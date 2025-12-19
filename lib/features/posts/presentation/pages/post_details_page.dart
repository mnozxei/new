import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/impressions_service.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({
    required this.postId,
    super.key,
  });

  final String postId;

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final ImpressionsService _impressionsService = ImpressionsService();
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _recordImpression();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _recordImpression() {
    _impressionsService.recordImpression(
      entityType: ImpressionEntityType.post,
      entityId: widget.postId,
    );
  }

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _handleLike() {
    if (_isAuthenticated) {
      setState(() => _isLiked = !_isLiked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLiked ? 'تم الإعجاب' : 'تم إزالة الإعجاب'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'like');
    }
  }

  void _handleComment() {
    if (!_isAuthenticated) {
      LoginRequiredDialog.showForAction(context, 'comment');
    }
    // Focus on comment field - already handled by tap
  }

  void _handleShare() {
    Share.share(
      'شاهد هذا المنشور على تماد هب\nhttps://tamadhub.com/posts/${widget.postId}',
      subject: 'منشور من تماد هب',
    );
  }

  void _handleFollow() {
    if (_isAuthenticated) {
      setState(() => _isFollowing = !_isFollowing);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFollowing ? 'تمت المتابعة' : 'تم إلغاء المتابعة'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'follow');
    }
  }

  void _handleCommentLike(int index) {
    if (_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الإعجاب بالتعليق'), duration: Duration(seconds: 1)),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'like');
    }
  }

  void _handleReply(int index) {
    if (_isAuthenticated) {
      _commentController.text = '@مستخدم${index + 1} ';
      FocusScope.of(context).requestFocus(FocusNode());
    } else {
      LoginRequiredDialog.showForAction(context, 'comment');
    }
  }

  void _handleSendComment() {
    if (!_isAuthenticated) {
      LoginRequiredDialog.showForAction(context, 'comment');
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    _commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إضافة التعليق'), duration: Duration(seconds: 1)),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Iconsax.bookmark),
              title: const Text('حفظ المنشور'),
              onTap: () {
                Navigator.pop(context);
                if (_isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ المنشور')),
                  );
                } else {
                  LoginRequiredDialog.showForAction(context, 'save');
                }
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.link),
              title: const Text('نسخ الرابط'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ الرابط')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.flag),
              title: const Text('الإبلاغ عن المنشور'),
              onTap: () {
                Navigator.pop(context);
                if (_isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لإبلاغك. سنراجع المنشور.')),
                  );
                } else {
                  LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول للإبلاغ');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleRelatedPostTap(int index) {
    context.pushReplacementNamed(RouteNames.postDetails, pathParameters: {'id': 'related-$index'});
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobilePostDetailsPage(
        postId: widget.postId,
        commentController: _commentController,
        isLiked: _isLiked,
        isFollowing: _isFollowing,
        onLike: _handleLike,
        onComment: _handleComment,
        onShare: _handleShare,
        onFollow: _handleFollow,
        onCommentLike: _handleCommentLike,
        onReply: _handleReply,
        onSendComment: _handleSendComment,
        onMore: _showMoreOptions,
      ),
      desktop: _DesktopPostDetailsPage(
        postId: widget.postId,
        commentController: _commentController,
        isLiked: _isLiked,
        isFollowing: _isFollowing,
        onLike: _handleLike,
        onComment: _handleComment,
        onShare: _handleShare,
        onFollow: _handleFollow,
        onCommentLike: _handleCommentLike,
        onReply: _handleReply,
        onSendComment: _handleSendComment,
        onRelatedPostTap: _handleRelatedPostTap,
      ),
    );
  }
}

class _MobilePostDetailsPage extends StatelessWidget {
  const _MobilePostDetailsPage({
    required this.postId,
    required this.commentController,
    required this.isLiked,
    required this.isFollowing,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onCommentLike,
    required this.onReply,
    required this.onSendComment,
    required this.onMore,
  });

  final String postId;
  final TextEditingController commentController;
  final bool isLiked;
  final bool isFollowing;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final void Function(int) onCommentLike;
  final void Function(int) onReply;
  final VoidCallback onSendComment;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'المنشور',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.more),
            onPressed: onMore,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostContent(
                    postId: postId,
                    isLiked: isLiked,
                    isFollowing: isFollowing,
                    onLike: onLike,
                    onComment: onComment,
                    onShare: onShare,
                    onFollow: onFollow,
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const Divider(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text('التعليقات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.spacingMedium),
                  ...List.generate(5, (index) => _CommentItem(
                    index: index,
                    onLike: () => onCommentLike(index),
                    onReply: () => onReply(index),
                  )),
                ],
              ),
            ),
          ),
          _CommentInput(
            controller: commentController,
            onSend: onSendComment,
          ),
        ],
      ),
    );
  }
}

