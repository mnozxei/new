import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/entities/instructor_entity.dart';
import '../../domain/repositories/course_repository.dart';

part 'instructor_event.dart';
part 'instructor_state.dart';

class InstructorBloc extends Bloc<InstructorEvent, InstructorState> {
  InstructorBloc({required CourseRepository repository})
      : _repository = repository,
        super(const InstructorInitial()) {
    on<LoadInstructorDashboard>(_onLoadDashboard);
    on<LoadMyCourses>(_onLoadMyCourses);
    on<CreateCourse>(_onCreateCourse);
    on<UpdateCourse>(_onUpdateCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<ToggleCoursePublish>(_onToggleCoursePublish);
    on<LoadCourseStats>(_onLoadCourseStats);
    on<LoadInstructorStats>(_onLoadInstructorStats);
    on<UploadCourseThumbnail>(_onUploadThumbnail);
    on<CreateSection>(_onCreateSection);
    on<UpdateSection>(_onUpdateSection);
    on<DeleteSection>(_onDeleteSection);
    on<ReorderSections>(_onReorderSections);
    on<CreateLesson>(_onCreateLesson);
    on<UpdateLesson>(_onUpdateLesson);
    on<DeleteLesson>(_onDeleteLesson);
    on<ReorderLessons>(_onReorderLessons);
  }

  final CourseRepository _repository;

  Future<void> _onLoadDashboard(
    LoadInstructorDashboard event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const InstructorLoading());
    try {
      final courses = await _repository.getMyCourses();
      final stats = await _repository.getInstructorStats();
      emit(InstructorDashboardLoaded(
        courses: courses,
        stats: stats,
      ));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onLoadMyCourses(
    LoadMyCourses event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const InstructorLoading());
    try {
      final courses = await _repository.getMyCourses();
      emit(MyCoursesLoaded(courses));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onCreateCourse(
    CreateCourse event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final course = await _repository.createCourse(event.params);
      emit(CourseCreated(course));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onUpdateCourse(
    UpdateCourse event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final course = await _repository.updateCourse(event.courseId, event.params);
      emit(CourseUpdated(course));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onDeleteCourse(
    DeleteCourse event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      await _repository.deleteCourse(event.courseId);
      emit(CourseDeleted(event.courseId));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onToggleCoursePublish(
    ToggleCoursePublish event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final course = await _repository.togglePublish(event.courseId);
      emit(CoursePublishToggled(course));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onLoadCourseStats(
    LoadCourseStats event,
    Emitter<InstructorState> emit,
  ) async {
    try {
      final stats = await _repository.getCourseStats(event.courseId);
      emit(CourseStatsLoaded(event.courseId, stats));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onLoadInstructorStats(
    LoadInstructorStats event,
    Emitter<InstructorState> emit,
  ) async {
    try {
      final stats = await _repository.getInstructorStats();
      emit(InstructorStatsLoaded(stats));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onUploadThumbnail(
    UploadCourseThumbnail event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final thumbnailUrl = await _repository.uploadThumbnail(
        event.courseId,
        event.file,
      );
      emit(ThumbnailUploaded(
        courseId: event.courseId,
        thumbnailUrl: thumbnailUrl,
      ));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onCreateSection(
    CreateSection event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final section = await _repository.createSection(event.params);
      emit(SectionCreated(section));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onUpdateSection(
    UpdateSection event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final section = await _repository.updateSection(
        event.sectionId,
        event.params,
      );
      emit(SectionUpdated(section));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onDeleteSection(
    DeleteSection event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      await _repository.deleteSection(event.sectionId);
      emit(SectionDeleted(event.sectionId));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onReorderSections(
    ReorderSections event,
    Emitter<InstructorState> emit,
  ) async {
    try {
      await _repository.reorderSections(event.courseId, event.sectionIds);
      emit(SectionsReordered(event.courseId));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onCreateLesson(
    CreateLesson event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final lesson = await _repository.createLesson(event.params);
      emit(LessonCreated(lesson));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onUpdateLesson(
    UpdateLesson event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      final lesson = await _repository.updateLesson(
        event.lessonId,
        event.params,
      );
      emit(LessonUpdated(lesson));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onDeleteLesson(
    DeleteLesson event,
    Emitter<InstructorState> emit,
  ) async {
    emit(const CourseOperationLoading());
    try {
      await _repository.deleteLesson(event.lessonId);
      emit(LessonDeleted(event.lessonId));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onReorderLessons(
    ReorderLessons event,
    Emitter<InstructorState> emit,
  ) async {
    try {
      await _repository.reorderLessons(event.sectionId, event.lessonIds);
      emit(LessonsReordered(event.sectionId));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }
}
