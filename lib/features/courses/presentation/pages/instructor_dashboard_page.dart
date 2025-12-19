import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/instructor_bloc.dart';
import '../widgets/instructor_stats_card.dart';
import '../widgets/instructor_course_card.dart';

class InstructorDashboardPage extends StatefulWidget {
  const InstructorDashboardPage({super.key});

  @override
  State<InstructorDashboardPage> createState() =>
      _InstructorDashboardPageState();
}

class _InstructorDashboardPageState extends State<InstructorDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<InstructorBloc>().add(const LoadInstructorDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'لوحة المدرب',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () => context.push(
              '${RouteNames.instructorDashboard}/${RouteNames.courseBuilder}',
            ),
            tooltip: 'إنشاء دورة جديدة',
          ),
        ],
      ),
      body: BlocBuilder<InstructorBloc, InstructorState>(
        builder: (context, state) {
          if (state is InstructorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InstructorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 64,
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    'حدث خطأ',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  FilledButton.icon(
                    onPressed: () {
                      context
                          .read<InstructorBloc>()
                          .add(const LoadInstructorDashboard());
                    },
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is InstructorDashboardLoaded) {
            return _DashboardContent(
              courses: state.courses,
              stats: state.stats,
            );
          }

          // Initial or other states - show placeholder
          return _DashboardContent(
            courses: const [],
            stats: const InstructorStats(),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.courses,
    required this.stats,
  });

  final List<CourseEntity> courses;
  final InstructorStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<InstructorBloc>().add(const LoadInstructorDashboard());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: InstructorStatsCard(
                    icon: Iconsax.people,
                    value: _formatNumber(stats.totalStudents),
                    label: 'الطلاب',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Expanded(
                  child: InstructorStatsCard(
                    icon: Iconsax.book,
                    value: stats.totalCourses.toString(),
                    label: 'الدورات',
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Expanded(
                  child: InstructorStatsCard(
                    icon: Iconsax.star1,
                    value: stats.averageRating.toStringAsFixed(1),
                    label: 'التقييم',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Revenue Card
            GlassCard(
              intensity: GlassIntensity.light,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    child: const Icon(
                      Iconsax.money_recive,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي الإيرادات',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          '${_formatNumber(stats.totalRevenue.toInt())} ر.س',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to earnings details
                    },
                    child: const Text('التفاصيل'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // My Courses Section
            GlassPanel(
              title: 'دوراتي',
              trailing: TextButton.icon(
                onPressed: () => context.push(
                  '${RouteNames.instructorDashboard}/${RouteNames.courseBuilder}',
                ),
                icon: const Icon(Iconsax.add, size: 18),
                label: const Text('جديدة'),
              ),
              intensity: GlassIntensity.light,
              child: courses.isEmpty
                  ? _EmptyCoursesState()
                  : Column(
                      children: courses.map((course) {
                        return InstructorCourseCard(
                          course: course,
                          onEdit: () => context.push(
                            '${RouteNames.instructorDashboard}/${RouteNames.courseBuilder}?courseId=${course.id}',
                          ),
                          onTogglePublish: () {
                            context
                                .read<InstructorBloc>()
                                .add(ToggleCoursePublish(course.id));
                          },
                          onViewStats: () {
                            context
                                .read<InstructorBloc>()
                                .add(LoadCourseStats(course.id));
                          },
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Quick Actions
            GlassPanel(
              title: 'إجراءات سريعة',
              intensity: GlassIntensity.light,
              child: Column(
                children: [
                  _QuickActionItem(
                    icon: Iconsax.add_circle,
                    title: 'إنشاء دورة جديدة',
                    subtitle: 'ابدأ بإنشاء محتوى جديد',
                    onTap: () => context.push(
                      '${RouteNames.instructorDashboard}/${RouteNames.courseBuilder}',
                    ),
                  ),
                  _QuickActionItem(
                    icon: Iconsax.chart_21,
                    title: 'عرض الإحصائيات',
                    subtitle: 'تحليلات مفصلة لأدائك',
                    onTap: () {
                      // TODO: Navigate to analytics
                    },
                  ),
                  _QuickActionItem(
                    icon: Iconsax.message_question,
                    title: 'أسئلة الطلاب',
                    subtitle: 'الرد على استفسارات طلابك',
                    onTap: () {
                      // TODO: Navigate to Q&A
                    },
                  ),
                  _QuickActionItem(
                    icon: Iconsax.star,
                    title: 'التقييمات والمراجعات',
                    subtitle: 'عرض آراء الطلاب',
                    showDivider: false,
                    onTap: () {
                      // TODO: Navigate to reviews
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _EmptyCoursesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingLarge),
      child: Column(
        children: [
          Icon(
            Iconsax.book,
            size: 48,
            color: AppColors.textTertiaryLight,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'لا توجد دورات بعد',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'ابدأ بإنشاء دورتك الأولى الآن',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          FilledButton.icon(
            onPressed: () => context.push(
              '${RouteNames.instructorDashboard}/${RouteNames.courseBuilder}',
            ),
            icon: const Icon(Iconsax.add),
            label: const Text('إنشاء دورة'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMedium,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Iconsax.arrow_left_2,
                  size: 18,
                  color: AppColors.textTertiaryLight,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
