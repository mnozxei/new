part of 'instructor_bloc.dart';

abstract class InstructorState extends Equatable {
  const InstructorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class InstructorInitial extends InstructorState {
  const InstructorInitial();
}

/// Loading state for dashboard/courses
class InstructorLoading extends InstructorState {
  const InstructorLoading();
}

/// Loading state for course operations (CRUD)
class CourseOperationLoading extends InstructorState {
  const CourseOperationLoading();
}

/// Dashboard loaded with courses and stats
class InstructorDashboardLoaded extends InstructorState {
  const InstructorDashboardLoaded({
    required this.courses,
    required this.stats,
  });

  final List<CourseEntity> courses;
  final InstructorStats stats;

  @override
  List<Object?> get props => [courses, stats];
}

/// My courses list loaded
class MyCoursesLoaded extends InstructorState {
  const MyCoursesLoaded(this.courses);

  final List<CourseEntity> courses;

  @override
  List<Object?> get props => [courses];
}

/// Course created successfully
class CourseCreated extends InstructorState {
  const CourseCreated(this.course);

  final CourseEntity course;

  @override
  List<Object?> get props => [course];
}

/// Course updated successfully
class CourseUpdated extends InstructorState {
  const CourseUpdated(this.course);

  final CourseEntity course;

  @override
  List<Object?> get props => [course];
}

/// Course deleted successfully
class CourseDeleted extends InstructorState {
  const CourseDeleted(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Course publish status toggled
class CoursePublishToggled extends InstructorState {
  const CoursePublishToggled(this.course);

  final CourseEntity course;

  @override
  List<Object?> get props => [course];
}

/// Course stats loaded
class CourseStatsLoaded extends InstructorState {
  const CourseStatsLoaded(this.courseId, this.stats);

  final String courseId;
  final CourseStats stats;

  @override
  List<Object?> get props => [courseId, stats];
}

/// Instructor overall stats loaded
class InstructorStatsLoaded extends InstructorState {
  const InstructorStatsLoaded(this.stats);

  final InstructorStats stats;

  @override
  List<Object?> get props => [stats];
}

/// Thumbnail uploaded successfully
class ThumbnailUploaded extends InstructorState {
  const ThumbnailUploaded({
    required this.courseId,
    required this.thumbnailUrl,
  });

  final String courseId;
  final String thumbnailUrl;

  @override
  List<Object?> get props => [courseId, thumbnailUrl];
}

/// Section created successfully
class SectionCreated extends InstructorState {
  const SectionCreated(this.section);

  final CourseSectionEntity section;

  @override
  List<Object?> get props => [section];
}

/// Section updated successfully
class SectionUpdated extends InstructorState {
  const SectionUpdated(this.section);

  final CourseSectionEntity section;

  @override
  List<Object?> get props => [section];
}

/// Section deleted successfully
class SectionDeleted extends InstructorState {
  const SectionDeleted(this.sectionId);

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

/// Sections reordered successfully
class SectionsReordered extends InstructorState {
  const SectionsReordered(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Lesson created successfully
class LessonCreated extends InstructorState {
  const LessonCreated(this.lesson);

  final LessonEntity lesson;

  @override
  List<Object?> get props => [lesson];
}

/// Lesson updated successfully
class LessonUpdated extends InstructorState {
  const LessonUpdated(this.lesson);

  final LessonEntity lesson;

  @override
  List<Object?> get props => [lesson];
}

/// Lesson deleted successfully
class LessonDeleted extends InstructorState {
  const LessonDeleted(this.lessonId);

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

/// Lessons reordered successfully
class LessonsReordered extends InstructorState {
  const LessonsReordered(this.sectionId);

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

// ============================================
// QUIZ STATES
// ============================================

/// Course quizzes loaded
class CourseQuizzesLoaded extends InstructorState {
  const CourseQuizzesLoaded(this.courseId, this.quizzes);

  final String courseId;
  final List<QuizEntity> quizzes;

  @override
  List<Object?> get props => [courseId, quizzes];
}

/// Quiz created successfully
class QuizCreated extends InstructorState {
  const QuizCreated(this.quiz);

  final QuizEntity quiz;

  @override
  List<Object?> get props => [quiz];
}

/// Quiz updated successfully
class QuizUpdated extends InstructorState {
  const QuizUpdated(this.quiz);

  final QuizEntity quiz;

  @override
  List<Object?> get props => [quiz];
}

/// Quiz deleted successfully
class QuizDeleted extends InstructorState {
  const QuizDeleted(this.quizId);

  final String quizId;

  @override
  List<Object?> get props => [quizId];
}

/// Question added successfully
class QuestionAdded extends InstructorState {
  const QuestionAdded(this.question);

  final QuizQuestionEntity question;

  @override
  List<Object?> get props => [question];
}

/// Question updated successfully
class QuestionUpdated extends InstructorState {
  const QuestionUpdated(this.question);

  final QuizQuestionEntity question;

  @override
  List<Object?> get props => [question];
}

/// Question deleted successfully
class QuestionDeleted extends InstructorState {
  const QuestionDeleted(this.questionId);

  final String questionId;

  @override
  List<Object?> get props => [questionId];
}

/// Questions reordered successfully
class QuestionsReordered extends InstructorState {
  const QuestionsReordered(this.quizId);

  final String quizId;

  @override
  List<Object?> get props => [quizId];
}

/// Error state
class InstructorError extends InstructorState {
  const InstructorError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
