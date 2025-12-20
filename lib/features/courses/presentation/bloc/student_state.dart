part of 'student_bloc.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StudentInitial extends StudentState {
  const StudentInitial();
}

/// General loading state
class StudentLoading extends StudentState {
  const StudentLoading();
}

/// Enrollments loaded
class EnrollmentsLoaded extends StudentState {
  const EnrollmentsLoaded(this.enrollments);

  final List<EnrollmentEntity> enrollments;

  @override
  List<Object?> get props => [enrollments];
}

/// Single enrollment details loaded with course content
class EnrollmentDetailsLoaded extends StudentState {
  const EnrollmentDetailsLoaded({
    required this.enrollment,
    required this.course,
  });

  final EnrollmentEntity enrollment;
  final CourseEntity course;

  @override
  List<Object?> get props => [enrollment, course];
}

/// Enrollment in progress
class EnrollmentLoading extends StudentState {
  const EnrollmentLoading();
}

/// Successfully enrolled
class EnrollmentSuccess extends StudentState {
  const EnrollmentSuccess(this.enrollment);

  final EnrollmentEntity enrollment;

  @override
  List<Object?> get props => [enrollment];
}

/// Lesson marked as complete
class LessonCompleted extends StudentState {
  const LessonCompleted(this.lessonId);

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

/// Lesson progress updated
class LessonProgressUpdated extends StudentState {
  const LessonProgressUpdated(this.progress);

  final LessonProgressEntity progress;

  @override
  List<Object?> get props => [progress];
}

/// Quiz loading
class QuizLoading extends StudentState {
  const QuizLoading();
}

/// Quiz loaded with optional previous attempt
class QuizLoaded extends StudentState {
  const QuizLoaded({
    required this.quiz,
    this.previousAttempt,
  });

  final QuizEntity quiz;
  final QuizAttemptEntity? previousAttempt;

  bool get canRetake =>
      previousAttempt == null ||
      !previousAttempt!.passed ||
      previousAttempt!.attemptNumber < quiz.maxAttempts;

  int get remainingAttempts =>
      quiz.maxAttempts - (previousAttempt?.attemptNumber ?? 0);

  @override
  List<Object?> get props => [quiz, previousAttempt];
}

/// Quiz started - taking quiz
class QuizStarted extends StudentState {
  const QuizStarted({
    required this.quiz,
    required this.attempt,
  });

  final QuizEntity quiz;
  final QuizAttemptEntity attempt;

  @override
  List<Object?> get props => [quiz, attempt];
}

/// Quiz being submitted
class QuizSubmitting extends StudentState {
  const QuizSubmitting();
}

/// Quiz completed with result
class QuizCompleted extends StudentState {
  const QuizCompleted(this.result);

  final QuizAttemptEntity result;

  bool get passed => result.passed;
  double get score => result.score;

  @override
  List<Object?> get props => [result];
}

/// Certificate loading
class CertificateLoading extends StudentState {
  const CertificateLoading();
}

/// Certificate loaded
class CertificateLoaded extends StudentState {
  const CertificateLoaded({
    required this.certificateUrl,
    required this.enrollment,
  });

  final String certificateUrl;
  final EnrollmentEntity enrollment;

  @override
  List<Object?> get props => [certificateUrl, enrollment];
}

/// Lesson loaded with course context
class LessonLoaded extends StudentState {
  const LessonLoaded({
    required this.lesson,
    required this.course,
    this.nextLesson,
    this.previousLesson,
    this.isLocked = false,
  });

  final LessonEntity lesson;
  final CourseEntity course;
  final LessonEntity? nextLesson;
  final LessonEntity? previousLesson;
  final bool isLocked;

  @override
  List<Object?> get props => [lesson, course, nextLesson, previousLesson, isLocked];
}

/// Final quiz loaded
class FinalQuizLoaded extends StudentState {
  const FinalQuizLoaded({
    required this.quiz,
    required this.course,
    this.previousAttempt,
  });

  final QuizEntity quiz;
  final CourseEntity course;
  final QuizAttemptEntity? previousAttempt;

  bool get canTake => previousAttempt == null || !previousAttempt!.passed;

  @override
  List<Object?> get props => [quiz, course, previousAttempt];
}

/// Certificate issued
class CertificateIssued extends StudentState {
  const CertificateIssued({
    required this.certificate,
    required this.pdfUrl,
  });

  final CertificateEntity certificate;
  final String pdfUrl;

  @override
  List<Object?> get props => [certificate, pdfUrl];
}

/// Review being submitted
class ReviewSubmitting extends StudentState {
  const ReviewSubmitting();
}

/// Review submitted successfully
class ReviewSubmitted extends StudentState {
  const ReviewSubmitted(this.review);

  final CourseReviewEntity review;

  @override
  List<Object?> get props => [review];
}

/// Error state
class StudentError extends StudentState {
  const StudentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
