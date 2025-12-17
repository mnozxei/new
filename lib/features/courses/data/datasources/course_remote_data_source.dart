import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/course_entity.dart';
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
  Future<List<CourseReviewEntity>> getCourseReviews(String courseId, {int limit = 20, int offset = 0});
  Future<CourseReviewEntity> addReview(AddReviewParams params);
  Future<CourseReviewEntity> updateReview(String reviewId, int rating, {String? comment});
  Future<void> deleteReview(String reviewId);
  Future<InstructorStats> getInstructorStats();
  Future<CourseStats> getCourseStats(String courseId);
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
}
