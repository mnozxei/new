import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  bool _hasImage = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileCreatePostPage(
        contentController: _contentController,
        hasImage: _hasImage,
        onImageToggle: () => setState(() => _hasImage = !_hasImage),
      ),
      desktop: _DesktopCreatePostPage(
        contentController: _contentController,
        hasImage: _hasImage,
        onImageToggle: () => setState(() => _hasImage = !_hasImage),
      ),
    );
  }
}

class _MobileCreatePostPage extends StatelessWidget {
  const _MobileCreatePostPage({
    required this.contentController,
    required this.hasImage,
    required this.onImageToggle,
  });

  final TextEditingController contentController;
  final bool hasImage;
  final VoidCallback onImageToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'منشور جديد',
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: AppConstants.spacingMedium),
            child: GlassButton(
              onPressed: () {
                // TODO: Post creation logic
                context.pop();
              },
              child: Text('نشر', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLighter,
                  child: Text('أ', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أحمد محمد', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
            ),
            if (hasImage) ...[
              const SizedBox(height: AppConstants.spacingMedium),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColors.primaryExtraLight,
                      child: const Center(
                        child: Icon(Iconsax.image, size: 64, color: AppColors.primaryLighter),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GlassIconButton(
                      icon: Iconsax.close_circle,
                      size: 32,
                      onPressed: onImageToggle,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppConstants.spacingLarge),
            const Divider(),
            const SizedBox(height: AppConstants.spacingMedium),
            _AttachmentOptions(onImageToggle: onImageToggle, hasImage: hasImage),
          ],
        ),
      ),
    );
  }
}

class _DesktopCreatePostPage extends StatelessWidget {
  const _DesktopCreatePostPage({
    required this.contentController,
    required this.hasImage,
    required this.onImageToggle,
  });

  final TextEditingController contentController;
  final bool hasImage;
  final VoidCallback onImageToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.all(AppConstants.spacingLarge),
          child: GlassCard(
            intensity: GlassIntensity.light,
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
                    GlassButton(
                      onPressed: () {
                        // TODO: Post creation logic
                        context.pop();
                      },
                      child: Text('نشر', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLighter,
                      child: Text('أ', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد محمد', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                              const Icon(Iconsax.arrow_down_1, size: 14, color: AppColors.textSecondaryLight),
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
                ),
                if (hasImage) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          color: AppColors.primaryExtraLight,
                          child: const Center(
                            child: Icon(Iconsax.image, size: 64, color: AppColors.primaryLighter),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GlassIconButton(
                          icon: Iconsax.close_circle,
                          size: 36,
                          onPressed: onImageToggle,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppConstants.spacingLarge),
                const Divider(),
                const SizedBox(height: AppConstants.spacingMedium),
                _AttachmentOptions(onImageToggle: onImageToggle, hasImage: hasImage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentOptions extends StatelessWidget {
  const _AttachmentOptions({
    required this.onImageToggle,
    required this.hasImage,
  });

  final VoidCallback onImageToggle;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _AttachmentButton(
          icon: Iconsax.image,
          label: 'صورة',
          color: AppColors.success,
          onTap: hasImage ? null : onImageToggle,
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        _AttachmentButton(
          icon: Iconsax.video,
          label: 'فيديو',
          color: AppColors.info,
          onTap: () {},
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        _AttachmentButton(
          icon: Iconsax.document,
          label: 'ملف',
          color: AppColors.warning,
          onTap: () {},
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        _AttachmentButton(
          icon: Iconsax.hashtag,
          label: 'وسم',
          color: AppColors.primary,
          onTap: () {},
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
