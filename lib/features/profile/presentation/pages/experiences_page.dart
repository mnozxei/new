import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';

class ExperiencesPage extends StatelessWidget {
  const ExperiencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'الخبرات العملية',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () => context.push('/profile/experiences/new'),
            tooltip: 'إضافة خبرة',
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            if (state.experiences.isEmpty) {
              return _EmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              itemCount: state.experiences.length,
              itemBuilder: (context, index) {
                final experience = state.experiences[index];
                return _ExperienceCard(
                  experience: experience,
                  onEdit: () => context.push('/profile/experiences/${experience.id}/edit'),
                  onDelete: () => _showDeleteConfirmation(context, experience),
                );
              },
            );
          }

          return const Center(child: GlassLoadingIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/experiences/new'),
        icon: const Icon(Iconsax.add),
        label: const Text('إضافة خبرة'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ExperienceEntity experience) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الخبرة'),
        content: Text('هل أنت متأكد من حذف خبرة "${experience.title}" في ${experience.company}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ExperienceDeleteRequested(experience.id));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.briefcase,
                size: 60,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'لا توجد خبرات عملية',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'أضف خبراتك العملية لتظهر للشركات وأصحاب العمل',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: () => context.push('/profile/experiences/new'),
              icon: const Icon(Iconsax.add),
              label: const Text('إضافة خبرة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.experience,
    required this.onEdit,
    required this.onDelete,
  });

  final ExperienceEntity experience;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.building_3,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            experience.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (experience.isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الوظيفة الحالية',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience.company,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (dateRange.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar_1,
                            size: 16,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          const SizedBox(width: 6),
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
                    if (experience.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Iconsax.location,
                            size: 16,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          const SizedBox(width: 6),
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
            ],
          ),
          if (experience.description != null && experience.description!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            const Divider(),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              experience.description!,
              style: theme.textTheme.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Iconsax.edit_2, size: 18),
                label: const Text('تعديل'),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Iconsax.trash, size: 18),
                label: const Text('حذف'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
