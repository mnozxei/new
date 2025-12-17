import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({
    required this.courseId,
    super.key,
  });

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                child: const Icon(Iconsax.arrow_right_1, color: AppColors.white),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Icon(
                    Iconsax.book_1,
                    size: 64,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flutter Development Masterclass',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 18, color: AppColors.warning),
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      Text('4.8', style: theme.textTheme.titleSmall),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        '(234 reviews)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      const Icon(Iconsax.people, size: 18, color: AppColors.textSecondaryLight),
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      Text(
                        '1,234 enrolled',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _InstructorCard(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _CourseStats(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'About This Course',
                    intensity: GlassIntensity.light,
                    child: Text(
                      'Learn Flutter from scratch and build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. This comprehensive course covers everything you need to know to become a proficient Flutter developer.',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'Course Content',
                    trailing: Text(
                      '12 sections',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    intensity: GlassIntensity.light,
                    child: Column(
                      children: List.generate(
                        5,
                        (index) => _SectionItem(
                          index: index,
                          courseId: courseId,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _EnrollBottomSheet(),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLighter,
            child: const Text(
              'I',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructor Name',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Senior Flutter Developer',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }
}

class _CourseStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Iconsax.clock,
            value: '12h 30m',
            label: 'Duration',
          ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Expanded(
          child: _StatCard(
            icon: Iconsax.video_play,
            value: '85',
            label: 'Lessons',
          ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Expanded(
          child: _StatCard(
            icon: Iconsax.medal_star,
            value: 'Certificate',
            label: 'Included',
          ),
        ),
      ],
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
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionItem extends StatelessWidget {
  const _SectionItem({
    required this.index,
    required this.courseId,
  });

  final int index;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        'Section ${index + 1}: Getting Started',
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        '5 lessons',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      children: List.generate(
        3,
        (lessonIndex) => ListTile(
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: lessonIndex == 0
                ? AppColors.primary
                : AppColors.primaryLightest,
            child: Icon(
              lessonIndex == 0 ? Iconsax.tick_circle : Iconsax.play,
              size: 14,
              color: lessonIndex == 0 ? AppColors.white : AppColors.primary,
            ),
          ),
          title: Text(
            'Lesson ${lessonIndex + 1}: Introduction',
            style: theme.textTheme.bodyMedium,
          ),
          subtitle: Text(
            '10 min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          onTap: () => context.push(
            '${RouteNames.courses}/$courseId/lesson/lesson-$lessonIndex',
          ),
        ),
      ),
    );
  }
}

class _EnrollBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Lifetime access',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppConstants.spacingLarge),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Enroll Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
