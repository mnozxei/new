import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/quiz_entity.dart';
import '../bloc/student_bloc.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    this.quizId,
    required this.courseId,
    this.isFinalQuiz = false,
  });

  final String? quizId;
  final String courseId;
  final bool isFinalQuiz;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizEntity? _quiz;
  QuizAttemptEntity? _attempt;
  int _currentQuestionIndex = 0;
  final Map<String, List<String>> _answers = {};
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // For final quiz, the quiz is loaded via LoadFinalQuiz event from the router
    // For lesson quizzes, we use the quizId
    if (widget.quizId != null && !widget.isFinalQuiz) {
      context.read<StudentBloc>().add(StartQuiz(widget.quizId!));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int minutes) {
    _remainingSeconds = minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _submitQuiz();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(String questionId, String answerId) {
    final question = _quiz!.questions.firstWhere((q) => q.id == questionId);

    setState(() {
      if (question.questionType == QuestionType.multiple) {
        // Multiple choice - toggle selection
        final currentAnswers = _answers[questionId] ?? [];
        if (currentAnswers.contains(answerId)) {
          currentAnswers.remove(answerId);
        } else {
          currentAnswers.add(answerId);
        }
        _answers[questionId] = currentAnswers;
      } else {
        // Single choice
        _answers[questionId] = [answerId];
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  void _goToQuestion(int index) {
    setState(() => _currentQuestionIndex = index);
  }

  void _submitQuiz() {
    if (_attempt == null) return;

    // Convert answers to submission format
    final formattedAnswers = <String, dynamic>{};
    for (final entry in _answers.entries) {
      if (entry.value.length == 1) {
        formattedAnswers[entry.key] = entry.value.first;
      } else {
        formattedAnswers[entry.key] = entry.value;
      }
    }

    setState(() => _isSubmitting = true);
    context.read<StudentBloc>().add(SubmitQuiz(
          attemptId: _attempt!.id,
          answers: formattedAnswers,
        ));
  }

  void _showSubmitConfirmation() {
    final unansweredCount = _quiz!.questions.length - _answers.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التسليم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unansweredCount > 0)
              Text(
                'لديك $unansweredCount سؤال بدون إجابة.',
                style: const TextStyle(color: AppColors.warning),
              ),
            const SizedBox(height: AppConstants.spacingSmall),
            const Text('هل أنت متأكد من تسليم الاختبار؟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _submitQuiz();
            },
            child: const Text('تسليم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is QuizStarted) {
          setState(() {
            _quiz = state.quiz;
            _attempt = state.attempt;
          });
          if (state.quiz.timeLimitMinutes != null) {
            _startTimer(state.quiz.timeLimitMinutes!);
          }
        } else if (state is FinalQuizLoaded) {
          // Start the final quiz attempt
          context.read<StudentBloc>().add(StartQuiz(state.quiz.id));
        } else if (state is QuizCompleted) {
          setState(() => _isSubmitting = false);
          _showResultDialog(state.result);
        } else if (state is StudentError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: GlassAppBar(
          title: _quiz?.title ?? 'الاختبار',
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_1),
            onPressed: () => _showExitConfirmation(),
          ),
          actions: [
            if (_quiz?.timeLimitMinutes != null && _remainingSeconds > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMedium,
                  vertical: AppConstants.spacingSmall,
                ),
                margin: const EdgeInsets.only(left: AppConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: _remainingSeconds < 60
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.timer_1,
                      size: 18,
                      color: _remainingSeconds < 60
                          ? AppColors.error
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formattedTime,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _remainingSeconds < 60
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_quiz == null || _quiz!.questions.isEmpty) {
              return const Center(
                child: Text('لا توجد أسئلة في هذا الاختبار'),
              );
            }

            final currentQuestion = _quiz!.questions[_currentQuestionIndex];
            final selectedAnswers = _answers[currentQuestion.id] ?? [];

            return Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _quiz!.questions.length,
                  backgroundColor: AppColors.primaryExtraLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number and navigation dots
                        Row(
                          children: [
                            Text(
                              'السؤال ${_currentQuestionIndex + 1} من ${_quiz!.questions.length}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const Spacer(),
                            if (currentQuestion.points > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                ),
                                child: Text(
                                  '${currentQuestion.points} نقاط',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.spacingMedium),

                        // Question dots for navigation
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(_quiz!.questions.length, (index) {
                            final isAnswered = _answers.containsKey(_quiz!.questions[index].id);
                            final isCurrent = index == _currentQuestionIndex;
                            return InkWell(
                              onTap: () => _goToQuestion(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.primary
                                      : isAnswered
                                          ? AppColors.success.withValues(alpha: 0.2)
                                          : AppColors.primaryExtraLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCurrent
                                        ? AppColors.primary
                                        : isAnswered
                                            ? AppColors.success
                                            : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent
                                          ? Colors.white
                                          : isAnswered
                                              ? AppColors.success
                                              : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: AppConstants.spacingLarge),

                        // Question text
                        GlassCard(
                          intensity: GlassIntensity.light,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentQuestion.questionText,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                              if (currentQuestion.questionImageUrl != null) ...[
                                const SizedBox(height: AppConstants.spacingMedium),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                  child: Image.network(
                                    currentQuestion.questionImageUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                              if (currentQuestion.questionType == QuestionType.multiple) ...[
                                const SizedBox(height: AppConstants.spacingSmall),
                                Text(
                                  'يمكنك اختيار أكثر من إجابة',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.info,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.spacingMedium),

                        // Answers
                        ...currentQuestion.answers.map((answer) {
                          final isSelected = selectedAnswers.contains(answer.id);
                          return InkWell(
                            onTap: () => _selectAnswer(currentQuestion.id, answer.id),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppConstants.spacingMedium),
                              margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.primaryExtraLight,
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      shape: currentQuestion.questionType == QuestionType.multiple
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      borderRadius: currentQuestion.questionType == QuestionType.multiple
                                          ? BorderRadius.circular(4)
                                          : null,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondaryLight,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Iconsax.tick_circle,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppConstants.spacingMedium),
                                  Expanded(
                                    child: Text(
                                      answer.answerText,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: isSelected ? FontWeight.w600 : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _previousQuestion,
                            icon: const Icon(Iconsax.arrow_right_3),
                            label: const Text('السابق'),
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Expanded(
                        child: _currentQuestionIndex < _quiz!.questions.length - 1
                            ? FilledButton.icon(
                                onPressed: _nextQuestion,
                                icon: const Icon(Iconsax.arrow_left_3),
                                label: const Text('التالي'),
                              )
                            : FilledButton(
                                onPressed: _isSubmitting ? null : _showSubmitConfirmation,
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('تسليم الاختبار'),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الخروج من الاختبار'),
        content: const Text(
          'هل أنت متأكد من الخروج؟ سيتم فقدان تقدمك في الاختبار.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(QuizAttemptEntity result) {
    _timer?.cancel();

    final isFinalQuiz = widget.isFinalQuiz;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              decoration: BoxDecoration(
                color: result.passed
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.passed ? Iconsax.medal_star : Iconsax.close_circle,
                size: 64,
                color: result.passed ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              result.passed
                  ? isFinalQuiz
                      ? 'مبروك! أكملت الدورة بنجاح'
                      : 'أحسنت! نجحت في الاختبار'
                  : 'للأسف، لم تجتز الاختبار',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    '${result.score.toInt()}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: result.passed ? AppColors.success : AppColors.error,
                        ),
                  ),
                  Text(
                    'درجتك',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'درجة النجاح: ${_quiz?.passingScore ?? 70}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            if (isFinalQuiz && result.passed) ...[
              const SizedBox(height: AppConstants.spacingMedium),
              const Text(
                'يمكنك الآن الحصول على شهادتك',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (isFinalQuiz && result.passed) {
                  // Navigate to certificate page
                  context.go('/courses/${widget.courseId}/certificate');
                } else {
                  context.pop();
                }
              },
              child: Text(
                isFinalQuiz && result.passed
                    ? 'عرض الشهادة'
                    : result.passed
                        ? 'متابعة'
                        : 'إعادة المحاولة',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
