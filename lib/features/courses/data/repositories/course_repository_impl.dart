import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  CourseRepositoryImpl({required CourseRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CourseRemoteDataSource _remoteDataSource;

  @override
  Future<List<CourseEntity>> getCourses({
    String? category,
    CourseLevel? level,
    bool? isFree,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getCourses(
      category: category,
      level: level,
      isFree: isFree,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<CourseEntity>> getFeaturedCourses({int limit = 10}) async {
    return _remoteDataSource.getFeaturedCourses(limit: limit);
  }

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    return _remoteDataSource.getCourseById(id);
  }

  @override
  Future<CourseEntity?> getCourseWithContent(String id) async {
    return _remoteDataSource.getCourseWithContent(id);
  }

  @override
  Future<List<CourseEntity>> getInstructorCourses(String instructorId) async {
    return _remoteDataSource.getInstructorCourses(instructorId);
  }

  @override
  Future<List<CourseEntity>> getMyCourses() async {
    return _remoteDataSource.getMyCourses();
  }

  @override
  Future<CourseEntity> createCourse(CreateCourseParams params) async {
    return _remoteDataSource.createCourse(params);
  }

  @override
  Future<CourseEntity> updateCourse(String id, UpdateCourseParams params) async {
    return _remoteDataSource.updateCourse(id, params);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _remoteDataSource.deleteCourse(id);
  }

  @override
  Future<CourseEntity> togglePublish(String id) async {
    return _remoteDataSource.togglePublish(id);
  }

  @override
  Future<String> uploadThumbnail(String courseId, dynamic file) async {
    return _remoteDataSource.uploadThumbnail(courseId, file);
  }

  @override
  Future<CourseSectionEntity> createSection(CreateSectionParams params) async {
    return _remoteDataSource.createSection(params);
  }

  @override
  Future<CourseSectionEntity> updateSection(String sectionId, UpdateSectionParams params) async {
    return _remoteDataSource.updateSection(sectionId, params);
  }

  @override
  Future<void> deleteSection(String sectionId) async {
    await _remoteDataSource.deleteSection(sectionId);
  }

  @override
  Future<void> reorderSections(String courseId, List<String> sectionIds) async {
    await _remoteDataSource.reorderSections(courseId, sectionIds);
  }

  @override
  Future<LessonEntity> createLesson(CreateLessonParams params) async {
    return _remoteDataSource.createLesson(params);
  }

  @override
  Future<LessonEntity> updateLesson(String lessonId, UpdateLessonParams params) async {
    return _remoteDataSource.updateLesson(lessonId, params);
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    await _remoteDataSource.deleteLesson(lessonId);
  }

  @override
  Future<void> reorderLessons(String sectionId, List<String> lessonIds) async {
    await _remoteDataSource.reorderLessons(sectionId, lessonIds);
  }

  @override
  Future<bool> isEnrolled(String courseId) async {
    return _remoteDataSource.isEnrolled(courseId);
  }

  @override
  Future<EnrollmentEntity?> getEnrollment(String courseId) async {
    return _remoteDataSource.getEnrollment(courseId);
  }

  @override
  Future<List<EnrollmentEntity>> getMyEnrollments({
    EnrollmentStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getMyEnrollments(
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<EnrollmentEntity> enrollInCourse(String courseId, {String? paymentId}) async {
    return _remoteDataSource.enrollInCourse(courseId, paymentId: paymentId);
  }

  @override
  Future<LessonProgressEntity> updateLessonProgress(
    String lessonId, {
    int? watchTimeSeconds,
    int? lastPositionSeconds,
    bool? isCompleted,
  }) async {
    return _remoteDataSource.updateLessonProgress(
      lessonId,
      watchTimeSeconds: watchTimeSeconds,
      lastPositionSeconds: lastPositionSeconds,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<LessonProgressEntity?> getLessonProgress(String lessonId) async {
    return _remoteDataSource.getLessonProgress(lessonId);
  }

  @override
  Future<void> markLessonComplete(String lessonId) async {
    await _remoteDataSource.markLessonComplete(lessonId);
  }

  @override
  Future<List<CourseReviewEntity>> getCourseReviews(
    String courseId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getCourseReviews(
      courseId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<CourseReviewEntity> addReview(AddReviewParams params) async {
    return _remoteDataSource.addReview(params);
  }

  @override
  Future<CourseReviewEntity> updateReview(String reviewId, int rating, {String? comment}) async {
    return _remoteDataSource.updateReview(reviewId, rating, comment: comment);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _remoteDataSource.deleteReview(reviewId);
  }

  @override
  Future<InstructorStats> getInstructorStats() async {
    return _remoteDataSource.getInstructorStats();
  }

  @override
  Future<CourseStats> getCourseStats(String courseId) async {
    return _remoteDataSource.getCourseStats(courseId);
  }

  // ============================================
  // QUIZ METHODS
  // ============================================

  @override
  Future<List<QuizEntity>> getCourseQuizzes(String courseId) async {
    return [];
  }

  @override
  Future<QuizEntity?> getQuizById(String quizId) async {
    return null;
  }

  @override
  Future<QuizEntity?> getLessonQuiz(String lessonId) async {
    return null;
  }

  @override
  Future<QuizEntity> createQuiz(CreateQuizParams params) async {
    throw UnimplementedError('createQuiz not implemented');
  }

  @override
  Future<QuizEntity> updateQuiz(String quizId, UpdateQuizParams params) async {
    throw UnimplementedError('updateQuiz not implemented');
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    throw UnimplementedError('deleteQuiz not implemented');
  }

  @override
  Future<QuizQuestionEntity> addQuestion(AddQuestionParams params) async {
    throw UnimplementedError('addQuestion not implemented');
  }

  @override
  Future<QuizQuestionEntity> updateQuestion(
    String questionId,
    UpdateQuestionParams params,
  ) async {
    throw UnimplementedError('updateQuestion not implemented');
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    throw UnimplementedError('deleteQuestion not implemented');
  }

  @override
  Future<void> reorderQuestions(String quizId, List<String> questionIds) async {
    // TODO: Implement
  }

  @override
  Future<QuizAttemptEntity> startQuizAttempt(String quizId) async {
    throw UnimplementedError('startQuizAttempt not implemented');
  }

  @override
  Future<QuizAttemptEntity> submitQuizAttempt(
    String attemptId,
    Map<String, dynamic> answers,
  ) async {
    throw UnimplementedError('submitQuizAttempt not implemented');
  }

  @override
  Future<List<QuizAttemptEntity>> getQuizAttempts(String quizId) async {
    return [];
  }

  @override
  Future<QuizAttemptEntity?> getLatestQuizAttempt(String quizId) async {
    return null;
  }

  @override
  Future<bool> isQuizPassed(String quizId) async {
    return true;
  }

  @override
  Future<bool> isLessonUnlocked(String lessonId) async {
    return true;
  }
}
