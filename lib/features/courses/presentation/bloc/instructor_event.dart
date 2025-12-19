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
