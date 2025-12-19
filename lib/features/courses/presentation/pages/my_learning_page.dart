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
import '../bloc/student_bloc.dart';

class MyLearningPage extends StatefulWidget {
  const MyLearningPage({super.key});

  @override
  State<MyLearningPage> createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EnrollmentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadEnrollments();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      EnrollmentStatus? status;
      switch (_tabController.index) {
        case 0:
          status = null; // All
          break;
        case 1:
          status = EnrollmentStatus.active;
          break;
        case 2:
          status = EnrollmentStatus.completed;
          break;
      }
      setState(() => _selectedStatus = status);
      _loadEnrollments();
    }
  }

  void _loadEnrollments() {
    context.read<StudentBloc>().add(LoadMyEnrollments(status: _selectedStatus));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'تعلمي',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'قيد التعلم'),
            Tab(text: 'مكتمل'),
          ],
        ),
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentError) {
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
                  Text(state.message),
                  const SizedBox(height: AppConstants.spacingMedium),
                  FilledButton(
                    onPressed: _loadEnrollments,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is EnrollmentsLoaded) {
            if (state.enrollments.isEmpty) {
              return _buildEmptyState(theme);
            }

            return RefreshIndicator(
              onRefresh: () async => _loadEnrollments(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                itemCount: state.enrollments.length,
                itemBuilder: (context, index) {
                  final enrollment = state.enrollments[index];
                  return _EnrollmentCard(
                    enrollment: enrollment,
                    onTap: () => context.push(
                      '${RouteNames.courses}/${enrollment.courseId}',
                    ),
                    onContinue: () => _continueLearning(enrollment),
                  );
                },
              ),
            );
          }

          return _buildEmptyState(theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.book_1,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'لا توجد دورات بعد',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'ابدأ رحلة التعلم واكتشف دورات جديدة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            FilledButton.icon(
              onPressed: () => context.go(RouteNames.courses),
              icon: const Icon(Iconsax.search_normal),
              label: const Text('تصفح الدورات'),
            ),
          ],
        ),
      ),
    );
  }

  void _continueLearning(EnrollmentEntity enrollment) {
    if (enrollment.currentLessonId != null) {
      context.push(
        '${RouteNames.courses}/${enrollment.courseId}/${RouteNames.lesson}/${enrollment.currentLessonId}',
      );
    } else {
      context.push('${RouteNames.courses}/${enrollment.courseId}');
    }
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({
    required this.enrollment,
    required this.onTap,
    required this.onContinue,
  });

  final EnrollmentEntity enrollment;
  final VoidCallback onTap;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final course = enrollment.course;

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                child: course?.thumbnailUrl != null
                    ? Image.network(
                        course!.thumbnailUrl!,
                        width: 100,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.title ?? 'دورة',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    if (course?.instructor != null)
                      Text(
                        course!.instructor!.fullName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    _StatusBadge(status: enrollment.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التقدم',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    '${enrollment.progressPercent}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingExtraSmall),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: enrollment.progressPercent / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.primaryExtraLight,
                  valueColor: AlwaysStoppedAnimation(
                    enrollment.isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          if (!enrollment.isCompleted) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Iconsax.play, size: 18),
                label: const Text('متابعة التعلم'),
              ),
            ),
          ] else if (enrollment.certificateUrl != null) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Download/view certificate
                },
                icon: const Icon(Iconsax.medal_star, size: 18),
                label: const Text('عرض الشهادة'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: const Icon(Iconsax.book_1, color: Colors.white),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EnrollmentStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case EnrollmentStatus.active:
        color = AppColors.info;
        label = 'قيد التعلم';
        break;
      case EnrollmentStatus.completed:
        color = AppColors.success;
        label = 'مكتمل';
        break;
      case EnrollmentStatus.paused:
        color = AppColors.warning;
        label = 'متوقف';
        break;
      case EnrollmentStatus.refunded:
        color = AppColors.error;
        label = 'مسترد';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
