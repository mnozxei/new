import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/injection/injection.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/impressions_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_bloc.dart';
import '../bloc/course_event.dart';
import '../bloc/course_state.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({
    required this.courseId,
    super.key,
  });

  final String courseId;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage>
    with SingleTickerProviderStateMixin {
  final ImpressionsService _impressionsService = ImpressionsService();
  late final CourseBloc _courseBloc;
  late final TabController _tabController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _courseBloc = getIt<CourseBloc>()
      ..add(LoadCourseDetails(courseId: widget.courseId));
    _recordImpression();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _recordImpression() {
    _impressionsService.recordImpression(
      entityType: ImpressionEntityType.course,
      entityId: widget.courseId,
    );
  }

  bool get _isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;

  void _handleSave() {
    if (_isAuthenticated) {
      setState(() => _isSaved = !_isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'تم حفظ الدورة' : 'تم إزالة الحفظ'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'save');
    }
  }

  void _handleShare(CourseEntity course) {
    Share.share(
      'تعلم معي في دورة "${course.title}" على تماد هب\nhttps://tamadhub.com/courses/${widget.courseId}',
      subject: course.title,
    );
  }

  void _handleEnroll(CourseEntity course, bool isEnrolled) {
    if (isEnrolled) {
      _goToLearning(course);
    } else if (_isAuthenticated) {
      if (course.isFree || course.price == 0) {
        _courseBloc.add(EnrollInCourse(courseId: widget.courseId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الدفع غير متاح حالياً. جميع الدورات مجانية.'),
          ),
        );
      }
    } else {
      LoginRequiredDialog.showForAction(context, 'enroll');
    }
  }

  void _goToLearning(CourseEntity course) {
    if (course.sections.isNotEmpty &&
        course.sections.first.lessons.isNotEmpty) {
      final firstLesson = course.sections.first.lessons.first;
      context.push(
        '${RouteNames.courses}/${widget.courseId}/lesson/${firstLesson.id}',
      );
    } else {
      context.push(RouteNames.myLearning);
    }
  }

  void _handleViewInstructor(CourseEntity course) {
    if (course.instructor != null) {
      context.push('/user/${course.instructor!.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _courseBloc,
      child: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is EnrollmentSuccessful) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم التسجيل في الدورة بنجاح!')),
            );
            _courseBloc.add(LoadCourseDetails(courseId: widget.courseId));
          }
          if (state is CourseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Scaffold(body: GlassLoading());
          }

          if (state is CourseError) {
            return Scaffold(
              appBar: AppBar(),
              body: EmptyState(
                icon: Iconsax.warning_2,
                title: 'حدث خطأ',
                message: state.message,
                actionLabel: 'إعادة المحاولة',
                onAction: () => _courseBloc
                    .add(LoadCourseDetails(courseId: widget.courseId)),
              ),
            );
          }

          if (state is CourseDetailsLoaded) {
            return _buildContent(context, state.course, state.isEnrolled,
                state.enrollment?.progressPercent ?? 0);
          }

          return const Scaffold(body: GlassLoading());
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CourseEntity course,
    bool isEnrolled,
    int progress,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Iconsax.arrow_right_1, color: AppColors.white),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSaved ? Iconsax.bookmark5 : Iconsax.bookmark,
                    color: AppColors.white,
                  ),
                ),
                onPressed: _handleSave,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.share, color: AppColors.white),
                ),
                onPressed: () => _handleShare(course),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (course.thumbnailUrl != null)
                    Image.network(
                      course.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultThumbnail(),
                    )
                  else
                    _buildDefaultThumbnail(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Category & Level badges
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        if (course.category != null)
                          _buildBadge(course.category!, AppColors.white),
                        const SizedBox(width: 8),
                        _buildBadge(course.level.label, AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),

                  // Stats row
                  Row(
                    children: [
                      if (course.ratingAverage > 0) ...[
                        const Icon(Iconsax.star1,
                            size: 18, color: AppColors.warning),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        Text(
                          course.ratingAverage.toStringAsFixed(1),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        Text(
                          '(${course.ratingCount} تقييم)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                      ],
                      const Icon(Iconsax.people,
                          size: 18, color: AppColors.textSecondaryLight),
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      Text(
                        '${course.enrollmentCount} طالب',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),

                  // Instructor Card
                  if (course.instructor != null)
                    _InstructorCard(
                      instructor: course.instructor!,
                      onViewProfile: () => _handleViewInstructor(course),
                    ),
                  const SizedBox(height: AppConstants.spacingMedium),

                  // Stats Cards
                  _CourseStats(course: course),
                  const SizedBox(height: AppConstants.spacingMedium),

                  // Progress (if enrolled)
                  if (isEnrolled) ...[
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'تقدمك في الدورة',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$progress%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingSmall),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: AppColors.primaryLightest,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                  ],

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'عن الدورة'),
                      Tab(text: 'المحتوى'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AboutTab(course: course),
                _CurriculumTab(
                  course: course,
                  isEnrolled: isEnrolled,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet:
          _EnrollBottomSheet(course: course, isEnrolled: isEnrolled, onEnroll: () => _handleEnroll(course, isEnrolled)),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
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
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard({
    required this.instructor,
    required this.onViewProfile,
  });

  final InstructorInfo instructor;
  final VoidCallback onViewProfile;

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
            backgroundImage: instructor.avatarUrl != null
                ? NetworkImage(instructor.avatarUrl!)
                : null,
            child: instructor.avatarUrl == null
                ? Text(
                    instructor.fullName.isNotEmpty
                        ? instructor.fullName[0]
                        : 'م',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        instructor.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (instructor.isVerified) ...[
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      const VerifiedBadge(
                        size: VerifiedBadgeSize.small,
                        type: VerifiedBadgeType.instructor,
                      ),
                    ],
                  ],
                ),
                if (instructor.headline != null)
                  Text(
                    instructor.headline!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onViewProfile,
            child: const Text('عرض الملف'),
          ),
        ],
      ),
    );
  }
}

