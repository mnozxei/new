import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class InstructorDashboardPage extends StatelessWidget {
  const InstructorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Instructor Dashboard',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () {},
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
                Expanded(child: _StatCard(icon: Iconsax.people, value: '1,234', label: 'Total Students')),
                const SizedBox(width: AppConstants.spacingSmall),
                Expanded(child: _StatCard(icon: Iconsax.book, value: '5', label: 'Courses')),
                const SizedBox(width: AppConstants.spacingSmall),
                Expanded(child: _StatCard(icon: Iconsax.star1, value: '4.8', label: 'Rating')),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            GlassPanel(
              title: 'My Courses',
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Create New'),
              ),
              intensity: GlassIntensity.light,
              child: Column(
                children: List.generate(
                  3,
                  (index) => _CourseItem(index: index),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            GlassPanel(
              title: 'Recent Reviews',
              intensity: GlassIntensity.light,
              child: Column(
                children: List.generate(
                  3,
                  (index) => _ReviewItem(index: index),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            GlassPanel(
              title: 'Earnings',
              intensity: GlassIntensity.light,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('This Month', style: theme.textTheme.bodyMedium),
                      Text('SAR 5,000', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Earnings', style: theme.textTheme.bodyMedium),
                      Text('SAR 45,000', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _CourseItem extends StatelessWidget {
  const _CourseItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Icon(Iconsax.book_1, color: AppColors.white),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Course Name ${index + 1}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('234 students', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Iconsax.edit), onPressed: () {}),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLighter,
            child: Text('S', style: const TextStyle(color: AppColors.white)),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Student Name', style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (i) => Icon(Iconsax.star1, size: 14, color: i < 4 ? AppColors.warning : AppColors.textTertiaryLight)),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingExtraSmall),
                Text('Great course! Very helpful and well explained.', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
