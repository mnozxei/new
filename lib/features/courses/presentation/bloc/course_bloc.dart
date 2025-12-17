import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(const CourseInitial()) {
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
    on<LoadCourseStudents>(_onLoadCourseStudents);
    on<LoadInstructorCourses>(_onLoadInstructorCourses);
    on<RateCourse>(_onRateCourse);
  }

  final CourseRepository _courseRepository;
  int _currentPage = 1;
  static const int _pageSize = 20;

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());
    _currentPage = 1;

    final result = await _courseRepository.getCourses(
      page: _currentPage,
      limit: _pageSize,
      category: event.category,
      level: event.level,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (courses) => emit(CoursesLoaded(
        courses: courses,
        hasMore: courses.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadMoreCourses(LoadMoreCourses event, Emitter<CourseState> emit) async {
    final currentState = state;
    if (currentState is! CoursesLoaded || !currentState.hasMore) return;

    _currentPage++;
    final result = await _courseRepository.getCourses(
      page: _currentPage,
      limit: _pageSize,
      category: event.category,
      level: event.level,
    );

    result.fold(
      (failure) {
        _currentPage--;
        emit(CourseError(message: failure.message));
      },
      (courses) => emit(CoursesLoaded(
        courses: [...currentState.courses, ...courses],
        hasMore: courses.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadFeaturedCourses(LoadFeaturedCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    final result = await _courseRepository.getFeaturedCourses(limit: event.limit);

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (courses) => emit(FeaturedCoursesLoaded(courses: courses)),
    );
  }

  Future<void> _onSearchCourses(SearchCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    final result = await _courseRepository.searchCourses(
      query: event.query,
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (courses) => emit(CourseSearchResults(
        query: event.query,
        courses: courses,
        hasMore: courses.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadCourseDetails(LoadCourseDetails event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    final courseResult = await _courseRepository.getCourseById(event.courseId);

    await courseResult.fold(
      (failure) async => emit(CourseError(message: failure.message)),
      (course) async {
        EnrollmentEntity? enrollment;
        final enrollmentResult = await _courseRepository.getEnrollment(event.courseId);
        enrollmentResult.fold(
          (_) => null,
          (e) => enrollment = e,
        );

        emit(CourseDetailsLoaded(
          course: course,
          enrollment: enrollment,
          isEnrolled: enrollment != null,
        ));
      },
    );
  }

  Future<void> _onCreateCourse(CreateCourse event, Emitter<CourseState> emit) async {
    emit(const CourseCreating());

    final result = await _courseRepository.createCourse(
      title: event.title,
      description: event.description,
      price: event.price,
      category: event.category,
      level: event.level,
      thumbnailUrl: event.thumbnailUrl,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (course) => emit(CourseCreated(course: course)),
    );
  }

  Future<void> _onUpdateCourse(UpdateCourse event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    final result = await _courseRepository.updateCourse(
      courseId: event.courseId,
      title: event.title,
      description: event.description,
      price: event.price,
      category: event.category,
      level: event.level,
      thumbnailUrl: event.thumbnailUrl,
      isPublished: event.isPublished,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (course) => emit(CourseUpdated(course: course)),
    );
  }

  Future<void> _onDeleteCourse(DeleteCourse event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.deleteCourse(event.courseId);

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (_) => emit(CourseDeleted(courseId: event.courseId)),
    );
  }

  Future<void> _onPublishCourse(PublishCourse event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.updateCourse(
      courseId: event.courseId,
      isPublished: true,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (course) => emit(CoursePublished(course: course)),
    );
  }

  Future<void> _onCreateSection(CreateSection event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.createSection(
      courseId: event.courseId,
      title: event.title,
      orderIndex: event.orderIndex,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (section) => emit(SectionCreated(section: section)),
    );
  }

  Future<void> _onUpdateSection(UpdateSection event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.updateSection(
      sectionId: event.sectionId,
      title: event.title,
      orderIndex: event.orderIndex,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (section) => emit(SectionUpdated(section: section)),
    );
  }

  Future<void> _onDeleteSection(DeleteSection event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.deleteSection(event.sectionId);

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (_) => emit(SectionDeleted(sectionId: event.sectionId)),
    );
  }

  Future<void> _onCreateLesson(CreateLesson event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.createLesson(
      sectionId: event.sectionId,
      title: event.title,
      type: event.type,
      content: event.content,
      videoUrl: event.videoUrl,
      durationMinutes: event.durationMinutes,
      orderIndex: event.orderIndex,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (lesson) => emit(LessonCreated(lesson: lesson)),
    );
  }

  Future<void> _onUpdateLesson(UpdateLesson event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.updateLesson(
      lessonId: event.lessonId,
      title: event.title,
      type: event.type,
      content: event.content,
      videoUrl: event.videoUrl,
      durationMinutes: event.durationMinutes,
      orderIndex: event.orderIndex,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (lesson) => emit(LessonUpdated(lesson: lesson)),
    );
  }

  Future<void> _onDeleteLesson(DeleteLesson event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.deleteLesson(event.lessonId);

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (_) => emit(LessonDeleted(lessonId: event.lessonId)),
    );
  }

  Future<void> _onEnrollInCourse(EnrollInCourse event, Emitter<CourseState> emit) async {
    emit(const EnrollmentProcessing());

    final result = await _courseRepository.enrollInCourse(event.courseId);

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (enrollment) => emit(EnrollmentSuccessful(enrollment: enrollment)),
    );
  }

  Future<void> _onLoadMyEnrollments(LoadMyEnrollments event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    final result = await _courseRepository.getMyEnrollments(
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (enrollments) => emit(MyEnrollmentsLoaded(
        enrollments: enrollments,
        hasMore: enrollments.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadEnrollment(LoadEnrollment event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.getEnrollment(event.courseId);

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (enrollment) => emit(EnrollmentLoaded(enrollment: enrollment)),
    );
  }

  Future<void> _onUpdateLessonProgress(UpdateLessonProgress event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.updateProgress(
      enrollmentId: event.enrollmentId,
      lessonId: event.lessonId,
      completed: event.completed,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (_) => emit(LessonProgressUpdated(
        lessonId: event.lessonId,
        completed: event.completed,
      )),
    );
  }

  Future<void> _onLoadCourseStudents(LoadCourseStudents event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    final result = await _courseRepository.getCourseStudents(
      courseId: event.courseId,
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (students) => emit(CourseStudentsLoaded(
        courseId: event.courseId,
        students: students,
        hasMore: students.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadInstructorCourses(LoadInstructorCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    final result = await _courseRepository.getInstructorCourses(
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (courses) => emit(InstructorCoursesLoaded(
        courses: courses,
        hasMore: courses.length >= _pageSize,
      )),
    );
  }

  Future<void> _onRateCourse(RateCourse event, Emitter<CourseState> emit) async {
    final result = await _courseRepository.rateCourse(
      courseId: event.courseId,
      rating: event.rating,
      review: event.review,
    );

    result.fold(
      (failure) => emit(CourseError(message: failure.message)),
      (_) => emit(CourseRated(
        courseId: event.courseId,
        rating: event.rating,
      )),
    );
  }
}
