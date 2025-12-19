part of 'instructor_bloc.dart';

abstract class InstructorEvent extends Equatable {
  const InstructorEvent();

  @override
  List<Object?> get props => [];
}

/// Load instructor dashboard with courses and stats
class LoadInstructorDashboard extends InstructorEvent {
  const LoadInstructorDashboard();
}

/// Load my courses as instructor
class LoadMyCourses extends InstructorEvent {
  const LoadMyCourses();
}

/// Create a new course
class CreateCourse extends InstructorEvent {
  const CreateCourse(this.params);

  final CreateCourseParams params;

  @override
  List<Object?> get props => [params];
}

/// Update an existing course
class UpdateCourse extends InstructorEvent {
  const UpdateCourse({
    required this.courseId,
    required this.params,
  });

  final String courseId;
  final UpdateCourseParams params;

  @override
  List<Object?> get props => [courseId, params];
}

/// Delete a course
class DeleteCourse extends InstructorEvent {
  const DeleteCourse(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Toggle course publish status
class ToggleCoursePublish extends InstructorEvent {
  const ToggleCoursePublish(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Load stats for a specific course
class LoadCourseStats extends InstructorEvent {
  const LoadCourseStats(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Load instructor overall stats
class LoadInstructorStats extends InstructorEvent {
  const LoadInstructorStats();
}

/// Upload course thumbnail
class UploadCourseThumbnail extends InstructorEvent {
  const UploadCourseThumbnail({
    required this.courseId,
    required this.file,
  });

  final String courseId;
  final dynamic file;

  @override
  List<Object?> get props => [courseId, file];
}

/// Create a new section in course
class CreateSection extends InstructorEvent {
  const CreateSection(this.params);

  final CreateSectionParams params;

  @override
  List<Object?> get props => [params];
}

/// Update a section
class UpdateSection extends InstructorEvent {
  const UpdateSection({
    required this.sectionId,
    required this.params,
  });

  final String sectionId;
  final UpdateSectionParams params;

  @override
  List<Object?> get props => [sectionId, params];
}

/// Delete a section
class DeleteSection extends InstructorEvent {
  const DeleteSection(this.sectionId);

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

/// Reorder sections in a course
class ReorderSections extends InstructorEvent {
  const ReorderSections({
    required this.courseId,
    required this.sectionIds,
  });

  final String courseId;
  final List<String> sectionIds;

  @override
  List<Object?> get props => [courseId, sectionIds];
}

/// Create a new lesson
class CreateLesson extends InstructorEvent {
  const CreateLesson(this.params);

  final CreateLessonParams params;

  @override
  List<Object?> get props => [params];
}

/// Update a lesson
class UpdateLesson extends InstructorEvent {
  const UpdateLesson({
    required this.lessonId,
    required this.params,
  });

  final String lessonId;
  final UpdateLessonParams params;

  @override
  List<Object?> get props => [lessonId, params];
}

/// Delete a lesson
class DeleteLesson extends InstructorEvent {
  const DeleteLesson(this.lessonId);

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

/// Reorder lessons in a section
class ReorderLessons extends InstructorEvent {
  const ReorderLessons({
    required this.sectionId,
    required this.lessonIds,
  });

  final String sectionId;
  final List<String> lessonIds;

  @override
  List<Object?> get props => [sectionId, lessonIds];
}

// ============================================
// QUIZ EVENTS
// ============================================

/// Load quizzes for a course
class LoadCourseQuizzes extends InstructorEvent {
  const LoadCourseQuizzes(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Create a new quiz
class CreateQuiz extends InstructorEvent {
  const CreateQuiz(this.params);

  final CreateQuizParams params;

  @override
  List<Object?> get props => [params];
}

/// Update an existing quiz
class UpdateQuiz extends InstructorEvent {
  const UpdateQuiz({
    required this.quizId,
    required this.params,
  });

  final String quizId;
  final UpdateQuizParams params;

  @override
  List<Object?> get props => [quizId, params];
}

/// Delete a quiz
class DeleteQuiz extends InstructorEvent {
  const DeleteQuiz(this.quizId);

  final String quizId;

  @override
  List<Object?> get props => [quizId];
}

/// Add a question to a quiz
class AddQuestion extends InstructorEvent {
  const AddQuestion(this.params);

  final AddQuestionParams params;

  @override
  List<Object?> get props => [params];
}

/// Update a question
class UpdateQuestion extends InstructorEvent {
  const UpdateQuestion({
    required this.questionId,
    required this.params,
  });

  final String questionId;
  final UpdateQuestionParams params;

  @override
  List<Object?> get props => [questionId, params];
}

/// Delete a question
class DeleteQuestion extends InstructorEvent {
  const DeleteQuestion(this.questionId);

  final String questionId;

  @override
  List<Object?> get props => [questionId];
}

/// Reorder questions in a quiz
class ReorderQuestions extends InstructorEvent {
  const ReorderQuestions({
    required this.quizId,
    required this.questionIds,
  });

  final String quizId;
  final List<String> questionIds;

  @override
  List<Object?> get props => [quizId, questionIds];
}
