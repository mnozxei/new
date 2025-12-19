part of 'student_bloc.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

/// Load my enrolled courses
class LoadMyEnrollments extends StudentEvent {
  const LoadMyEnrollments({
    this.status,
    this.limit = 20,
    this.offset = 0,
  });

  final EnrollmentStatus? status;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [status, limit, offset];
}

/// Load details for a specific enrollment
class LoadEnrollmentDetails extends StudentEvent {
  const LoadEnrollmentDetails(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Enroll in a course
class EnrollInCourse extends StudentEvent {
  const EnrollInCourse({
    required this.courseId,
    this.paymentId,
  });

  final String courseId;
  final String? paymentId;

  @override
  List<Object?> get props => [courseId, paymentId];
}

/// Mark a lesson as complete
class MarkLessonComplete extends StudentEvent {
  const MarkLessonComplete(this.lessonId);

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

/// Update lesson progress (watch time, position)
class UpdateLessonProgress extends StudentEvent {
  const UpdateLessonProgress({
    required this.lessonId,
    this.watchTimeSeconds,
    this.lastPositionSeconds,
    this.isCompleted,
  });

  final String lessonId;
  final int? watchTimeSeconds;
  final int? lastPositionSeconds;
  final bool? isCompleted;

  @override
  List<Object?> get props => [
        lessonId,
        watchTimeSeconds,
        lastPositionSeconds,
        isCompleted,
      ];
}

/// Start a quiz attempt
class StartQuiz extends StudentEvent {
  const StartQuiz(this.quizId);

  final String quizId;

  @override
  List<Object?> get props => [quizId];
}

/// Submit an answer to a question
class SubmitQuizAnswer extends StudentEvent {
  const SubmitQuizAnswer({
    required this.questionId,
    required this.answerId,
  });

  final String questionId;
  final String answerId;

  @override
  List<Object?> get props => [questionId, answerId];
}

/// Submit the entire quiz
class SubmitQuiz extends StudentEvent {
  const SubmitQuiz({
    required this.attemptId,
    required this.answers,
  });

  final String attemptId;
  final Map<String, dynamic> answers;

  @override
  List<Object?> get props => [attemptId, answers];
}

/// Load quiz details and previous attempts
class LoadQuiz extends StudentEvent {
  const LoadQuiz(this.quizId);

  final String quizId;

  @override
  List<Object?> get props => [quizId];
}

/// Load certificate for a completed course
class LoadCertificate extends StudentEvent {
  const LoadCertificate(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Add a review for a course
class AddCourseReview extends StudentEvent {
  const AddCourseReview({
    required this.courseId,
    required this.rating,
    this.comment,
  });

  final String courseId;
  final int rating;
  final String? comment;

  @override
  List<Object?> get props => [courseId, rating, comment];
}