class _DesktopPostDetailsPage extends StatelessWidget {
  const _DesktopPostDetailsPage({
    required this.postId,
    required this.commentController,
    required this.isLiked,
    required this.isFollowing,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onCommentLike,
    required this.onReply,
    required this.onSendComment,
    required this.onRelatedPostTap,
  });

  final String postId;
  final TextEditingController commentController;
  final bool isLiked;
  final bool isFollowing;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final void Function(int) onCommentLike;
  final void Function(int) onReply;
  final VoidCallback onSendComment;
  final void Function(int) onRelatedPostTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.arrow_right_1),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Text('المنشور', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PostContent(
                          postId: postId,
                          isLiked: isLiked,
                          isFollowing: isFollowing,
                          onLike: onLike,
                          onComment: onComment,
                          onShare: onShare,
                          onFollow: onFollow,
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        const Divider(),
                        const SizedBox(height: AppConstants.spacingMedium),
                        Text('التعليقات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppConstants.spacingMedium),
                        ...List.generate(5, (index) => _CommentItem(
                          index: index,
                          onLike: () => onCommentLike(index),
                          onReply: () => onReply(index),
                        )),
                      ],
                    ),
                  ),
                ),
                _CommentInput(
                  controller: commentController,
                  onSend: onSendComment,
                ),
              ],
            ),
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: GlassPanel(
              title: 'منشورات ذات صلة',
              intensity: GlassIntensity.light,
              child: Column(
                children: List.generate(
                  3,
                  (index) => _RelatedPost(
                    index: index,
                    onTap: () => onRelatedPostTap(index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  const _PostContent({
    required this.postId,
    required this.isLiked,
    required this.isFollowing,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
  });

  final String postId;
  final bool isLiked;
  final bool isFollowing;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLighter,
                child: Text('ش', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('شركة التقنية المتقدمة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        const VerifiedBadge(size: VerifiedBadgeSize.small, type: VerifiedBadgeType.company),
                      ],
                    ),
                    Text('منذ 3 ساعات', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              GlassButton(
                onPressed: onFollow,
                intensity: GlassIntensity.light,
                child: Text(isFollowing ? 'متابَع' : 'متابعة', style: theme.textTheme.labelMedium),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text(
            'هذا نص تجريبي مفصل للمنشور رقم $postId. يمكن أن يحتوي المنشور على نص طويل ومحتوى متنوع يشرح فكرة أو يعلن عن خبر أو يشارك معلومة مفيدة مع المتابعين.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            child: Container(
              height: 250,
              width: double.infinity,
              color: AppColors.primaryExtraLight,
              child: const Center(child: Icon(Iconsax.image, size: 64, color: AppColors.primaryLighter)),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              Icon(
                isLiked ? Iconsax.like_15 : Iconsax.like_1,
                size: 18,
                color: isLiked ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: AppConstants.spacingExtraSmall),
              Text('156', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(width: AppConstants.spacingLarge),
              Icon(Iconsax.message, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: AppConstants.spacingExtraSmall),
              Text('24 تعليق', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          const Divider(),
          const SizedBox(height: AppConstants.spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PostActionButton(
                icon: isLiked ? Iconsax.like_15 : Iconsax.like_1,
                label: 'إعجاب',
                isActive: isLiked,
                onTap: onLike,
              ),
              _PostActionButton(icon: Iconsax.message, label: 'تعليق', onTap: onComment),
              _PostActionButton(icon: Iconsax.share, label: 'مشاركة', onTap: onShare),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? AppColors.error : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.index,
    required this.onLike,
    required this.onReply,
  });

  final int index;
  final VoidCallback onLike;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLighter,
            child: Text('م', style: const TextStyle(color: AppColors.white, fontSize: 14)),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('مستخدم ${index + 1}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text('منذ ${index + 1} ساعة', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingExtraSmall),
                  Text(
                    'تعليق رائع على هذا المنشور المفيد!',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(
                    children: [
                      InkWell(
                        onTap: onLike,
                        child: Text('إعجاب', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      InkWell(
                        onTap: onReply,
                        child: Text('رد', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLighter,
              child: Text('أ', style: const TextStyle(color: AppColors.white, fontSize: 14)),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: GlassTextField(
                controller: controller,
                hintText: 'اكتب تعليقاً...',
                maxLines: 1,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            IconButton(
              icon: const Icon(Iconsax.send_1, color: AppColors.primary),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedPost extends StatelessWidget {
  const _RelatedPost({
    required this.index,
    required this.onTap,
  });

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLighter,
              child: Text('${index + 1}', style: const TextStyle(color: AppColors.white, fontSize: 12)),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('منشور ذو صلة ${index + 1}', style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('${(index + 1) * 45} إعجاب', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
