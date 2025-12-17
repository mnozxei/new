import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class LessonPage extends StatelessWidget {
  const LessonPage({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Lesson 1',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.bookmark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              color: AppColors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.play,
                        size: 32,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      'Video Player Placeholder',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Introduction to Flutter',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(
                    children: [
                      _LessonTag(icon: Iconsax.clock, label: '10 min'),
                      const SizedBox(width: AppConstants.spacingSmall),
                      _LessonTag(icon: Iconsax.video_play, label: 'Video'),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'Lesson Description',
                    intensity: GlassIntensity.light,
                    child: Text(
                      'In this lesson, you will learn the fundamentals of Flutter, including its architecture, widget system, and how to set up your development environment. By the end of this lesson, you will have a solid understanding of what Flutter is and how it works.',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'Resources',
                    intensity: GlassIntensity.light,
                    child: Column(
                      children: [
                        _ResourceItem(
                          icon: Iconsax.document_download,
                          title: 'Lesson Slides',
                          subtitle: 'PDF - 2.4 MB',
                        ),
                        const Divider(),
                        _ResourceItem(
                          icon: Iconsax.code,
                          title: 'Source Code',
                          subtitle: 'ZIP - 1.2 MB',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'Notes',
                    intensity: GlassIntensity.light,
                    child: Column(
                      children: [
                        TextField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Write your notes here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Iconsax.save_2, size: 18),
                            label: const Text('Save Notes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _NavigationBottomSheet(),
    );
  }
}

class _LessonTag extends StatelessWidget {
  const _LessonTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  const _ResourceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryExtraLight,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Iconsax.import_1),
        onPressed: () {},
      ),
    );
  }
}

class _NavigationBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.arrow_right_1),
                label: const Text('Previous'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.tick_circle),
                label: const Text('Complete & Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
