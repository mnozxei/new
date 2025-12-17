import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/verified_badge.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.arrow_right_1,
                  color: AppColors.white,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.more,
                    color: AppColors.white,
                  ),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                        borderRadius: const BorderRadius.only(
                          topLeft:
                              Radius.circular(AppConstants.borderRadiusExtraLarge),
                          topRight:
                              Radius.circular(AppConstants.borderRadiusExtraLarge),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.backgroundDark
                              : AppColors.backgroundLight,
                          width: 4,
                        ),
                        boxShadow: AppColors.elevatedShadowLight,
                      ),
                      child: const CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primaryLighter,
                        child: Icon(
                          Iconsax.user,
                          size: 48,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'User Name',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        const VerifiedBadge(size: VerifiedBadgeSize.medium),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Text(
                      'Software Engineer',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(label: 'Followers', value: '1.2K'),
                          _StatItem(label: 'Following', value: '345'),
                          _StatItem(label: 'Posts', value: '42'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Follow'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        GlassIconButton(
                          icon: Iconsax.message,
                          onPressed: () {},
                          intensity: GlassIntensity.light,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    GlassPanel(
                      title: 'About',
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passionate software engineer with 5+ years of experience in mobile development.',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.location,
                                size: 16,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: AppConstants.spacingSmall),
                              Text(
                                'Riyadh, Saudi Arabia',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    GlassPanel(
                      title: 'Recent Posts',
                      intensity: GlassIntensity.light,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacingLarge),
                          child: Column(
                            children: [
                              const Icon(
                                Iconsax.document_text,
                                size: 48,
                                color: AppColors.textTertiaryLight,
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),
                              Text(
                                'No posts yet',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingExtraSmall),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
