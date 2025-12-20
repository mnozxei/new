import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../config/injection/injection.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/youtube_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/student_bloc.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final StudentBloc _studentBloc;
  YoutubePlayerController? _youtubeController;
  bool _isBookmarked = false;
  bool _isVideoReady = false;
  LessonEntity? _lesson;
  CourseEntity? _course;
  LessonEntity? _nextLesson;
  LessonEntity? _previousLesson;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _studentBloc = getIt<StudentBloc>()
      ..add(LoadLesson(
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      ));
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  void _initializeYouTubePlayer(String youtubeUrl) {
    final videoId = YouTubeHelper.extractVideoId(youtubeUrl);
    if (videoId != null && _youtubeController == null) {
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: true,
          showVideoAnnotations: false,
          playsInline: true,
        ),
      );
      _youtubeController!.setFullScreenListener((isFullScreen) {
        // Handle fullscreen
      });
      setState(() => _isVideoReady = true);
    }
  }

  bool get _isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;

  void _handleBookmark() {
    if (_isAuthenticated) {
      setState(() => _isBookmarked = !_isBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'تم حفظ الدرس' : 'تم إزالة الحفظ'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'save');
    }
  }

  void _handlePreviousLesson() {
    if (_previousLesson != null) {
      context.pushReplacement(
        '${RouteNames.courses}/${widget.courseId}/lesson/${_previousLesson!.id}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذا هو الدرس الأول')),
      );
    }
  }

  void _handleNextLesson() {
    if (_lesson?.hasQuiz == true && !(_lesson?.quizPassed ?? false)) {
      _handleStartQuiz();
      return;
    }

    if (_nextLesson != null) {
      if (_nextLesson!.isUnlocked) {
        context.pushReplacement(
          '${RouteNames.courses}/${widget.courseId}/lesson/${_nextLesson!.id}',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب اجتياز اختبار الدرس الحالي لفتح الدرس التالي'),
          ),
        );
      }
    } else {
      _showCourseCompleteDialog();
    }
  }

  void _handleCompleteLesson() {
    if (!_isAuthenticated) {
      LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول لإكمال الدروس');
      return;
    }

    _studentBloc.add(CompleteLesson(
      courseId: widget.courseId,
      lessonId: widget.lessonId,
    ));
  }

  void _handleStartQuiz() {
    if (!_isAuthenticated) {
      LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول لبدء الاختبار');
      return;
    }

    if (_lesson?.quizId != null) {
      context.push(
        '${RouteNames.courses}/${widget.courseId}/quiz/${_lesson!.quizId}',
      );
    }
  }

  void _showCourseCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أحسنت!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.medal_star,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            const Text(
              'لقد أكملت جميع دروس الدورة!',
              textAlign: TextAlign.center,
            ),
            if (_course?.hasFinalQuiz == true) ...[
              const SizedBox(height: AppConstants.spacingSmall),
              const Text(
                'أكمل الاختبار النهائي للحصول على الشهادة',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (_course?.hasFinalQuiz == true)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(
                  '${RouteNames.courses}/${widget.courseId}/final-quiz',
                );
              },
              child: const Text('الاختبار النهائي'),
            )
          else
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(
                  '${RouteNames.courses}/${widget.courseId}/certificate',
                );
              },
              child: const Text('الشهادة'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _studentBloc,
      child: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is LessonLoaded) {
            setState(() {
              _lesson = state.lesson;
              _course = state.course;
              _nextLesson = state.nextLesson;
              _previousLesson = state.previousLesson;
              _isLocked = state.isLocked;
            });
            if (state.lesson.videoUrl != null && !_isLocked) {
              _initializeYouTubePlayer(state.lesson.videoUrl!);
            }
          }
          if (state is LessonCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إكمال الدرس!')),
            );
            if (_lesson?.hasQuiz == true) {
              _handleStartQuiz();
            } else {
              _handleNextLesson();
            }
          }
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Scaffold(body: GlassLoading());
          }

          if (_isLocked) {
            return Scaffold(
              appBar: GlassAppBar(
                title: 'الدرس مقفل',
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_right_1),
                  onPressed: () => context.pop(),
                ),
              ),
              body: EmptyState(
                icon: Iconsax.lock,
                title: 'هذا الدرس مقفل',
                message: 'يجب اجتياز اختبار الدرس السابق لفتح هذا الدرس',
                actionLabel: 'العودة',
                onAction: () => context.pop(),
              ),
            );
          }

          if (_lesson == null) {
            return const Scaffold(body: GlassLoading());
          }

          return _buildContent(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = _lesson!;

    return Scaffold(
      appBar: GlassAppBar(
        title: lesson.title,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Iconsax.bookmark_25 : Iconsax.bookmark),
            onPressed: _handleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player
            if (lesson.videoUrl != null && _isVideoReady) ...[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                ),
              ),
            ] else if (lesson.videoUrl != null) ...[
              Container(
                height: 220,
                color: AppColors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        'جاري تحميل الفيديو...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                height: 220,
                color: AppColors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.video_slash,
                        size: 48,
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        'لا يوجد فيديو لهذا الدرس',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson title and info
                  Text(
                    lesson.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(
                    children: [
                      _LessonTag(
                        icon: Iconsax.clock,
                        label: lesson.formattedDuration,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      _LessonTag(
                        icon: Iconsax.video_play,
                        label: 'فيديو',
                      ),
                      if (lesson.isCompleted) ...[
                        const SizedBox(width: AppConstants.spacingSmall),
                        const _LessonTag(
                          icon: Iconsax.tick_circle,
                          label: 'مكتمل',
                          isSuccess: true,
                        ),
                      ],
                      if (lesson.hasQuiz) ...[
                        const SizedBox(width: AppConstants.spacingSmall),
                        _LessonTag(
                          icon: Iconsax.clipboard_tick,
                          label: lesson.quizPassed ? 'اختبار ناجح' : 'يتطلب اختبار',
                          isWarning: !lesson.quizPassed,
                          isSuccess: lesson.quizPassed,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingMedium),

                  // Description
                  if (lesson.description != null && lesson.description!.isNotEmpty)
                    GlassPanel(
                      title: 'وصف الدرس',
                      intensity: GlassIntensity.light,
                      child: Text(
                        lesson.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                    ),

                  const SizedBox(height: AppConstants.spacingMedium),

                  // Quiz section
                  if (lesson.hasQuiz && !lesson.quizPassed)
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadiusSmall),
                                ),
                                child: const Icon(
                                  Iconsax.clipboard_text,
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'اختبار الدرس مطلوب',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'يجب اجتياز الاختبار للانتقال للدرس التالي',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _handleStartQuiz,
                              icon: const Icon(Iconsax.play),
                              label: const Text('بدء الاختبار'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Curriculum sidebar
                  const SizedBox(height: AppConstants.spacingMedium),
                  if (_course != null)
                    GlassPanel(
                      title: 'محتوى الدورة',
                      intensity: GlassIntensity.light,
                      child: _CourseCurriculumSidebar(
                        course: _course!,
                        currentLessonId: widget.lessonId,
                        onLessonTap: (lessonId, isLocked) {
                          if (isLocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يجب إكمال الدروس السابقة أولاً'),
                              ),
                            );
                          } else {
                            context.pushReplacement(
                              '${RouteNames.courses}/${widget.courseId}/lesson/$lessonId',
                            );
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _NavigationBottomSheet(
        onPrevious: _previousLesson != null ? _handlePreviousLesson : null,
        onNext: _handleNextLesson,
        onComplete: !(_lesson?.isCompleted ?? false) ? _handleCompleteLesson : null,
        isCompleted: _lesson?.isCompleted ?? false,
        hasQuiz: _lesson?.hasQuiz ?? false,
        quizPassed: _lesson?.quizPassed ?? false,
        hasNextLesson: _nextLesson != null,
      ),
    );
  }
}

class _LessonTag extends StatelessWidget {
  const _LessonTag({
    required this.icon,
    required this.label,
    this.isSuccess = false,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final bool isSuccess;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    Color bgColor;

    if (isSuccess) {
      color = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.1);
    } else if (isWarning) {
      color = AppColors.warning;
      bgColor = AppColors.warning.withValues(alpha: 0.1);
    } else {
      color = AppColors.primary;
      bgColor = AppColors.primaryExtraLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCurriculumSidebar extends StatelessWidget {
  const _CourseCurriculumSidebar({
    required this.course,
    required this.currentLessonId,
    required this.onLessonTap,
  });

  final CourseEntity course;
  final String currentLessonId;
  final void Function(String lessonId, bool isLocked) onLessonTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: course.sections.map((section) {
        return ExpansionTile(
          title: Text(
            section.title,
            style: theme.textTheme.titleSmall,
          ),
          initiallyExpanded: section.lessons.any((l) => l.id == currentLessonId),
          children: section.lessons.map((lesson) {
            final isCurrent = lesson.id == currentLessonId;
            final isLocked = !lesson.isUnlocked;

            return ListTile(
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: lesson.isCompleted
                    ? AppColors.success
                    : isCurrent
                        ? AppColors.primary
                        : isLocked
                            ? AppColors.textTertiaryLight
                            : AppColors.primaryLightest,
                child: Icon(
                  lesson.isCompleted
                      ? Iconsax.tick_circle
                      : isLocked
                          ? Iconsax.lock
                          : isCurrent
                              ? Iconsax.play
                              : Iconsax.video_play,
                  size: 14,
                  color: lesson.isCompleted || isCurrent || isLocked
                      ? AppColors.white
                      : AppColors.primary,
                ),
              ),
              title: Text(
                lesson.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : null,
                  color: isLocked ? AppColors.textTertiaryLight : null,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    lesson.formattedDuration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                  if (lesson.hasQuiz) ...[
                    const SizedBox(width: 8),
                    Icon(
                      lesson.quizPassed
                          ? Iconsax.tick_circle
                          : Iconsax.clipboard_text,
                      size: 12,
                      color: lesson.quizPassed
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ],
                ],
              ),
              selected: isCurrent,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
              onTap: isCurrent
                  ? null
                  : () => onLessonTap(lesson.id, isLocked),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _NavigationBottomSheet extends StatelessWidget {
  const _NavigationBottomSheet({
    required this.onPrevious,
    required this.onNext,
    required this.onComplete,
    required this.isCompleted,
    required this.hasQuiz,
    required this.quizPassed,
    required this.hasNextLesson,
  });

  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onComplete;
  final bool isCompleted;
  final bool hasQuiz;
  final bool quizPassed;
  final bool hasNextLesson;

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
            if (onPrevious != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Iconsax.arrow_right_1),
                  label: const Text('السابق'),
                ),
              )
            else
              const Spacer(),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              flex: 2,
              child: _buildMainButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    if (!isCompleted && onComplete != null) {
      return ElevatedButton.icon(
        onPressed: onComplete,
        icon: const Icon(Iconsax.tick_circle),
        label: const Text('إكمال الدرس'),
      );
    }

    if (hasQuiz && !quizPassed) {
      return ElevatedButton.icon(
        onPressed: onNext,
        icon: const Icon(Iconsax.clipboard_text),
        label: const Text('بدء الاختبار'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
        ),
      );
    }

    if (hasNextLesson) {
      return ElevatedButton.icon(
        onPressed: onNext,
        icon: const Icon(Iconsax.arrow_left_2),
        label: const Text('الدرس التالي'),
      );
    }

    return ElevatedButton.icon(
      onPressed: onNext,
      icon: const Icon(Iconsax.medal_star),
      label: const Text('إكمال الدورة'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
      ),
    );
  }
}
