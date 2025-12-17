import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  CourseRepositoryImpl({required CourseRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CourseRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    CourseLevel? level,
  }) async {
    try {
      final courses = await _remoteDataSource.getCourses(
        page: page,
        limit: limit,
        category: category,
        level: level,
      );
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getFeaturedCourses({int limit = 10}) async {
    try {
      final courses = await _remoteDataSource.getFeaturedCourses(limit: limit);
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> searchCourses({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final courses = await _remoteDataSource.searchCourses(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseById(String courseId) async {
    try {
      final course = await _remoteDataSource.getCourseById(courseId);
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> createCourse({
    required String title,
    required String description,
    required double price,
    String? category,
    CourseLevel? level,
    String? thumbnailUrl,
  }) async {
    try {
      final course = await _remoteDataSource.createCourse(
        title: title,
        description: description,
        price: price,
        category: category,
        level: level,
        thumbnailUrl: thumbnailUrl,
      );
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> updateCourse({
    required String courseId,
    String? title,
    String? description,
    double? price,
    String? category,
    CourseLevel? level,
    String? thumbnailUrl,
    bool? isPublished,
  }) async {
    try {
      final course = await _remoteDataSource.updateCourse(
        courseId: courseId,
        title: title,
        description: description,
        price: price,
        category: category,
        level: level,
        thumbnailUrl: thumbnailUrl,
        isPublished: isPublished,
      );
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String courseId) async {
    try {
      await _remoteDataSource.deleteCourse(courseId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseSectionEntity>>> getCourseSections(String courseId) async {
    try {
      final sections = await _remoteDataSource.getCourseSections(courseId);
      return Right(sections);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseSectionEntity>> createSection({
    required String courseId,
    required String title,
    int? orderIndex,
  }) async {
    try {
      final section = await _remoteDataSource.createSection(
        courseId: courseId,
        title: title,
        orderIndex: orderIndex,
      );
      return Right(section);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseSectionEntity>> updateSection({
    required String sectionId,
    String? title,
    int? orderIndex,
  }) async {
    try {
      final section = await _remoteDataSource.updateSection(
        sectionId: sectionId,
        title: title,
        orderIndex: orderIndex,
      );
      return Right(section);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSection(String sectionId) async {
    try {
      await _remoteDataSource.deleteSection(sectionId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LessonEntity>>> getLessons(String sectionId) async {
    try {
      final lessons = await _remoteDataSource.getLessons(sectionId);
      return Right(lessons);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> createLesson({
    required String sectionId,
    required String title,
    required LessonType type,
    String? content,
    String? videoUrl,
    int? durationMinutes,
    int? orderIndex,
  }) async {
    try {
      final lesson = await _remoteDataSource.createLesson(
        sectionId: sectionId,
        title: title,
        type: type,
        content: content,
        videoUrl: videoUrl,
        durationMinutes: durationMinutes,
        orderIndex: orderIndex,
      );
      return Right(lesson);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> updateLesson({
    required String lessonId,
    String? title,
    LessonType? type,
    String? content,
    String? videoUrl,
    int? durationMinutes,
    int? orderIndex,
  }) async {
    try {
      final lesson = await _remoteDataSource.updateLesson(
        lessonId: lessonId,
        title: title,
        type: type,
        content: content,
        videoUrl: videoUrl,
        durationMinutes: durationMinutes,
        orderIndex: orderIndex,
      );
      return Right(lesson);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLesson(String lessonId) async {
    try {
      await _remoteDataSource.deleteLesson(lessonId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnrollmentEntity>> enrollInCourse(String courseId) async {
    try {
      final enrollment = await _remoteDataSource.enrollInCourse(courseId);
      return Right(enrollment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollments({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final enrollments = await _remoteDataSource.getMyEnrollments(
        page: page,
        limit: limit,
      );
      return Right(enrollments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnrollmentEntity>> getEnrollment(String courseId) async {
    try {
      final enrollment = await _remoteDataSource.getEnrollment(courseId);
      return Right(enrollment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProgress({
    required String enrollmentId,
    required String lessonId,
    bool completed = true,
  }) async {
    try {
      await _remoteDataSource.updateProgress(
        enrollmentId: enrollmentId,
        lessonId: lessonId,
        completed: completed,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EnrollmentEntity>>> getCourseStudents({
    required String courseId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final students = await _remoteDataSource.getCourseStudents(
        courseId: courseId,
        page: page,
        limit: limit,
      );
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getInstructorCourses({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final courses = await _remoteDataSource.getInstructorCourses(
        page: page,
        limit: limit,
      );
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rateCourse({
    required String courseId,
    required int rating,
    String? review,
  }) async {
    try {
      await _remoteDataSource.rateCourse(
        courseId: courseId,
        rating: rating,
        review: review,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
