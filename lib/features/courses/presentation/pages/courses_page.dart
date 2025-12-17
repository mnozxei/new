import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'Courses',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () => context.push(RouteNames.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: GlassSearchField(
              hint: 'Search courses...',
              onChanged: (query) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(label: 'All', isSelected: true),
                  _CategoryChip(label: 'Development'),
                  _CategoryChip(label: 'Design'),
                  _CategoryChip(label: 'Marketing'),
                  _CategoryChip(label: 'Business'),
                  _CategoryChip(label: 'Finance'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ResponsiveLayout(
              mobile: _MobileCoursesList(),
              desktop: _DesktopCoursesList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    this.isSelected = false,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacingSmall),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
      ),
    );
  }
}

class _MobileCoursesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: 10,
      itemBuilder: (context, index) => _CourseCard(
        index: index,
        onTap: () => context.push('${RouteNames.courses}/course-$index'),
      ),
    );
  }
}

class _DesktopCoursesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppConstants.spacingMedium,
        mainAxisSpacing: AppConstants.spacingMedium,
        childAspectRatio: 0.8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => _CourseCard(
        index: index,
        onTap: () => context.push('${RouteNames.courses}/course-$index'),
        isCompact: true,
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.index,
    required this.onTap,
    this.isCompact = false,
  });

  final int index;
  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: onTap,
      intensity: GlassIntensity.light,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isCompact ? 120 : 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusLarge),
                topRight: Radius.circular(AppConstants.borderRadiusLarge),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Iconsax.book_1,
                    size: 48,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
                Positioned(
                  top: AppConstants.spacingSmall,
                  left: AppConstants.spacingSmall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSmall,
                      vertical: AppConstants.spacingExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: const Text(
                      'Development',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flutter Development Masterclass',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryLighter,
                      child: const Text(
                        'I',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      'Instructor Name',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  children: [
                    const Icon(
                      Iconsax.star1,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppConstants.spacingExtraSmall),
                    Text(
                      '4.8',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      '(234 reviews)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '12 hours',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                if (!isCompact) ...[
                  const SizedBox(height: AppConstants.spacingSmall),
                  LinearProgressIndicator(
                    value: index * 0.1,
                    backgroundColor: AppColors.primaryLightest,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: AppConstants.spacingExtraSmall),
                  Text(
                    '${(index * 10).clamp(0, 100)}% complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
