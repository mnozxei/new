import 'dart:io';

import '../../domain/entities/certificate_entity.dart';
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
  Future<String> uploadThumbnail(String courseId, File file) async {
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
  Future<EnrollmentEntity> updateEnrollmentProgress(String courseId) async {
    return _remoteDataSource.updateEnrollmentProgress(courseId);
  }

  @override
  Future<EnrollmentEntity?> checkAndCompleteCourse(String courseId) async {
    return _remoteDataSource.checkAndCompleteCourse(courseId);
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
    return _remoteDataSource.getCourseQuizzes(courseId);
  }

  @override
  Future<QuizEntity?> getQuizById(String quizId) async {
    return _remoteDataSource.getQuizById(quizId);
  }

  @override
  Future<QuizEntity?> getLessonQuiz(String lessonId) async {
    return _remoteDataSource.getLessonQuiz(lessonId);
  }

  @override
  Future<QuizEntity> createQuiz(CreateQuizParams params) async {
    return _remoteDataSource.createQuiz(params);
  }

  @override
  Future<QuizEntity> updateQuiz(String quizId, UpdateQuizParams params) async {
    return _remoteDataSource.updateQuiz(quizId, params);
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    await _remoteDataSource.deleteQuiz(quizId);
  }

  @override
  Future<QuizQuestionEntity> addQuestion(AddQuestionParams params) async {
    return _remoteDataSource.addQuestion(params);
  }

  @override
  Future<QuizQuestionEntity> updateQuestion(
    String questionId,
    UpdateQuestionParams params,
  ) async {
    return _remoteDataSource.updateQuestion(questionId, params);
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    await _remoteDataSource.deleteQuestion(questionId);
  }

  @override
  Future<void> reorderQuestions(String quizId, List<String> questionIds) async {
    await _remoteDataSource.reorderQuestions(quizId, questionIds);
  }

  @override
  Future<QuizAttemptEntity> startQuizAttempt(String quizId) async {
    return _remoteDataSource.startQuizAttempt(quizId);
  }

  @override
  Future<QuizAttemptEntity> submitQuizAttempt(
    String attemptId,
    Map<String, dynamic> answers,
  ) async {
    return _remoteDataSource.submitQuizAttempt(attemptId, answers);
  }

  @override
  Future<List<QuizAttemptEntity>> getQuizAttempts(String quizId) async {
    return _remoteDataSource.getQuizAttempts(quizId);
  }

  @override
  Future<QuizAttemptEntity?> getLatestQuizAttempt(String quizId) async {
    return _remoteDataSource.getLatestQuizAttempt(quizId);
  }

  @override
  Future<bool> isQuizPassed(String quizId) async {
    return _remoteDataSource.isQuizPassed(quizId);
  }

  @override
  Future<bool> isLessonUnlocked(String lessonId) async {
    return _remoteDataSource.isLessonUnlocked(lessonId);
  }

  // ============================================
  // CERTIFICATE METHODS
  // ============================================

  @override
  Future<CertificateEntity> issueCertificate(String enrollmentId) async {
    return _remoteDataSource.issueCertificate(enrollmentId);
  }

  @override
  Future<CertificateEntity?> getCertificate(String certificateId) async {
    return _remoteDataSource.getCertificate(certificateId);
  }

  @override
  Future<CertificateEntity?> getCertificateByEnrollment(String enrollmentId) async {
    return _remoteDataSource.getCertificateByEnrollment(enrollmentId);
  }

  @override
  Future<CertificateEntity?> getCertificateBySerial(String serialNumber) async {
    return _remoteDataSource.getCertificateBySerial(serialNumber);
  }

  @override
  Future<CertificateVerificationResult> verifyCertificate(String serialNumber) async {
    return _remoteDataSource.verifyCertificate(serialNumber);
  }

  @override
  Future<List<CertificateEntity>> getUserCertificates() async {
    return _remoteDataSource.getUserCertificates();
  }

  @override
  Future<void> revokeCertificate(String certificateId, String reason) async {
    await _remoteDataSource.revokeCertificate(certificateId, reason);
  }
}