class _CourseStats extends StatelessWidget {
  const _CourseStats({required this.course});

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Iconsax.clock,
            value: course.formattedDuration,
            label: 'المدة',
          ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Expanded(
          child: _StatCard(
            icon: Iconsax.video_play,
            value: '${course.lessonCount}',
            label: 'درس',
          ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Expanded(
          child: _StatCard(
            icon: Iconsax.medal_star,
            value: 'شهادة',
            label: course.hasCertificate ? 'معتمدة' : 'غير متاح',
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

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.course});

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          GlassPanel(
            title: 'عن هذه الدورة',
            intensity: GlassIntensity.light,
            child: Text(
              course.description ?? 'لا يوجد وصف متاح لهذه الدورة.',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // What you'll learn
          if (course.objectives != null && course.objectives!.isNotEmpty) ...[
            GlassPanel(
              title: 'ماذا ستتعلم',
              intensity: GlassIntensity.light,
              child: Column(
                children: course.objectives!
                    .map((objective) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.spacingSmall),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Iconsax.tick_circle,
                                  size: 18, color: AppColors.success),
                              const SizedBox(
                                  width: AppConstants.spacingSmall),
                              Expanded(
                                child: Text(
                                  objective,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
          ],

          // Requirements
          if (course.requirements != null &&
              course.requirements!.isNotEmpty) ...[
            GlassPanel(
              title: 'المتطلبات',
              intensity: GlassIntensity.light,
              child: Column(
                children: course.requirements!
                    .map((requirement) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.spacingSmall),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Iconsax.warning_2,
                                  size: 18, color: AppColors.warning),
                              const SizedBox(
                                  width: AppConstants.spacingSmall),
                              Expanded(
                                child: Text(
                                  requirement,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
          ],

          // Tags
          if (course.tags != null && course.tags!.isNotEmpty) ...[
            GlassPanel(
              title: 'الوسوم',
              intensity: GlassIntensity.light,
              child: Wrap(
                spacing: AppConstants.spacingSmall,
                runSpacing: AppConstants.spacingSmall,
                children: course.tags!
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primaryLightest,
                        ))
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _CurriculumTab extends StatelessWidget {
  const _CurriculumTab({
    required this.course,
    required this.isEnrolled,
  });

  final CourseEntity course;
  final bool isEnrolled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (course.sections.isEmpty) {
      return const EmptyState(
        icon: Iconsax.book_1,
        title: 'لا يوجد محتوى',
        message: 'لم تتم إضافة محتوى لهذه الدورة بعد.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        children: [
          // Summary
          GlassCard(
            intensity: GlassIntensity.light,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  theme,
                  '${course.sections.length}',
                  'أقسام',
                ),
                _buildStat(
                  theme,
                  '${course.lessonCount}',
                  'دروس',
                ),
                _buildStat(
                  theme,
                  course.formattedDuration,
                  'إجمالي',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Sections
          ...course.sections.map((section) => _SectionItem(
                section: section,
                courseId: course.id,
                isEnrolled: isEnrolled,
              )),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _SectionItem extends StatelessWidget {
  const _SectionItem({
    required this.section,
    required this.courseId,
    required this.isEnrolled,
  });

  final CourseSectionEntity section;
  final String courseId;
  final bool isEnrolled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(
          section.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${section.lessons.length} دروس',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        children: section.lessons
            .map((lesson) => _LessonItem(
                  lesson: lesson,
                  courseId: courseId,
                  isEnrolled: isEnrolled,
                ))
            .toList(),
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  const _LessonItem({
    required this.lesson,
    required this.courseId,
    required this.isEnrolled,
  });

  final LessonEntity lesson;
  final String courseId;
  final bool isEnrolled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLocked = !isEnrolled && !lesson.isFreePreview;
    final bool hasQuiz = lesson.hasQuiz;

    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: lesson.isCompleted
            ? AppColors.success
            : isLocked
                ? AppColors.textTertiaryLight
                : AppColors.primaryLightest,
        child: Icon(
          lesson.isCompleted
              ? Iconsax.tick_circle
              : isLocked
                  ? Iconsax.lock
                  : Iconsax.play,
          size: 14,
          color: lesson.isCompleted || isLocked
              ? AppColors.white
              : AppColors.primary,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              lesson.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isLocked ? AppColors.textTertiaryLight : null,
              ),
            ),
          ),
          if (hasQuiz)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Text(
                'اختبار',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (lesson.isFreePreview && !isEnrolled) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Text(
                'مجاني',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        lesson.formattedDuration,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiaryLight,
        ),
      ),
      trailing: isLocked
          ? const Icon(Iconsax.lock, size: 16, color: AppColors.textTertiaryLight)
          : null,
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('يجب التسجيل في الدورة لمشاهدة هذا الدرس'),
                ),
              );
            }
          : () => context.push(
                '${RouteNames.courses}/$courseId/lesson/${lesson.id}',
              ),
    );
  }
}

class _EnrollBottomSheet extends StatelessWidget {
  const _EnrollBottomSheet({
    required this.course,
    required this.isEnrolled,
    required this.onEnroll,
  });

  final CourseEntity course;
  final bool isEnrolled;
  final VoidCallback onEnroll;

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
                  course.formattedPrice,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'وصول مدى الحياة',
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
                child: ElevatedButton.icon(
                  onPressed: onEnroll,
                  icon: Icon(isEnrolled ? Iconsax.play : Iconsax.teacher),
                  label: Text(isEnrolled ? 'متابعة التعلم' : 'سجل الآن'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
