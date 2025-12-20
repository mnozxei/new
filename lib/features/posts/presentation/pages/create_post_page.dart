import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/policies/post_content_policy.dart';
import '../bloc/post_bloc.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _imageUrl;
  bool _isUploading = false;
  String? _linkWarning;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final content = _contentController.text;
    final hasLink = PostContentPolicy.containsUrl(content);
    setState(() {
      _linkWarning = hasLink ? 'لا يُسمح بإضافة روابط في المنشورات' : null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await pickedFile.readAsBytes();
        final fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

        await Supabase.instance.client.storage.from('media').uploadBinary(fileName, bytes);
        final publicUrl = Supabase.instance.client.storage.from('media').getPublicUrl(fileName);

        setState(() {
          _imageUrl = publicUrl;
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل رفع الصورة: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  void _removeImage() {
    setState(() => _imageUrl = null);
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة محتوى المنشور'), backgroundColor: AppColors.warning),
      );
      return;
    }

    // Final validation for no-links
    final validationError = PostContentPolicy.validate(content);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: AppColors.error),
      );
      return;
    }

    context.read<PostBloc>().add(CreatePost(
      content: content,
      mediaUrls: _imageUrl != null ? [_imageUrl!] : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم نشر المنشور بنجاح'), backgroundColor: AppColors.success),
          );
          context.pop();
        } else if (state is PostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: ResponsiveLayout(
        mobile: _MobileCreatePostPage(
          formKey: _formKey,
          contentController: _contentController,
          imageUrl: _imageUrl,
          isUploading: _isUploading,
          linkWarning: _linkWarning,
          onPickImage: _pickImage,
          onRemoveImage: _removeImage,
          onSubmit: _handleSubmit,
        ),
        desktop: _DesktopCreatePostPage(
          formKey: _formKey,
          contentController: _contentController,
          imageUrl: _imageUrl,
          isUploading: _isUploading,
          linkWarning: _linkWarning,
          onPickImage: _pickImage,
          onRemoveImage: _removeImage,
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}

class _MobileCreatePostPage extends StatelessWidget {
  const _MobileCreatePostPage({
    required this.formKey,
    required this.contentController,
    required this.imageUrl,
    required this.isUploading,
    required this.linkWarning,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController contentController;
  final String? imageUrl;
  final bool isUploading;
  final String? linkWarning;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userName = currentUser?.userMetadata?['full_name'] ?? 'مستخدم';
    final initials = userName.isNotEmpty ? userName[0] : '?';

    return Scaffold(
      appBar: GlassAppBar(
        title: 'منشور جديد',
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              final isLoading = state is PostCreating;
              return Padding(
                padding: const EdgeInsets.only(left: AppConstants.spacingMedium),
                child: GlassButton(
                  onPressed: isLoading ? null : onSubmit,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                      : Text('نشر', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLighter,
                    child: Text(initials, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('نشر للعامة', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              GlassTextField(
                controller: contentController,
                hintText: 'ماذا تريد أن تشارك؟',
                maxLines: 8,
                minLines: 4,
                inputFormatters: [NoLinksInputFormatter()],
                validator: (value) => PostContentPolicy.validate(value),
              ),
              if (linkWarning != null) ...[
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  children: [
                    const Icon(Iconsax.warning_2, size: 16, color: AppColors.error),
                    const SizedBox(width: AppConstants.spacingExtraSmall),
                    Text(linkWarning!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error)),
                  ],
                ),
              ],
              if (isUploading) ...[
                const SizedBox(height: AppConstants.spacingMedium),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: AppConstants.spacingSmall),
                Center(child: Text('جاري رفع الصورة...', style: theme.textTheme.bodySmall)),
              ],
              if (imageUrl != null) ...[
                const SizedBox(height: AppConstants.spacingMedium),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      child: Image.network(
                        imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          width: double.infinity,
                          color: AppColors.primaryExtraLight,
                          child: const Center(child: Icon(Iconsax.image, size: 64, color: AppColors.primaryLighter)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GlassIconButton(
                        icon: Iconsax.close_circle,
                        size: 32,
                        onPressed: onRemoveImage,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppConstants.spacingLarge),
              const Divider(),
              const SizedBox(height: AppConstants.spacingMedium),
              _AttachmentOptions(
                onPickImage: onPickImage,
                hasImage: imageUrl != null,
                isUploading: isUploading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopCreatePostPage extends StatelessWidget {
  const _DesktopCreatePostPage({
    required this.formKey,
    required this.contentController,
    required this.imageUrl,
    required this.isUploading,
    required this.linkWarning,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController contentController;
  final String? imageUrl;
  final bool isUploading;
  final String? linkWarning;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userName = currentUser?.userMetadata?['full_name'] ?? 'مستخدم';
    final initials = userName.isNotEmpty ? userName[0] : '?';

    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.all(AppConstants.spacingLarge),
          child: GlassCard(
            intensity: GlassIntensity.light,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Text('منشور جديد', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      BlocBuilder<PostBloc, PostState>(
                        builder: (context, state) {
                          final isLoading = state is PostCreating;
                          return GlassButton(
                            onPressed: isLoading ? null : onSubmit,
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                                : Text('نشر', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryLighter,
                        child: Text(initials, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingSmall,
                              vertical: AppConstants.spacingExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryExtraLight,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.global, size: 14, color: AppColors.textSecondaryLight),
                                const SizedBox(width: AppConstants.spacingExtraSmall),
                                Text('عام', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  GlassTextField(
                    controller: contentController,
                    hintText: 'ماذا تريد أن تشارك؟',
                    maxLines: 10,
                    minLines: 6,
                    inputFormatters: [NoLinksInputFormatter()],
                    validator: (value) => PostContentPolicy.validate(value),
                  ),
                  if (linkWarning != null) ...[
                    const SizedBox(height: AppConstants.spacingSmall),
                    Row(
                      children: [
                        const Icon(Iconsax.warning_2, size: 16, color: AppColors.error),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        Text(linkWarning!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error)),
                      ],
                    ),
                  ],
                  if (isUploading) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Center(child: Text('جاري رفع الصورة...', style: theme.textTheme.bodySmall)),
                  ],
                  if (imageUrl != null) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          child: Image.network(
                            imageUrl!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 250,
                              width: double.infinity,
                              color: AppColors.primaryExtraLight,
                              child: const Center(child: Icon(Iconsax.image, size: 64, color: AppColors.primaryLighter)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GlassIconButton(
                            icon: Iconsax.close_circle,
                            size: 36,
                            onPressed: onRemoveImage,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacingLarge),
                  const Divider(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _AttachmentOptions(
                    onPickImage: onPickImage,
                    hasImage: imageUrl != null,
                    isUploading: isUploading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentOptions extends StatelessWidget {
  const _AttachmentOptions({
    required this.onPickImage,
    required this.hasImage,
    required this.isUploading,
  });

  final VoidCallback onPickImage;
  final bool hasImage;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AttachmentButton(
          icon: Iconsax.image,
          label: 'صورة',
          color: AppColors.success,
          onTap: (hasImage || isUploading) ? null : onPickImage,
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        _AttachmentButton(
          icon: Iconsax.hashtag,
          label: 'وسم',
          color: AppColors.primary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('استخدم # في النص لإضافة وسوم')),
            );
          },
        ),
      ],
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingSmall),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppConstants.spacingExtraSmall),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
