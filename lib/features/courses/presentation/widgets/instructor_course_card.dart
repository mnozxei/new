import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/course_entity.dart';

class InstructorCourseCard extends StatelessWidget {
  const InstructorCourseCard({
    super.key,
    required this.course,
    this.onEdit,
    this.onTogglePublish,
    this.onViewStats,
    this.onDelete,
  });

  final CourseEntity course;
  final VoidCallback? onEdit;
  final VoidCallback? onTogglePublish;
  final VoidCallback? onViewStats;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: course.isPublished
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
                child: course.thumbnailUrl != null
                    ? Image.network(
                        course.thumbnailUrl!,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Row(
                      children: [
                        _StatusBadge(
                          isPublished: course.isPublished,
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        if (course.enrollmentCount > 0) ...[
                          Icon(
                            Iconsax.people,
                            size: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.enrollmentCount}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions menu
              PopupMenuButton<String>(
                icon: const Icon(Iconsax.more, size: 20),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'toggle_publish':
                      onTogglePublish?.call();
                      break;
                    case 'stats':
                      onViewStats?.call();
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Iconsax.edit, size: 18),
                        SizedBox(width: AppConstants.spacingSmall),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_publish',
                    child: Row(
                      children: [
                        Icon(
                          course.isPublished ? Iconsax.eye_slash : Iconsax.eye,
                          size: 18,
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        Text(course.isPublished ? 'إلغاء النشر' : 'نشر'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'stats',
                    child: Row(
                      children: [
                        Icon(Iconsax.chart_21, size: 18),
                        SizedBox(width: AppConstants.spacingSmall),
                        Text('الإحصائيات'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Iconsax.trash, size: 18, color: AppColors.error),
                        SizedBox(width: AppConstants.spacingSmall),
                        Text('حذف', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          // Stats row
          Row(
            children: [
              _StatItem(
                icon: Iconsax.people,
                value: '${course.enrollmentCount}',
                label: 'طالب',
              ),
              _StatItem(
                icon: Iconsax.star1,
                value: course.averageRating?.toStringAsFixed(1) ?? '-',
                label: 'تقييم',
              ),
              _StatItem(
                icon: Iconsax.video,
                value: '${course.lessonCount}',
                label: 'درس',
              ),
              if (course.price > 0)
                _StatItem(
                  icon: Iconsax.money_4,
                  value: '${course.price.toInt()}',
                  label: 'ر.س',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: const Icon(
        Iconsax.book_1,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الدورة'),
        content: Text('هل أنت متأكد من حذف "${course.title}"؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPublished});

  final bool isPublished;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isPublished
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        isPublished ? 'منشور' : 'مسودة',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isPublished ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
