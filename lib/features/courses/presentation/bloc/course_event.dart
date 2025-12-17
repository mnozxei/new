part of 'course_bloc.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {
  const LoadCourses({this.category, this.level});

  final String? category;
  final CourseLevel? level;

  @override
  List<Object?> get props => [category, level];
}

class LoadMoreCourses extends CourseEvent {
  const LoadMoreCourses({this.category, this.level});

  final String? category;
  final CourseLevel? level;

  @override
  List<Object?> get props => [category, level];
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
  const CreateCourse({
    required this.title,
    required this.description,
    required this.price,
    this.category,
    this.level,
    this.thumbnailUrl,
  });

  final String title;
  final String description;
  final double price;
  final String? category;
  final CourseLevel? level;
  final String? thumbnailUrl;

  @override
  List<Object?> get props => [title, description, price, category, level, thumbnailUrl];
}

class UpdateCourse extends CourseEvent {
  const UpdateCourse({
    required this.courseId,
    this.title,
    this.description,
    this.price,
    this.category,
    this.level,
    this.thumbnailUrl,
    this.isPublished,
  });

  final String courseId;
  final String? title;
  final String? description;
  final double? price;
  final String? category;
  final CourseLevel? level;
  final String? thumbnailUrl;
  final bool? isPublished;

  @override
  List<Object?> get props => [courseId, title, description, price, category, level, thumbnailUrl, isPublished];
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
  const CreateSection({
    required this.courseId,
    required this.title,
    this.orderIndex,
  });

  final String courseId;
  final String title;
  final int? orderIndex;

  @override
  List<Object?> get props => [courseId, title, orderIndex];
}

class UpdateSection extends CourseEvent {
  const UpdateSection({
    required this.sectionId,
    this.title,
    this.orderIndex,
  });

  final String sectionId;
  final String? title;
  final int? orderIndex;

  @override
  List<Object?> get props => [sectionId, title, orderIndex];
}

class DeleteSection extends CourseEvent {
  const DeleteSection({required this.sectionId});

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}

class CreateLesson extends CourseEvent {
  const CreateLesson({
    required this.sectionId,
    required this.title,
    required this.type,
    this.content,
    this.videoUrl,
    this.durationMinutes,
    this.orderIndex,
  });

  final String sectionId;
  final String title;
  final LessonType type;
  final String? content;
  final String? videoUrl;
  final int? durationMinutes;
  final int? orderIndex;

  @override
  List<Object?> get props => [sectionId, title, type, content, videoUrl, durationMinutes, orderIndex];
}

class UpdateLesson extends CourseEvent {
  const UpdateLesson({
    required this.lessonId,
    this.title,
    this.type,
    this.content,
    this.videoUrl,
    this.durationMinutes,
    this.orderIndex,
  });

  final String lessonId;
  final String? title;
  final LessonType? type;
  final String? content;
  final String? videoUrl;
  final int? durationMinutes;
  final int? orderIndex;

  @override
  List<Object?> get props => [lessonId, title, type, content, videoUrl, durationMinutes, orderIndex];
}

class DeleteLesson extends CourseEvent {
  const DeleteLesson({required this.lessonId});

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class EnrollInCourse extends CourseEvent {
  const EnrollInCourse({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class LoadMyEnrollments extends CourseEvent {
  const LoadMyEnrollments();
}

class LoadEnrollment extends CourseEvent {
  const LoadEnrollment({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class UpdateLessonProgress extends CourseEvent {
  const UpdateLessonProgress({
    required this.enrollmentId,
    required this.lessonId,
    this.completed = true,
  });

  final String enrollmentId;
  final String lessonId;
  final bool completed;

  @override
  List<Object?> get props => [enrollmentId, lessonId, completed];
}

class LoadCourseStudents extends CourseEvent {
  const LoadCourseStudents({required this.courseId});

  final String courseId;

  @override
  List<Object?> get props => [courseId];
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
