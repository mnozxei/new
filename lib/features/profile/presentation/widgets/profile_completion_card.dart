import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/services/profile_completion_service.dart';

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({
    super.key,
    required this.completionResult,
    this.showDetails = true,
  });

  final ProfileCompletionResult completionResult;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percent = completionResult.percent;

    if (percent >= 100) {
      return const SizedBox.shrink();
    }

    final nextAction = ProfileCompletionService.getNextAction(completionResult);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.chart_1,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اكتمال الملف الشخصي',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أكمل ملفك الشخصي للحصول على فرص أفضل',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getProgressColor(percent).withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    '$percent%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(percent),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppColors.backgroundTertiaryDark
                  : AppColors.backgroundTertiaryLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(percent),
              ),
            ),
          ),
          if (showDetails && completionResult.missingItems.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            const Divider(),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'لإكمال ملفك الشخصي:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            ...completionResult.missingItems.take(3).map(
                  (item) => _MissingItemTile(item: item),
                ),
            if (completionResult.missingItems.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
                child: Text(
                  '+${completionResult.missingItems.length - 3} عناصر أخرى',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
          if (nextAction != null) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(nextAction.route.split('#').first),
                icon: const Icon(Iconsax.add_circle, size: 18),
                label: Text('أضف ${nextAction.getLabel('ar')}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(int percent) {
    if (percent >= 80) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.primary;
  }
}

class _MissingItemTile extends StatelessWidget {
  const _MissingItemTile({required this.item});

  final MissingProfileItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push(item.route.split('#').first),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingSmall,
          horizontal: AppConstants.spacingExtraSmall,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              child: const Icon(
                Iconsax.add,
                size: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: Text(
                item.getLabel('ar'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              '+${(item.weight * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
