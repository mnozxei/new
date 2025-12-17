part of 'course_bloc.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

class CourseCreating extends CourseState {
  const CourseCreating();
}

class EnrollmentProcessing extends CourseState {
  const EnrollmentProcessing();
}

class CourseError extends CourseState {
  const CourseError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class CoursesLoaded extends CourseState {
  const CoursesLoaded({
    required this.courses,
    this.hasMore = false,
  });

  final List<CourseEntity> courses;
  final bool hasMore;

  @override
  List<Object?> get props => [courses, hasMore];
}

class FeaturedCoursesLoaded extends CourseState {
  const FeaturedCoursesLoaded({required this.courses});

  final List<CourseEntity> courses;

  @override
  List<Object?> get props => [courses];
}

class CourseSearchResults extends CourseState {
  const CourseSearchResults({
    required this.query,
    required this.courses,
    this.hasMore = false,
  });

  final String query;
  final List<CourseEntity> courses;
  final bool hasMore;

  @override
  List<Object?> get props => [query, courses, hasMore];
}

class CourseDetailsLoaded extends CourseState {
  const CourseDetailsLoaded({
    required this.course,
    this.enrollment,
    this.isEnrolled = false,
  });

  final CourseEntity course;
  final EnrollmentEntity? enrollment;
  final bool isEnrolled;

  @override
  List<Object?> get props => [course, enrollment, isEnrolled];
}

class CourseCreated extends CourseState {
  const CourseCreated({required this.course});

  final CourseEntity course;

  @override
  List<Object?> get props => [course];
}

class CourseUpdated extends CourseState {
  const CourseUpdated({required this.course});

  final CourseEntity course;

  @override
  List<Object?> get props => [course];
}

class CourseDeleted extends CourseState {
  const CourseDeleted({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class CoursePublished extends CourseState {
  const CoursePublished({required this.course});

  final CourseEntity course;

  @override
  List<Object?> get props => [course];
}

class SectionCreated extends CourseState {
  const SectionCreated({required this.section});

  final CourseSectionEntity section;

  @override
  List<Object?> get props => [section];
}

class SectionUpdated extends CourseState {
  const SectionUpdated({required this.section});

  final CourseSectionEntity section;

  @override
  List<Object?> get props => [section];
}

class SectionDeleted extends CourseState {
  const SectionDeleted({required this.sectionId});

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

class LessonCreated extends CourseState {
  const LessonCreated({required this.lesson});

  final LessonEntity lesson;

  @override
  List<Object?> get props => [lesson];
}

class LessonUpdated extends CourseState {
  const LessonUpdated({required this.lesson});

  final LessonEntity lesson;

  @override
  List<Object?> get props => [lesson];
}

class LessonDeleted extends CourseState {
  const LessonDeleted({required this.lessonId});

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class EnrollmentSuccessful extends CourseState {
  const EnrollmentSuccessful({required this.enrollment});

  final EnrollmentEntity enrollment;

  @override
  List<Object?> get props => [enrollment];
}

class MyEnrollmentsLoaded extends CourseState {
  const MyEnrollmentsLoaded({
    required this.enrollments,
    this.hasMore = false,
  });

  final List<EnrollmentEntity> enrollments;
  final bool hasMore;

  @override
  List<Object?> get props => [enrollments, hasMore];
}

class EnrollmentLoaded extends CourseState {
  const EnrollmentLoaded({required this.enrollment});

  final EnrollmentEntity enrollment;

  @override
  List<Object?> get props => [enrollment];
}

class LessonProgressUpdated extends CourseState {
  const LessonProgressUpdated({
    required this.lessonId,
    required this.completed,
  });

  final String lessonId;
  final bool completed;

  @override
  List<Object?> get props => [lessonId, completed];
}

class CourseStudentsLoaded extends CourseState {
  const CourseStudentsLoaded({
    required this.courseId,
    required this.students,
    this.hasMore = false,
  });

  final String courseId;
  final List<EnrollmentEntity> students;
  final bool hasMore;

  @override
  List<Object?> get props => [courseId, students, hasMore];
}

class InstructorCoursesLoaded extends CourseState {
  const InstructorCoursesLoaded({
    required this.courses,
    this.hasMore = false,
  });

  final List<CourseEntity> courses;
  final bool hasMore;

  @override
  List<Object?> get props => [courses, hasMore];
}

class CourseRated extends CourseState {
  const CourseRated({
    required this.courseId,
    required this.rating,
  });

  final String courseId;
  final int rating;

  @override
  List<Object?> get props => [courseId, rating];
}
