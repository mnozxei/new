import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/certificate_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc({required this.repository}) : super(const CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadMoreCourses>(_onLoadMoreCourses);
    on<LoadFeaturedCourses>(_onLoadFeaturedCourses);
    on<SearchCourses>(_onSearchCourses);
    on<LoadCourseDetails>(_onLoadCourseDetails);
    on<CreateCourse>(_onCreateCourse);
    on<UpdateCourse>(_onUpdateCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<PublishCourse>(_onPublishCourse);
    on<CreateSection>(_onCreateSection);
    on<UpdateSection>(_onUpdateSection);
    on<DeleteSection>(_onDeleteSection);
    on<CreateLesson>(_onCreateLesson);
    on<UpdateLesson>(_onUpdateLesson);
    on<DeleteLesson>(_onDeleteLesson);
    on<EnrollInCourse>(_onEnrollInCourse);
    on<LoadMyEnrollments>(_onLoadMyEnrollments);
    on<LoadEnrollment>(_onLoadEnrollment);
    on<UpdateLessonProgress>(_onUpdateLessonProgress);
    on<LoadInstructorCourses>(_onLoadInstructorCourses);
    on<RateCourse>(_onRateCourse);
  }

  final CourseRepository repository;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());
    _currentOffset = 0;

    try {
      final courses = await repository.getCourses(
        category: event.category,
        level: event.level,
        isFree: event.isFree,
        searchQuery: event.searchQuery,
        limit: _pageSize,
        offset: _currentOffset,
      );
      emit(CoursesLoaded(
        courses: courses,
        hasMore: courses.length >= _pageSize,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreCourses(LoadMoreCourses event, Emitter<CourseState> emit) async {
    final currentState = state;
    if (currentState is! CoursesLoaded || !currentState.hasMore) return;

    _currentOffset += _pageSize;
    try {
      final courses = await repository.getCourses(
        category: event.category,
        level: event.level,
        isFree: event.isFree,
        searchQuery: event.searchQuery,
        limit: _pageSize,
        offset: _currentOffset,
      );
      emit(CoursesLoaded(
        courses: [...currentState.courses, ...courses],
        hasMore: courses.length >= _pageSize,
      ));
    } catch (e) {
      _currentOffset -= _pageSize;
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onLoadFeaturedCourses(LoadFeaturedCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final courses = await repository.getFeaturedCourses(limit: event.limit);
      emit(FeaturedCoursesLoaded(courses: courses));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onSearchCourses(SearchCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final courses = await repository.getCourses(
        searchQuery: event.query,
        limit: _pageSize,
        offset: 0,
      );
      emit(CourseSearchResults(
        query: event.query,
        courses: courses,
        hasMore: courses.length >= _pageSize,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onLoadCourseDetails(LoadCourseDetails event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final course = await repository.getCourseWithContent(event.courseId);
      if (course == null) {
        emit(const CourseError(message: 'Course not found'));
        return;
      }

      EnrollmentEntity? enrollment;
      try {
        enrollment = await repository.getEnrollment(event.courseId);
      } catch (_) {
        // No enrollment found
      }

      emit(CourseDetailsLoaded(
        course: course,
        enrollment: enrollment,
        isEnrolled: enrollment != null,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onCreateCourse(CreateCourse event, Emitter<CourseState> emit) async {
    emit(const CourseCreating());

    try {
      final course = await repository.createCourse(event.params);
      emit(CourseCreated(course: course));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCourse(UpdateCourse event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final course = await repository.updateCourse(event.courseId, event.params);
      emit(CourseUpdated(course: course));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCourse(DeleteCourse event, Emitter<CourseState> emit) async {
    try {
      await repository.deleteCourse(event.courseId);
      emit(CourseDeleted(courseId: event.courseId));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onPublishCourse(PublishCourse event, Emitter<CourseState> emit) async {
    try {
      final course = await repository.togglePublish(event.courseId);
      emit(CoursePublished(course: course));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onCreateSection(CreateSection event, Emitter<CourseState> emit) async {
    try {
      final section = await repository.createSection(event.params);
      emit(SectionCreated(section: section));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSection(UpdateSection event, Emitter<CourseState> emit) async {
    try {
      final section = await repository.updateSection(event.sectionId, event.params);
      emit(SectionUpdated(section: section));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onDeleteSection(DeleteSection event, Emitter<CourseState> emit) async {
    try {
      await repository.deleteSection(event.sectionId);
      emit(SectionDeleted(sectionId: event.sectionId));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onCreateLesson(CreateLesson event, Emitter<CourseState> emit) async {
    try {
      final lesson = await repository.createLesson(event.params);
      emit(LessonCreated(lesson: lesson));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateLesson(UpdateLesson event, Emitter<CourseState> emit) async {
    try {
      final lesson = await repository.updateLesson(event.lessonId, event.params);
      emit(LessonUpdated(lesson: lesson));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onDeleteLesson(DeleteLesson event, Emitter<CourseState> emit) async {
    try {
      await repository.deleteLesson(event.lessonId);
      emit(LessonDeleted(lessonId: event.lessonId));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onEnrollInCourse(EnrollInCourse event, Emitter<CourseState> emit) async {
    emit(const EnrollmentProcessing());

    try {
      final enrollment = await repository.enrollInCourse(event.courseId, paymentId: event.paymentId);
      emit(EnrollmentSuccessful(enrollment: enrollment));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyEnrollments(LoadMyEnrollments event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final enrollments = await repository.getMyEnrollments(
        status: event.status,
        limit: _pageSize,
        offset: 0,
      );
      emit(MyEnrollmentsLoaded(
        enrollments: enrollments,
        hasMore: enrollments.length >= _pageSize,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onLoadEnrollment(LoadEnrollment event, Emitter<CourseState> emit) async {
    try {
      final enrollment = await repository.getEnrollment(event.courseId);
      if (enrollment != null) {
        emit(EnrollmentLoaded(enrollment: enrollment));
      }
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateLessonProgress(UpdateLessonProgress event, Emitter<CourseState> emit) async {
    try {
      await repository.updateLessonProgress(
        event.lessonId,
        watchTimeSeconds: event.watchTimeSeconds,
        lastPositionSeconds: event.lastPositionSeconds,
        isCompleted: event.isCompleted,
      );
      emit(LessonProgressUpdated(
        lessonId: event.lessonId,
        completed: event.isCompleted ?? false,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onLoadInstructorCourses(LoadInstructorCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final courses = await repository.getMyCourses();
      emit(InstructorCoursesLoaded(
        courses: courses,
        hasMore: false,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }

  Future<void> _onRateCourse(RateCourse event, Emitter<CourseState> emit) async {
    try {
      await repository.addReview(AddReviewParams(
        courseId: event.courseId,
        rating: event.rating,
        comment: event.review,
      ));
      emit(CourseRated(
        courseId: event.courseId,
        rating: event.rating,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
    }
  }
}
