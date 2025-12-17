import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class PostDetailsPage extends StatelessWidget {
  const PostDetailsPage({
    required this.postId,
    super.key,
  });

  final String postId;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobilePostDetailsPage(postId: postId),
      desktop: _DesktopPostDetailsPage(postId: postId),
    );
  }
}

class _MobilePostDetailsPage extends StatelessWidget {
  const _MobilePostDetailsPage({required this.postId});

  final String postId;

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
            onPressed: () {},
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
                  _PostContent(postId: postId),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const Divider(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text('التعليقات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.spacingMedium),
                  ...List.generate(5, (index) => _CommentItem(index: index)),
                ],
              ),
            ),
          ),
          _CommentInput(),
        ],
      ),
    );
  }
}

class _DesktopPostDetailsPage extends StatelessWidget {
  const _DesktopPostDetailsPage({required this.postId});

  final String postId;

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
                        _PostContent(postId: postId),
                        const SizedBox(height: AppConstants.spacingMedium),
                        const Divider(),
                        const SizedBox(height: AppConstants.spacingMedium),
                        Text('التعليقات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppConstants.spacingMedium),
                        ...List.generate(5, (index) => _CommentItem(index: index)),
                      ],
                    ),
                  ),
                ),
                _CommentInput(),
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
                  (index) => _RelatedPost(index: index),
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
  const _PostContent({required this.postId});

  final String postId;

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
                onPressed: () {},
                intensity: GlassIntensity.light,
                child: Text('متابعة', style: theme.textTheme.labelMedium),
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
              Icon(Iconsax.like_1, size: 18, color: AppColors.primary),
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
              _PostActionButton(icon: Iconsax.like_1, label: 'إعجاب', onTap: () {}),
              _PostActionButton(icon: Iconsax.message, label: 'تعليق', onTap: () {}),
              _PostActionButton(icon: Iconsax.share, label: 'مشاركة', onTap: () {}),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Icon(icon, size: 20, color: AppColors.textSecondaryLight),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({required this.index});

  final int index;

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
                        onTap: () {},
                        child: Text('إعجاب', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      InkWell(
                        onTap: () {},
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
            const Expanded(
              child: GlassTextField(
                hintText: 'اكتب تعليقاً...',
                maxLines: 1,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            IconButton(
              icon: const Icon(Iconsax.send_1, color: AppColors.primary),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedPost extends StatelessWidget {
  const _RelatedPost({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
    );
  }
}
