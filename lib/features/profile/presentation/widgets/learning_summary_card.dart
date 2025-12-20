import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/repositories/profile_repository.dart';

export '../../domain/repositories/profile_repository.dart' show LearningStats;

class LearningSummaryCard extends StatelessWidget {
  const LearningSummaryCard({
    super.key,
    required this.stats,
    this.onViewAll,
  });

  final LearningStats stats;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.book_1,
                      color: AppColors.info,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  Text(
                    'ملخص التعلم',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll ?? () => context.push(RouteNames.myLearning),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Iconsax.play_circle,
                  label: 'مسجل',
                  value: stats.enrolledCount,
                  color: AppColors.primary,
                  onTap: () => context.push(RouteNames.myEnrollments),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _StatTile(
                  icon: Iconsax.timer_1,
                  label: 'قيد التقدم',
                  value: stats.inProgressCount,
                  color: AppColors.warning,
                  onTap: () => context.push(RouteNames.myLearning),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _StatTile(
                  icon: Iconsax.tick_circle,
                  label: 'مكتمل',
                  value: stats.completedCount,
                  color: AppColors.success,
                  onTap: () => context.push(RouteNames.myLearning),
                ),
              ),
            ],
          ),
          if (stats.enrolledCount == 0) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundSecondaryDark
                    : AppColors.backgroundSecondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.book,
                    size: 32,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'ابدأ رحلة التعلم الآن!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  ElevatedButton(
                    onPressed: () => context.push(RouteNames.courses),
                    child: const Text('تصفح الدورات'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingSmall),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
