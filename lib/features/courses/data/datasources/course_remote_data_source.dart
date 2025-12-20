import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/certificate_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/course_repository.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseEntity>> getCourses({
    String? category,
    CourseLevel? level,
    bool? isFree,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });
  Future<List<CourseEntity>> getFeaturedCourses({int limit = 10});
  Future<CourseEntity?> getCourseById(String id);
  Future<CourseEntity?> getCourseWithContent(String id);
  Future<List<CourseEntity>> getInstructorCourses(String instructorId);
  Future<List<CourseEntity>> getMyCourses();
  Future<CourseEntity> createCourse(CreateCourseParams params);
  Future<CourseEntity> updateCourse(String id, UpdateCourseParams params);
  Future<void> deleteCourse(String id);
  Future<CourseEntity> togglePublish(String id);
  Future<String> uploadThumbnail(String courseId, File file);
  Future<CourseSectionEntity> createSection(CreateSectionParams params);
  Future<CourseSectionEntity> updateSection(String sectionId, UpdateSectionParams params);
  Future<void> deleteSection(String sectionId);
  Future<void> reorderSections(String courseId, List<String> sectionIds);
  Future<LessonEntity> createLesson(CreateLessonParams params);
  Future<LessonEntity> updateLesson(String lessonId, UpdateLessonParams params);
  Future<void> deleteLesson(String lessonId);
  Future<void> reorderLessons(String sectionId, List<String> lessonIds);
  Future<bool> isEnrolled(String courseId);
  Future<EnrollmentEntity?> getEnrollment(String courseId);
  Future<List<EnrollmentEntity>> getMyEnrollments({
    EnrollmentStatus? status,
    int limit = 20,
    int offset = 0,
  });
  Future<EnrollmentEntity> enrollInCourse(String courseId, {String? paymentId});
  Future<LessonProgressEntity> updateLessonProgress(
    String lessonId, {
    int? watchTimeSeconds,
    int? lastPositionSeconds,
    bool? isCompleted,
  });
  Future<LessonProgressEntity?> getLessonProgress(String lessonId);
  Future<void> markLessonComplete(String lessonId);
  Future<EnrollmentEntity> updateEnrollmentProgress(String courseId);
  Future<EnrollmentEntity?> checkAndCompleteCourse(String courseId);
  Future<List<CourseReviewEntity>> getCourseReviews(String courseId, {int limit = 20, int offset = 0});
  Future<CourseReviewEntity> addReview(AddReviewParams params);
  Future<CourseReviewEntity> updateReview(String reviewId, int rating, {String? comment});
  Future<void> deleteReview(String reviewId);
  Future<InstructorStats> getInstructorStats();
  Future<CourseStats> getCourseStats(String courseId);

  // Quiz methods
  Future<List<QuizEntity>> getCourseQuizzes(String courseId);
  Future<QuizEntity?> getQuizById(String quizId);
  Future<QuizEntity?> getLessonQuiz(String lessonId);
  Future<QuizEntity?> getFinalQuiz(String courseId);
  Future<QuizEntity> createQuiz(CreateQuizParams params);
  Future<QuizEntity> updateQuiz(String quizId, UpdateQuizParams params);
  Future<void> deleteQuiz(String quizId);
  Future<QuizQuestionEntity> addQuestion(AddQuestionParams params);
  Future<QuizQuestionEntity> updateQuestion(String questionId, UpdateQuestionParams params);
  Future<void> deleteQuestion(String questionId);
  Future<void> reorderQuestions(String quizId, List<String> questionIds);
  Future<QuizAttemptEntity> startQuizAttempt(String quizId);
  Future<QuizAttemptEntity> submitQuizAttempt(String attemptId, Map<String, dynamic> answers);
  Future<List<QuizAttemptEntity>> getQuizAttempts(String quizId);
  Future<QuizAttemptEntity?> getLatestQuizAttempt(String quizId);
  Future<bool> isQuizPassed(String quizId);
  Future<bool> isLessonUnlocked(String lessonId);

  // Certificate methods
  Future<CertificateEntity> issueCertificate(String enrollmentId);
  Future<CertificateEntity?> getCertificate(String certificateId);
  Future<CertificateEntity?> getCertificateByEnrollment(String enrollmentId);
  Future<CertificateEntity?> getCertificateBySerial(String serialNumber);
  Future<CertificateVerificationResult> verifyCertificate(String serialNumber);
  Future<List<CertificateEntity>> getUserCertificates();
  Future<void> revokeCertificate(String certificateId, String reason);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  CourseRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<CourseEntity>> getCourses({
    String? category,
    CourseLevel? level,
    bool? isFree,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .eq('is_published', true);

    if (category != null) {
      query = query.eq('category', category);
    }
    if (level != null) {
      query = query.eq('level', level.value);
    }
    if (isFree != null) {
      query = query.eq('is_free', isFree);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapCourseFromJson(json)).toList();
  }

  @override
  Future<List<CourseEntity>> getFeaturedCourses({int limit = 10}) async {
    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .eq('is_published', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => _mapCourseFromJson(json)).toList();
  }

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapCourseFromJson(response);
  }

  @override
  Future<CourseEntity?> getCourseWithContent(String id) async {
    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*),
          sections:course_sections(
            *,
            lessons:lessons(*)
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapCourseFromJson(response);
  }

  @override
  Future<List<CourseEntity>> getInstructorCourses(String instructorId) async {
    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .eq('instructor_id', instructorId)
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return (response as List).map((json) => _mapCourseFromJson(json)).toList();
  }

  @override
  Future<List<CourseEntity>> getMyCourses() async {
    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .eq('instructor_id', _currentUserId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => _mapCourseFromJson(json)).toList();
  }

  @override
  Future<CourseEntity> createCourse(CreateCourseParams params) async {
    final now = DateTime.now();
    final data = params.toJson();
    data['instructor_id'] = _currentUserId;
    data['is_published'] = false;
    data['created_at'] = now.toIso8601String();
    data['updated_at'] = now.toIso8601String();

    final response = await _supabase
        .from('courses')
        .insert(data)
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .single();

    return _mapCourseFromJson(response);
  }

  @override
  Future<CourseEntity> updateCourse(String id, UpdateCourseParams params) async {
    final data = params.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('courses')
        .update(data)
        .eq('id', id)
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .single();

    return _mapCourseFromJson(response);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _supabase.from('courses').delete().eq('id', id);
  }

  @override
  Future<CourseEntity> togglePublish(String id) async {
    final current = await getCourseById(id);
    if (current == null) {
      throw Exception('Course not found');
    }

    final response = await _supabase
        .from('courses')
        .update({
          'is_published': !current.isPublished,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select('''
          *,
          instructor:profiles!instructor_id(*)
        ''')
        .single();

    return _mapCourseFromJson(response);
  }

  @override
  Future<String> uploadThumbnail(String courseId, File file) async {
    final fileName = '${courseId}_thumbnail_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
    final path = 'courses/$courseId/$fileName';

    await _supabase.storage.from('courses').upload(path, file);
    final url = _supabase.storage.from('courses').getPublicUrl(path);

    await _supabase.from('courses').update({
      'thumbnail_url': url,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', courseId);

    return url;
  }

  @override
  Future<CourseSectionEntity> createSection(CreateSectionParams params) async {
    final orderIndex = await _getNextSectionOrder(params.courseId);
    final now = DateTime.now();

    final response = await _supabase
        .from('course_sections')
        .insert({
          'course_id': params.courseId,
          'title': params.title,
          'description': params.description,
          'order_index': orderIndex,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select()
        .single();

    return _mapSectionFromJson(response);
  }

  @override
  Future<CourseSectionEntity> updateSection(String sectionId, UpdateSectionParams params) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (params.title != null) updateData['title'] = params.title;
    if (params.description != null) updateData['description'] = params.description;

    final response = await _supabase
        .from('course_sections')
        .update(updateData)
        .eq('id', sectionId)
        .select()
        .single();

    return _mapSectionFromJson(response);
  }

  @override
  Future<void> deleteSection(String sectionId) async {
    await _supabase.from('course_sections').delete().eq('id', sectionId);
  }

  @override
  Future<void> reorderSections(String courseId, List<String> sectionIds) async {
    for (int i = 0; i < sectionIds.length; i++) {
      await _supabase
          .from('course_sections')
          .update({'order_index': i})
          .eq('id', sectionIds[i]);
    }
  }

  @override
  Future<LessonEntity> createLesson(CreateLessonParams params) async {
    final orderIndex = await _getNextLessonOrder(params.sectionId);
    final now = DateTime.now();

    final response = await _supabase
        .from('lessons')
        .insert({
          'section_id': params.sectionId,
          'course_id': params.courseId,
          'title': params.title,
          'description': params.description,
          'content_type': params.contentType,
          'video_url': params.videoUrl,
          'duration_seconds': params.durationSeconds,
          'content': params.content,
          'is_free_preview': params.isFreePreview,
          'order_index': orderIndex,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select()
        .single();

    return _mapLessonFromJson(response);
  }

  @override
  Future<LessonEntity> updateLesson(String lessonId, UpdateLessonParams params) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (params.title != null) updateData['title'] = params.title;
    if (params.description != null) updateData['description'] = params.description;
    if (params.contentType != null) updateData['content_type'] = params.contentType;
    if (params.videoUrl != null) updateData['video_url'] = params.videoUrl;
    if (params.durationSeconds != null) updateData['duration_seconds'] = params.durationSeconds;
    if (params.content != null) updateData['content'] = params.content;
    if (params.isFreePreview != null) updateData['is_free_preview'] = params.isFreePreview;

    final response = await _supabase
        .from('lessons')
        .update(updateData)
        .eq('id', lessonId)
        .select()
        .single();

    return _mapLessonFromJson(response);
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    await _supabase.from('lessons').delete().eq('id', lessonId);
  }

  @override
  Future<void> reorderLessons(String sectionId, List<String> lessonIds) async {
    for (int i = 0; i < lessonIds.length; i++) {
      await _supabase
          .from('lessons')
          .update({'order_index': i})
          .eq('id', lessonIds[i]);
    }
  }

  @override
  Future<bool> isEnrolled(String courseId) async {
    final response = await _supabase
        .from('enrollments')
        .select('id')
        .eq('course_id', courseId)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<EnrollmentEntity?> getEnrollment(String courseId) async {
    final response = await _supabase
        .from('enrollments')
        .select('''
          *,
          course:courses(
            *,
            instructor:profiles!instructor_id(*)
          )
        ''')
        .eq('course_id', courseId)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (response == null) return null;
    return _mapEnrollmentFromJson(response);
  }

  @override
  Future<List<EnrollmentEntity>> getMyEnrollments({
    EnrollmentStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _supabase
        .from('enrollments')
        .select('''
          *,
          course:courses(
            *,
            instructor:profiles!instructor_id(*)
          )
        ''')
        .eq('user_id', _currentUserId);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final response = await query
        .order('enrolled_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapEnrollmentFromJson(json)).toList();
  }

  @override
  Future<EnrollmentEntity> enrollInCourse(String courseId, {String? paymentId}) async {
    final course = await getCourseById(courseId);
    final now = DateTime.now();

    final response = await _supabase
        .from('enrollments')
        .insert({
          'course_id': courseId,
          'user_id': _currentUserId,
          'status': EnrollmentStatus.active.value,
          'progress_percent': 0,
          'completed_lessons': [],
          'enrolled_at': now.toIso8601String(),
          'payment_id': paymentId,
          'amount_paid': course?.price ?? 0,
        })
        .select('''
          *,
          course:courses(
            *,
            instructor:profiles!instructor_id(*)
          )
        ''')
        .single();

    return _mapEnrollmentFromJson(response);
  }

  @override
  Future<LessonProgressEntity> updateLessonProgress(
    String lessonId, {
    int? watchTimeSeconds,
    int? lastPositionSeconds,
    bool? isCompleted,
  }) async {
    final lesson = await _supabase
        .from('lessons')
        .select('course_id')
        .eq('id', lessonId)
        .single();

    final enrollment = await _supabase
        .from('enrollments')
        .select('id')
        .eq('course_id', lesson['course_id'])
        .eq('user_id', _currentUserId)
        .single();

    final now = DateTime.now();
    final existingProgress = await getLessonProgress(lessonId);

    if (existingProgress != null) {
      final updateData = <String, dynamic>{
        'updated_at': now.toIso8601String(),
      };
      if (watchTimeSeconds != null) updateData['watch_time_seconds'] = watchTimeSeconds;
      if (lastPositionSeconds != null) updateData['last_position_seconds'] = lastPositionSeconds;
      if (isCompleted != null) {
        updateData['is_completed'] = isCompleted;
        if (isCompleted) updateData['completed_at'] = now.toIso8601String();
      }

      final response = await _supabase
          .from('lesson_progress')
          .update(updateData)
          .eq('id', existingProgress.id)
          .select()
          .single();

      return _mapLessonProgressFromJson(response);
    } else {
      final response = await _supabase
          .from('lesson_progress')
          .insert({
            'enrollment_id': enrollment['id'],
            'lesson_id': lessonId,
            'user_id': _currentUserId,
            'watch_time_seconds': watchTimeSeconds ?? 0,
            'last_position_seconds': lastPositionSeconds ?? 0,
            'is_completed': isCompleted ?? false,
            'completed_at': isCompleted == true ? now.toIso8601String() : null,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select()
          .single();

      return _mapLessonProgressFromJson(response);
    }
  }

  @override
  Future<LessonProgressEntity?> getLessonProgress(String lessonId) async {
    final response = await _supabase
        .from('lesson_progress')
        .select()
        .eq('lesson_id', lessonId)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (response == null) return null;
    return _mapLessonProgressFromJson(response);
  }

  @override
  Future<void> markLessonComplete(String lessonId) async {
    await updateLessonProgress(lessonId, isCompleted: true);

    // Get the course ID for this lesson
    final lesson = await _supabase
        .from('lessons')
        .select('course_id')
        .eq('id', lessonId)
        .single();

    final courseId = lesson['course_id'] as String;

    // Update enrollment progress
    await updateEnrollmentProgress(courseId);

    // Check if course should be completed
    await checkAndCompleteCourse(courseId);
  }

  @override
  Future<EnrollmentEntity> updateEnrollmentProgress(String courseId) async {
    // Get enrollment
    final enrollmentResponse = await _supabase
        .from('enrollments')
        .select('id, completed_lessons')
        .eq('course_id', courseId)
        .eq('user_id', _currentUserId)
        .single();

    final enrollmentId = enrollmentResponse['id'] as String;

    // Get all lessons for this course
    final lessonsResponse = await _supabase
        .from('lessons')
        .select('id')
        .eq('course_id', courseId);

    final allLessonIds = (lessonsResponse as List)
        .map((l) => l['id'] as String)
        .toList();

    // Get completed lesson progress for this user
    final progressResponse = await _supabase
        .from('lesson_progress')
        .select('lesson_id')
        .eq('user_id', _currentUserId)
        .eq('is_completed', true)
        .inFilter('lesson_id', allLessonIds);

    final completedLessonIds = (progressResponse as List)
        .map((p) => p['lesson_id'] as String)
        .toList();

    // Calculate progress percentage
    final progressPercent = allLessonIds.isEmpty
        ? 0
        : ((completedLessonIds.length / allLessonIds.length) * 100).round();

    // Determine current lesson (next uncompleted)
    String? currentLessonId;
    for (final lessonId in allLessonIds) {
      if (!completedLessonIds.contains(lessonId)) {
        currentLessonId = lessonId;
        break;
      }
    }

    // Update enrollment
    final response = await _supabase
        .from('enrollments')
        .update({
          'completed_lessons': completedLessonIds,
          'progress_percent': progressPercent,
          'current_lesson_id': currentLessonId,
        })
        .eq('id', enrollmentId)
        .select('''
          *,
          course:courses(
            *,
            instructor:profiles!instructor_id(*)
          )
        ''')
        .single();

    return _mapEnrollmentFromJson(response);
  }

  @override
  Future<EnrollmentEntity?> checkAndCompleteCourse(String courseId) async {
    // Get enrollment
    final enrollmentResponse = await _supabase
        .from('enrollments')
        .select()
        .eq('course_id', courseId)
        .eq('user_id', _currentUserId)
        .single();

    final progressPercent = enrollmentResponse['progress_percent'] as int? ?? 0;

    // Check if all lessons completed (100%)
    if (progressPercent < 100) {
      return null;
    }

    // Check if final quiz exists and is passed
    final finalQuizResponse = await _supabase
        .from('quizzes')
        .select('id')
        .eq('course_id', courseId)
        .eq('type', 'final')
        .maybeSingle();

    if (finalQuizResponse != null) {
      final finalQuizId = finalQuizResponse['id'] as String;
      final isPassed = await isQuizPassed(finalQuizId);
      if (!isPassed) {
        return null; // Final quiz not passed
      }
    }

    // All requirements met - mark course as complete
    final now = DateTime.now();
    final enrollmentId = enrollmentResponse['id'] as String;

    final response = await _supabase
        .from('enrollments')
        .update({
          'status': 'completed',
          'completed_at': now.toIso8601String(),
        })
        .eq('id', enrollmentId)
        .select('''
          *,
          course:courses(
            *,
            instructor:profiles!instructor_id(*)
          )
        ''')
        .single();

    // Automatically issue certificate
    try {
      await issueCertificate(enrollmentId);
    } catch (_) {
      // Certificate issuance failure should not fail course completion
    }

    return _mapEnrollmentFromJson(response);
  }

  @override
  Future<List<CourseReviewEntity>> getCourseReviews(String courseId, {int limit = 20, int offset = 0}) async {
    final response = await _supabase
        .from('course_reviews')
        .select('''
          *,
          user:profiles!user_id(*)
        ''')
        .eq('course_id', courseId)
        .eq('is_visible', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapReviewFromJson(json)).toList();
  }

  @override
  Future<CourseReviewEntity> addReview(AddReviewParams params) async {
    final now = DateTime.now();
    final response = await _supabase
        .from('course_reviews')
        .insert({
          'course_id': params.courseId,
          'user_id': _currentUserId,
          'rating': params.rating,
          'comment': params.comment,
          'is_visible': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select('''
          *,
          user:profiles!user_id(*)
        ''')
        .single();

    return _mapReviewFromJson(response);
  }

  @override
  Future<CourseReviewEntity> updateReview(String reviewId, int rating, {String? comment}) async {
    final updateData = <String, dynamic>{
      'rating': rating,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (comment != null) updateData['comment'] = comment;

    final response = await _supabase
        .from('course_reviews')
        .update(updateData)
        .eq('id', reviewId)
        .select('''
          *,
          user:profiles!user_id(*)
        ''')
        .single();

    return _mapReviewFromJson(response);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _supabase.from('course_reviews').delete().eq('id', reviewId);
  }

  @override
  Future<InstructorStats> getInstructorStats() async {
    final coursesResponse = await _supabase
        .from('courses')
        .select('id, price')
        .eq('instructor_id', _currentUserId);

    final courses = coursesResponse as List;
    final courseIds = courses.map((c) => c['id'] as String).toList();

    if (courseIds.isEmpty) {
      return const InstructorStats();
    }

    final enrollmentsResponse = await _supabase
        .from('enrollments')
        .select('amount_paid')
        .inFilter('course_id', courseIds);

    final enrollments = enrollmentsResponse as List;
    final totalStudents = enrollments.length;
    final totalRevenue = enrollments.fold<double>(0, (sum, e) => sum + ((e['amount_paid'] as num?)?.toDouble() ?? 0));

    final reviewsResponse = await _supabase
        .from('course_reviews')
        .select('rating')
        .inFilter('course_id', courseIds);

    final reviews = reviewsResponse as List;
    final totalReviews = reviews.length;
    final averageRating = totalReviews > 0
        ? reviews.fold<double>(0, (sum, r) => sum + (r['rating'] as int)) / totalReviews
        : 0.0;

    return InstructorStats(
      totalCourses: courses.length,
      totalStudents: totalStudents,
      totalRevenue: totalRevenue,
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }

  @override
  Future<CourseStats> getCourseStats(String courseId) async {
    final enrollmentsResponse = await _supabase
        .from('enrollments')
        .select()
        .eq('course_id', courseId);

    final enrollments = enrollmentsResponse as List;
    final totalEnrollments = enrollments.length;
    final completions = enrollments.where((e) => e['status'] == 'completed').length;
    final totalRevenue = enrollments.fold<double>(0, (sum, e) => sum + ((e['amount_paid'] as num?)?.toDouble() ?? 0));
    final averageProgress = totalEnrollments > 0
        ? enrollments.fold<double>(0, (sum, e) => sum + ((e['progress_percent'] as int?) ?? 0)) / totalEnrollments
        : 0.0;

    final reviewsResponse = await _supabase
        .from('course_reviews')
        .select('rating')
        .eq('course_id', courseId);

    final reviews = reviewsResponse as List;
    final totalReviews = reviews.length;
    final averageRating = totalReviews > 0
        ? reviews.fold<double>(0, (sum, r) => sum + (r['rating'] as int)) / totalReviews
        : 0.0;

    return CourseStats(
      enrollments: totalEnrollments,
      completions: completions,
      revenue: totalRevenue,
      averageProgress: averageProgress,
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }

  Future<int> _getNextSectionOrder(String courseId) async {
    final response = await _supabase
        .from('course_sections')
        .select('order_index')
        .eq('course_id', courseId)
        .order('order_index', ascending: false)
        .limit(1);

    if ((response as List).isEmpty) return 0;
    return (response.first['order_index'] as int) + 1;
  }

  Future<int> _getNextLessonOrder(String sectionId) async {
    final response = await _supabase
        .from('lessons')
        .select('order_index')
        .eq('section_id', sectionId)
        .order('order_index', ascending: false)
        .limit(1);

    if ((response as List).isEmpty) return 0;
    return (response.first['order_index'] as int) + 1;
  }

  CourseEntity _mapCourseFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    InstructorInfo? instructor;
    if (json['instructor'] != null) {
      final i = json['instructor'] as Map<String, dynamic>;
      instructor = InstructorInfo(
        id: i['id'] as String? ?? '',
        fullName: i['full_name'] as String? ?? '',
        avatarUrl: i['avatar_url'] as String?,
        headline: i['headline'] as String?,
      );
    }

    List<CourseSectionEntity>? sections;
    if (json['sections'] != null) {
      final sectionsData = json['sections'] as List;
      sections = sectionsData.map((s) => _mapSectionFromJson(s as Map<String, dynamic>)).toList();
    }

    return CourseEntity(
      id: json['id'] as String,
      instructorId: json['instructor_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      previewVideoUrl: json['preview_video_url'] as String?,
      level: CourseLevel.fromString(json['level'] as String? ?? 'beginner'),
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      language: json['language'] as String? ?? 'ar',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      isFree: json['is_free'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      lessonCount: json['lesson_count'] as int? ?? 0,
      enrollmentCount: json['enrollment_count'] as int? ?? 0,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      requirements: List<String>.from(json['requirements'] ?? []),
      objectives: List<String>.from(json['objectives'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
      instructor: instructor,
      sections: sections,
    );
  }

  CourseSectionEntity _mapSectionFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    List<LessonEntity> lessons = [];
    if (json['lessons'] != null) {
      final lessonsData = json['lessons'] as List;
      lessons = lessonsData.map((l) => _mapLessonFromJson(l as Map<String, dynamic>)).toList();
    }

    return CourseSectionEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
      lessons: lessons,
    );
  }

  LessonEntity _mapLessonFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return LessonEntity(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentType: json['content_type'] as String? ?? 'video',
      videoUrl: json['video_url'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      content: json['content'] as String?,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
    );
  }

  EnrollmentEntity _mapEnrollmentFromJson(Map<String, dynamic> json) {
    CourseEntity? course;
    if (json['course'] != null) {
      course = _mapCourseFromJson(json['course'] as Map<String, dynamic>);
    }

    return EnrollmentEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      userId: json['user_id'] as String,
      status: EnrollmentStatus.fromString(json['status'] as String? ?? 'active'),
      progressPercent: json['progress_percent'] as int? ?? 0,
      completedLessons: List<String>.from(json['completed_lessons'] ?? []),
      currentLessonId: json['current_lesson_id'] as String?,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      certificateUrl: json['certificate_url'] as String?,
      paymentId: json['payment_id'] as String?,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      course: course,
    );
  }

  LessonProgressEntity _mapLessonProgressFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return LessonProgressEntity(
      id: json['id'] as String,
      enrollmentId: json['enrollment_id'] as String,
      lessonId: json['lesson_id'] as String,
      userId: json['user_id'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      watchTimeSeconds: json['watch_time_seconds'] as int? ?? 0,
      lastPositionSeconds: json['last_position_seconds'] as int? ?? 0,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
    );
  }

  CourseReviewEntity _mapReviewFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    ReviewUserInfo? user;
    if (json['user'] != null) {
      final u = json['user'] as Map<String, dynamic>;
      user = ReviewUserInfo(
        id: u['id'] as String? ?? '',
        fullName: u['full_name'] as String? ?? '',
        avatarUrl: u['avatar_url'] as String?,
      );
    }

    return CourseReviewEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      isVisible: json['is_visible'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
      user: user,
    );
  }

  // ============================================
  // QUIZ METHODS IMPLEMENTATION
  // ============================================

  @override
  Future<List<QuizEntity>> getCourseQuizzes(String courseId) async {
    final response = await _supabase
        .from('quizzes')
        .select('''
          *,
          questions:quiz_questions(
            *,
            answers:quiz_answers(*)
          )
        ''')
        .eq('course_id', courseId)
        .order('sort_order', ascending: true);

    return (response as List).map((json) => _mapQuizFromJson(json)).toList();
  }

  @override
  Future<QuizEntity?> getQuizById(String quizId) async {
    final response = await _supabase
        .from('quizzes')
        .select('''
          *,
          questions:quiz_questions(
            *,
            answers:quiz_answers(*)
          )
        ''')
        .eq('id', quizId)
        .maybeSingle();

    if (response == null) return null;
    return _mapQuizFromJson(response);
  }

  @override
  Future<QuizEntity?> getLessonQuiz(String lessonId) async {
    final response = await _supabase
        .from('quizzes')
        .select('''
          *,
          questions:quiz_questions(
            *,
            answers:quiz_answers(*)
          )
        ''')
        .eq('lesson_id', lessonId)
        .maybeSingle();

    if (response == null) return null;
    return _mapQuizFromJson(response);
  }

  @override
  Future<QuizEntity?> getFinalQuiz(String courseId) async {
    final response = await _supabase
        .from('quizzes')
        .select('''
          *,
          questions:quiz_questions(
            *,
            answers:quiz_answers(*)
          )
        ''')
        .eq('course_id', courseId)
        .eq('is_final_quiz', true)
        .maybeSingle();

    if (response == null) return null;
    return _mapQuizFromJson(response);
  }

  @override
  Future<QuizEntity> createQuiz(CreateQuizParams params) async {
    final now = DateTime.now();
    final sortOrder = await _getNextQuizOrder(params.courseId);

    final response = await _supabase
        .from('quizzes')
        .insert({
          ...params.toJson(),
          'sort_order': sortOrder,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select()
        .single();

    return _mapQuizFromJson(response);
  }

  @override
  Future<QuizEntity> updateQuiz(String quizId, UpdateQuizParams params) async {
    final data = params.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('quizzes')
        .update(data)
        .eq('id', quizId)
        .select('''
          *,
          questions:quiz_questions(
            *,
            answers:quiz_answers(*)
          )
        ''')
        .single();

    return _mapQuizFromJson(response);
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    await _supabase.from('quizzes').delete().eq('id', quizId);
  }

  @override
  Future<QuizQuestionEntity> addQuestion(AddQuestionParams params) async {
    final now = DateTime.now();
    final sortOrder = await _getNextQuestionOrder(params.quizId);

    // Insert question
    final questionResponse = await _supabase
        .from('quiz_questions')
        .insert({
          ...params.toJson(),
          'sort_order': sortOrder,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select()
        .single();

    final questionId = questionResponse['id'] as String;

    // Insert answers if provided
    if (params.answers.isNotEmpty) {
      final answersData = params.answers.asMap().entries.map((entry) => {
        ...entry.value.toJson(),
        'question_id': questionId,
        'sort_order': entry.key,
        'created_at': now.toIso8601String(),
      }).toList();

      await _supabase.from('quiz_answers').insert(answersData);
    }

    // Re-fetch with answers
    final response = await _supabase
        .from('quiz_questions')
        .select('''
          *,
          answers:quiz_answers(*)
        ''')
        .eq('id', questionId)
        .single();

    return _mapQuestionFromJson(response);
  }

  @override
  Future<QuizQuestionEntity> updateQuestion(
    String questionId,
    UpdateQuestionParams params,
  ) async {
    final data = params.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('quiz_questions')
        .update(data)
        .eq('id', questionId)
        .select('''
          *,
          answers:quiz_answers(*)
        ''')
        .single();

    return _mapQuestionFromJson(response);
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    await _supabase.from('quiz_questions').delete().eq('id', questionId);
  }

  @override
  Future<void> reorderQuestions(String quizId, List<String> questionIds) async {
    for (int i = 0; i < questionIds.length; i++) {
      await _supabase
          .from('quiz_questions')
          .update({'sort_order': i})
          .eq('id', questionIds[i]);
    }
  }

  @override
  Future<QuizAttemptEntity> startQuizAttempt(String quizId) async {
    final quiz = await getQuizById(quizId);
    if (quiz == null) {
      throw Exception('Quiz not found');
    }

    // Get attempt count for this user
    final attemptCount = await _supabase
        .from('quiz_attempts')
        .select('id')
        .eq('quiz_id', quizId)
        .eq('user_id', _currentUserId)
        .count();

    final attemptNumber = (attemptCount.count ?? 0) + 1;

    // Check if max attempts exceeded
    if (quiz.maxAttempts > 0 && attemptNumber > quiz.maxAttempts) {
      throw Exception('Maximum attempts exceeded');
    }

    final now = DateTime.now();
    final response = await _supabase
        .from('quiz_attempts')
        .insert({
          'quiz_id': quizId,
          'course_id': quiz.courseId,
          'user_id': _currentUserId,
          'attempt_number': attemptNumber,
          'score': 0,
          'passed': false,
          'answers': {},
          'started_at': now.toIso8601String(),
          'created_at': now.toIso8601String(),
        })
        .select()
        .single();

    return _mapAttemptFromJson(response);
  }

  @override
  Future<QuizAttemptEntity> submitQuizAttempt(
    String attemptId,
    Map<String, dynamic> answers,
  ) async {
    // Get the attempt
    final attemptResponse = await _supabase
        .from('quiz_attempts')
        .select()
        .eq('id', attemptId)
        .single();

    final quizId = attemptResponse['quiz_id'] as String;
    final startedAt = DateTime.parse(attemptResponse['started_at'] as String);

    // Get quiz with questions
    final quiz = await getQuizById(quizId);
    if (quiz == null) {
      throw Exception('Quiz not found');
    }

    // Calculate score
    double earnedPoints = 0;
    double totalPoints = 0;

    for (final question in quiz.questions) {
      totalPoints += question.points;

      final userAnswer = answers[question.id];
      if (userAnswer != null) {
        final correctAnswerIds = question.correctAnswers.map((a) => a.id).toSet();

        if (question.questionType == QuestionType.single) {
          if (correctAnswerIds.contains(userAnswer)) {
            earnedPoints += question.points;
          }
        } else if (question.questionType == QuestionType.multiple) {
          final userAnswers = (userAnswer as List).toSet();
          if (userAnswers.containsAll(correctAnswerIds) &&
              correctAnswerIds.containsAll(userAnswers)) {
            earnedPoints += question.points;
          }
        } else if (question.questionType == QuestionType.trueFalse) {
          if (correctAnswerIds.contains(userAnswer)) {
            earnedPoints += question.points;
          }
        }
      }
    }

    final score = totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0;
    final passed = score >= quiz.passingScore;
    final now = DateTime.now();
    final timeTaken = now.difference(startedAt).inSeconds;

    final response = await _supabase
        .from('quiz_attempts')
        .update({
          'score': score,
          'passed': passed,
          'answers': answers,
          'time_taken_seconds': timeTaken,
          'completed_at': now.toIso8601String(),
        })
        .eq('id', attemptId)
        .select()
        .single();

    return _mapAttemptFromJson(response);
  }

  @override
  Future<List<QuizAttemptEntity>> getQuizAttempts(String quizId) async {
    final response = await _supabase
        .from('quiz_attempts')
        .select()
        .eq('quiz_id', quizId)
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => _mapAttemptFromJson(json)).toList();
  }

  @override
  Future<QuizAttemptEntity?> getLatestQuizAttempt(String quizId) async {
    final response = await _supabase
        .from('quiz_attempts')
        .select()
        .eq('quiz_id', quizId)
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return _mapAttemptFromJson(response);
  }

  @override
  Future<bool> isQuizPassed(String quizId) async {
    final response = await _supabase
        .from('quiz_attempts')
        .select('passed')
        .eq('quiz_id', quizId)
        .eq('user_id', _currentUserId)
        .eq('passed', true)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<bool> isLessonUnlocked(String lessonId) async {
    // Get the lesson
    final lessonResponse = await _supabase
        .from('lessons')
        .select('course_id, section_id, order_index, requires_quiz_pass, unlock_after_lesson_id')
        .eq('id', lessonId)
        .maybeSingle();

    if (lessonResponse == null) return false;

    final requiresQuizPass = lessonResponse['requires_quiz_pass'] as bool? ?? false;
    final unlockAfterLessonId = lessonResponse['unlock_after_lesson_id'] as String?;

    // If no requirements, lesson is unlocked
    if (!requiresQuizPass && unlockAfterLessonId == null) {
      return true;
    }

    // If there's a specific lesson to complete first
    if (unlockAfterLessonId != null) {
      // Check if the previous lesson's quiz is passed
      final previousLessonQuiz = await getLessonQuiz(unlockAfterLessonId);
      if (previousLessonQuiz != null && previousLessonQuiz.isRequired) {
        final isPassed = await isQuizPassed(previousLessonQuiz.id);
        if (!isPassed) return false;
      }
    }

    return true;
  }

  Future<int> _getNextQuizOrder(String courseId) async {
    final response = await _supabase
        .from('quizzes')
        .select('sort_order')
        .eq('course_id', courseId)
        .order('sort_order', ascending: false)
        .limit(1);

    if ((response as List).isEmpty) return 0;
    return (response.first['sort_order'] as int) + 1;
  }

  Future<int> _getNextQuestionOrder(String quizId) async {
    final response = await _supabase
        .from('quiz_questions')
        .select('sort_order')
        .eq('quiz_id', quizId)
        .order('sort_order', ascending: false)
        .limit(1);

    if ((response as List).isEmpty) return 0;
    return (response.first['sort_order'] as int) + 1;
  }

  QuizEntity _mapQuizFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    List<QuizQuestionEntity> questions = [];
    if (json['questions'] != null) {
      final questionsData = json['questions'] as List;
      questions = questionsData
          .map((q) => _mapQuestionFromJson(q as Map<String, dynamic>))
          .toList();
      questions.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return QuizEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      lessonId: json['lesson_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: QuizType.fromString(json['type'] as String? ?? 'lesson'),
      passingScore: json['passing_score'] as int? ?? 70,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      maxAttempts: json['max_attempts'] as int? ?? 3,
      shuffleQuestions: json['shuffle_questions'] as bool? ?? true,
      shuffleAnswers: json['shuffle_answers'] as bool? ?? true,
      showCorrectAnswers: json['show_correct_answers'] as bool? ?? false,
      isRequired: json['is_required'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
      questions: questions,
    );
  }

  QuizQuestionEntity _mapQuestionFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    List<QuizAnswerEntity> answers = [];
    if (json['answers'] != null) {
      final answersData = json['answers'] as List;
      answers = answersData
          .map((a) => _mapAnswerFromJson(a as Map<String, dynamic>))
          .toList();
      answers.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return QuizQuestionEntity(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      questionType: QuestionType.fromString(
          json['question_type'] as String? ?? 'single'),
      questionText: json['question_text'] as String,
      questionImageUrl: json['question_image_url'] as String?,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 1,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
      answers: answers,
    );
  }

  QuizAnswerEntity _mapAnswerFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return QuizAnswerEntity(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      answerText: json['answer_text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
    );
  }

  QuizAttemptEntity _mapAttemptFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return QuizAttemptEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quizId: json['quiz_id'] as String,
      courseId: json['course_id'] as String,
      attemptNumber: json['attempt_number'] as int? ?? 1,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      passed: json['passed'] as bool? ?? false,
      timeTakenSeconds: json['time_taken_seconds'] as int?,
      answers: Map<String, dynamic>.from(json['answers'] ?? {}),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : now,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
    );
  }

  // ============================================
  // CERTIFICATE METHODS IMPLEMENTATION
  // ============================================

  @override
  Future<CertificateEntity> issueCertificate(String enrollmentId) async {
    // Get enrollment details
    final enrollmentResponse = await _supabase
        .from('enrollments')
        .select('''
          *,
          course:courses(
            *,
            instructor:profiles!instructor_id(*)
          ),
          user:profiles!user_id(*)
        ''')
        .eq('id', enrollmentId)
        .single();

    // Check if enrollment is completed
    if (enrollmentResponse['status'] != 'completed') {
      throw Exception('Enrollment is not completed');
    }

    // Check if certificate already exists
    final existingCertificate = await getCertificateByEnrollment(enrollmentId);
    if (existingCertificate != null) {
      return existingCertificate;
    }

    // Generate unique serial number
    final serialNumber = CertificateSerialGenerator.generate();

    // Extract names for caching
    final course = enrollmentResponse['course'] as Map<String, dynamic>?;
    final user = enrollmentResponse['user'] as Map<String, dynamic>?;
    final instructor = course?['instructor'] as Map<String, dynamic>?;

    final now = DateTime.now();
    final verificationUrl = 'https://tamad.hub/verify/$serialNumber';

    final response = await _supabase
        .from('certificates')
        .insert({
          'enrollment_id': enrollmentId,
          'course_id': enrollmentResponse['course_id'],
          'user_id': enrollmentResponse['user_id'],
          'serial_number': serialNumber,
          'status': 'issued',
          'course_name': course?['title'],
          'student_name': user?['full_name'],
          'instructor_name': instructor?['full_name'],
          'verification_url': verificationUrl,
          'qr_code_data': verificationUrl,
          'issued_at': now.toIso8601String(),
          'created_at': now.toIso8601String(),
        })
        .select()
        .single();

    // Update enrollment with certificate URL
    await _supabase
        .from('enrollments')
        .update({
          'certificate_url': verificationUrl,
        })
        .eq('id', enrollmentId);

    return _mapCertificateFromJson(response);
  }

  @override
  Future<CertificateEntity?> getCertificate(String certificateId) async {
    final response = await _supabase
        .from('certificates')
        .select()
        .eq('id', certificateId)
        .maybeSingle();

    if (response == null) return null;
    return _mapCertificateFromJson(response);
  }

  @override
  Future<CertificateEntity?> getCertificateByEnrollment(String enrollmentId) async {
    final response = await _supabase
        .from('certificates')
        .select()
        .eq('enrollment_id', enrollmentId)
        .maybeSingle();

    if (response == null) return null;
    return _mapCertificateFromJson(response);
  }

  @override
  Future<CertificateEntity?> getCertificateBySerial(String serialNumber) async {
    final response = await _supabase
        .from('certificates')
        .select()
        .eq('serial_number', serialNumber)
        .maybeSingle();

    if (response == null) return null;
    return _mapCertificateFromJson(response);
  }

  @override
  Future<CertificateVerificationResult> verifyCertificate(String serialNumber) async {
    // Validate serial number format
    if (!CertificateSerialGenerator.isValid(serialNumber)) {
      return CertificateVerificationResult.invalid('صيغة رقم الشهادة غير صحيحة');
    }

    final certificate = await getCertificateBySerial(serialNumber);

    if (certificate == null) {
      return CertificateVerificationResult.notFound();
    }

    if (certificate.status == CertificateStatus.revoked) {
      return CertificateVerificationResult.revoked(
        certificate.revokedReason ?? 'سبب غير محدد',
      );
    }

    return CertificateVerificationResult.valid(certificate);
  }

  @override
  Future<List<CertificateEntity>> getUserCertificates() async {
    final response = await _supabase
        .from('certificates')
        .select()
        .eq('user_id', _currentUserId)
        .eq('status', 'issued')
        .order('issued_at', ascending: false);

    return (response as List).map((json) => _mapCertificateFromJson(json)).toList();
  }

  @override
  Future<void> revokeCertificate(String certificateId, String reason) async {
    final now = DateTime.now();
    await _supabase
        .from('certificates')
        .update({
          'status': 'revoked',
          'revoked_at': now.toIso8601String(),
          'revoked_reason': reason,
        })
        .eq('id', certificateId);
  }

  CertificateEntity _mapCertificateFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return CertificateEntity(
      id: json['id'] as String,
      enrollmentId: json['enrollment_id'] as String,
      courseId: json['course_id'] as String,
      userId: json['user_id'] as String,
      serialNumber: json['serial_number'] as String,
      status: CertificateStatus.fromString(json['status'] as String? ?? 'issued'),
      courseName: json['course_name'] as String?,
      studentName: json['student_name'] as String?,
      instructorName: json['instructor_name'] as String?,
      companyName: json['company_name'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      verificationUrl: json['verification_url'] as String?,
      qrCodeData: json['qr_code_data'] as String?,
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : now,
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
      revokedReason: json['revoked_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
    );
  }
}
