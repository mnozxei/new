import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/profile_entity.dart';

class WorkHistoryPreviewCard extends StatelessWidget {
  const WorkHistoryPreviewCard({
    super.key,
    required this.experiences,
    this.isOwner = true,
    this.onAddExperience,
    this.onViewAll,
    this.onEditExperience,
  });

  final List<ExperienceEntity> experiences;
  final bool isOwner;
  final VoidCallback? onAddExperience;
  final VoidCallback? onViewAll;
  final void Function(ExperienceEntity)? onEditExperience;

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
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.briefcase,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  Text(
                    'الخبرات العملية',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isOwner)
                    IconButton(
                      onPressed: onAddExperience ?? () => context.push('/profile/experiences/new'),
                      icon: const Icon(Iconsax.add_circle, size: 22),
                      color: AppColors.primary,
                      tooltip: 'إضافة خبرة',
                    ),
                  if (experiences.length > 3)
                    TextButton(
                      onPressed: onViewAll ?? () => context.push('/profile/experiences'),
                      child: const Text('عرض الكل'),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          if (experiences.isEmpty)
            _EmptyState(isOwner: isOwner, onAdd: onAddExperience)
          else
            ...experiences.take(3).map(
                  (exp) => _ExperienceTile(
                    experience: exp,
                    isOwner: isOwner,
                    onEdit: onEditExperience != null ? () => onEditExperience!(exp) : null,
                  ),
                ),
          if (experiences.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
              child: Center(
                child: TextButton(
                  onPressed: onViewAll ?? () => context.push('/profile/experiences'),
                  child: Text('+${experiences.length - 3} خبرات أخرى'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isOwner,
    this.onAdd,
  });

  final bool isOwner;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundSecondaryDark
            : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.briefcase,
            size: 40,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            isOwner ? 'أضف خبراتك العملية' : 'لا توجد خبرات عملية',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (isOwner) ...[
            const SizedBox(height: 4),
            Text(
              'شارك تجربتك المهنية مع أصحاب العمل',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            ElevatedButton.icon(
              onPressed: onAdd ?? () => context.push('/profile/experiences/new'),
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('إضافة خبرة'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({
    required this.experience,
    required this.isOwner,
    this.onEdit,
  });

  final ExperienceEntity experience;
  final bool isOwner;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM yyyy', 'ar');

    String dateRange = '';
    if (experience.startDate != null) {
      dateRange = dateFormat.format(experience.startDate!);
      if (experience.isCurrent) {
        dateRange += ' - الآن';
      } else if (experience.endDate != null) {
        dateRange += ' - ${dateFormat.format(experience.endDate!)}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundSecondaryDark
            : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.building_3,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        experience.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (experience.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'حالي',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  experience.company,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (dateRange.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 12,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
                if (experience.location != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 12,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        experience.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isOwner)
            IconButton(
              onPressed: onEdit ?? () => context.push('/profile/experiences/${experience.id}/edit'),
              icon: const Icon(Iconsax.edit_2, size: 18),
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
