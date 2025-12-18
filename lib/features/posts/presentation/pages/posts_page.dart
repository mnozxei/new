import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobilePostsPage(),
      desktop: const _DesktopPostsPage(),
    );
  }
}

class _MobilePostsPage extends StatelessWidget {
  const _MobilePostsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'المنشورات',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification),
                onPressed: () => context.push(RouteNames.notifications),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.createPost),
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: AppColors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 10,
        itemBuilder: (context, index) => _PostCard(index: index),
      ),
    );
  }
}

class _DesktopPostsPage extends StatelessWidget {
  const _DesktopPostsPage();

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
                      Text('المنشورات', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Iconsax.notification),
                            onPressed: () => context.push(RouteNames.notifications),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      GlassButton(
                        onPressed: () => context.pushNamed(RouteNames.createPost),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.add, size: 18),
                            const SizedBox(width: AppConstants.spacingSmall),
                            Text('منشور جديد', style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
                    itemCount: 10,
                    itemBuilder: (context, index) => _PostCard(index: index),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassPanel(
                  title: 'المواضيع الرائجة',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
                        child: Row(
                          children: [
                            Text('#موضوع_${index + 1}', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                            const Spacer(),
                            Text('${(index + 1) * 123} منشور', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassPanel(
                  title: 'اقتراحات المتابعة',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => _SuggestedCompany(index: index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.pushNamed(RouteNames.postDetails, pathParameters: {'id': '$index'}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLighter,
                child: Text('ش', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('شركة التقنية المتقدمة', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        if (index % 2 == 0) const VerifiedBadge(size: VerifiedBadgeSize.small, type: VerifiedBadgeType.company),
                      ],
                    ),
                    Text('منذ ${index + 1} ساعات', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.more, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'هذا نص تجريبي للمنشور رقم ${index + 1}. يمكن أن يحتوي المنشور على نص طويل ومحتوى متنوع.',
            style: theme.textTheme.bodyMedium,
          ),
          if (index % 3 == 0) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.primaryExtraLight,
                child: const Center(child: Icon(Iconsax.image, size: 48, color: AppColors.primaryLighter)),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              _PostAction(icon: Iconsax.like_1, label: '${(index + 1) * 12}', onTap: () {}),
              const SizedBox(width: AppConstants.spacingLarge),
              _PostAction(icon: Iconsax.message, label: '${(index + 1) * 3}', onTap: () {}),
              const SizedBox(width: AppConstants.spacingLarge),
              _PostAction(icon: Iconsax.share, label: 'مشاركة', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
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
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondaryLight),
            const SizedBox(width: AppConstants.spacingExtraSmall),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}

class _SuggestedCompany extends StatelessWidget {
  const _SuggestedCompany({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLighter,
            child: Text('${index + 1}', style: const TextStyle(color: AppColors.white)),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('شركة ${index + 1}', style: theme.textTheme.titleSmall),
                Text('${(index + 1) * 1000} متابع', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }
}
