part of 'course_bloc.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {
  const LoadCourses({this.category, this.level, this.isFree, this.searchQuery});

  final String? category;
  final CourseLevel? level;
  final bool? isFree;
  final String? searchQuery;

  @override
  List<Object?> get props => [category, level, isFree, searchQuery];
}

class LoadMoreCourses extends CourseEvent {
  const LoadMoreCourses({this.category, this.level, this.isFree, this.searchQuery});

  final String? category;
  final CourseLevel? level;
  final bool? isFree;
  final String? searchQuery;

  @override
  List<Object?> get props => [category, level, isFree, searchQuery];
}

class LoadFeaturedCourses extends CourseEvent {
  const LoadFeaturedCourses({this.limit = 10});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class SearchCourses extends CourseEvent {
  const SearchCourses({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class LoadCourseDetails extends CourseEvent {
  const LoadCourseDetails({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class CreateCourse extends CourseEvent {
  const CreateCourse({required this.params});

  final CreateCourseParams params;

  @override
  List<Object?> get props => [params];
}

class UpdateCourse extends CourseEvent {
  const UpdateCourse({required this.courseId, required this.params});

  final String courseId;
  final UpdateCourseParams params;

  @override
  List<Object?> get props => [courseId, params];
}

class DeleteCourse extends CourseEvent {
  const DeleteCourse({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class PublishCourse extends CourseEvent {
  const PublishCourse({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class CreateSection extends CourseEvent {
  const CreateSection({required this.params});

  final CreateSectionParams params;

  @override
  List<Object?> get props => [params];
}

class UpdateSection extends CourseEvent {
  const UpdateSection({required this.sectionId, required this.params});

  final String sectionId;
  final UpdateSectionParams params;

  @override
  List<Object?> get props => [sectionId, params];
}

class DeleteSection extends CourseEvent {
  const DeleteSection({required this.sectionId});

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

class CreateLesson extends CourseEvent {
  const CreateLesson({required this.params});

  final CreateLessonParams params;

  @override
  List<Object?> get props => [params];
}

class UpdateLesson extends CourseEvent {
  const UpdateLesson({required this.lessonId, required this.params});

  final String lessonId;
  final UpdateLessonParams params;

  @override
  List<Object?> get props => [lessonId, params];
}

class DeleteLesson extends CourseEvent {
  const DeleteLesson({required this.lessonId});

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class EnrollInCourse extends CourseEvent {
  const EnrollInCourse({required this.courseId, this.paymentId});

  final String courseId;
  final String? paymentId;

  @override
  List<Object?> get props => [courseId, paymentId];
}

class LoadMyEnrollments extends CourseEvent {
  const LoadMyEnrollments({this.status});

  final EnrollmentStatus? status;

  @override
  List<Object?> get props => [status];
}

class LoadEnrollment extends CourseEvent {
  const LoadEnrollment({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class UpdateLessonProgress extends CourseEvent {
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
  List<Object?> get props => [lessonId, watchTimeSeconds, lastPositionSeconds, isCompleted];
}

class LoadInstructorCourses extends CourseEvent {
  const LoadInstructorCourses();
}

class RateCourse extends CourseEvent {
  const RateCourse({
    required this.courseId,
    required this.rating,
    this.review,
  });

  final String courseId;
  final int rating;
  final String? review;

  @override
  List<Object?> get props => [courseId, rating, review];
}
