import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/course_entity.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseEntity>> getCourses({int page = 1, int limit = 20, String? category, CourseLevel? level});
  Future<List<CourseEntity>> getFeaturedCourses({int limit = 10});
  Future<List<CourseEntity>> searchCourses({required String query, int page = 1, int limit = 20});
  Future<CourseEntity> getCourseById(String courseId);
  Future<CourseEntity> createCourse({required String title, required String description, required double price, String? category, CourseLevel? level, String? thumbnailUrl});
  Future<CourseEntity> updateCourse({required String courseId, String? title, String? description, double? price, String? category, CourseLevel? level, String? thumbnailUrl, bool? isPublished});
  Future<void> deleteCourse(String courseId);
  Future<List<CourseSectionEntity>> getCourseSections(String courseId);
  Future<CourseSectionEntity> createSection({required String courseId, required String title, int? orderIndex});
  Future<CourseSectionEntity> updateSection({required String sectionId, String? title, int? orderIndex});
  Future<void> deleteSection(String sectionId);
  Future<List<LessonEntity>> getLessons(String sectionId);
  Future<LessonEntity> createLesson({required String sectionId, required String title, required LessonType type, String? content, String? videoUrl, int? durationMinutes, int? orderIndex});
  Future<LessonEntity> updateLesson({required String lessonId, String? title, LessonType? type, String? content, String? videoUrl, int? durationMinutes, int? orderIndex});
  Future<void> deleteLesson(String lessonId);
  Future<EnrollmentEntity> enrollInCourse(String courseId);
  Future<List<EnrollmentEntity>> getMyEnrollments({int page = 1, int limit = 20});
  Future<EnrollmentEntity> getEnrollment(String courseId);
  Future<void> updateProgress({required String enrollmentId, required String lessonId, bool completed = true});
  Future<List<EnrollmentEntity>> getCourseStudents({required String courseId, int page = 1, int limit = 20});
  Future<List<CourseEntity>> getInstructorCourses({int page = 1, int limit = 20});
  Future<void> rateCourse({required String courseId, required int rating, String? review});
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  CourseRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<CourseEntity>> getCourses({
    int page = 1,
    int limit = 20,
    String? category,
    CourseLevel? level,
  }) async {
    final offset = (page - 1) * limit;

    var query = _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*),
          sections:course_sections(count),
          enrollments:enrollments(count)
        ''')
        .eq('is_published', true);

    if (category != null) {
      query = query.eq('category', category);
    }

    if (level != null) {
      query = query.eq('level', level.value);
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
          instructor:profiles!instructor_id(*),
          sections:course_sections(count),
          enrollments:enrollments(count)
        ''')
        .eq('is_published', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => _mapCourseFromJson(json)).toList();
  }

  @override
  Future<List<CourseEntity>> searchCourses({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;

    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*),
          sections:course_sections(count),
          enrollments:enrollments(count)
        ''')
        .eq('is_published', true)
        .or('title.ilike.%$query%,description.ilike.%$query%')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapCourseFromJson(json)).toList();
  }

  @override
  Future<CourseEntity> getCourseById(String courseId) async {
    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*),
          sections:course_sections(
            *,
            lessons:lessons(*)
          ),
          enrollments:enrollments(count)
        ''')
        .eq('id', courseId)
        .single();

    return _mapCourseFromJson(response);
  }

  @override
  Future<CourseEntity> createCourse({
    required String title,
    required String description,
    required double price,
    String? category,
    CourseLevel? level,
    String? thumbnailUrl,
  }) async {
    final response = await _supabase
        .from('courses')
        .insert({
          'instructor_id': _currentUserId,
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'level': level?.value ?? CourseLevel.beginner.value,
          'thumbnail_url': thumbnailUrl,
          'is_published': false,
        })
        .select('''
          *,
          instructor:profiles!instructor_id(*),
          sections:course_sections(count),
          enrollments:enrollments(count)
        ''')
        .single();

    return _mapCourseFromJson(response);
  }

  @override
  Future<CourseEntity> updateCourse({
    required String courseId,
    String? title,
    String? description,
    double? price,
    String? category,
    CourseLevel? level,
    String? thumbnailUrl,
    bool? isPublished,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (price != null) updateData['price'] = price;
    if (category != null) updateData['category'] = category;
    if (level != null) updateData['level'] = level.value;
    if (thumbnailUrl != null) updateData['thumbnail_url'] = thumbnailUrl;
    if (isPublished != null) updateData['is_published'] = isPublished;

    final response = await _supabase
        .from('courses')
        .update(updateData)
        .eq('id', courseId)
        .select('''
          *,
          instructor:profiles!instructor_id(*),
          sections:course_sections(count),
          enrollments:enrollments(count)
        ''')
        .single();

    return _mapCourseFromJson(response);
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _supabase.from('courses').delete().eq('id', courseId);
  }

  @override
  Future<List<CourseSectionEntity>> getCourseSections(String courseId) async {
    final response = await _supabase
        .from('course_sections')
        .select('''
          *,
          lessons:lessons(*)
        ''')
        .eq('course_id', courseId)
        .order('order_index');

    return (response as List).map((json) => _mapSectionFromJson(json)).toList();
  }

  @override
  Future<CourseSectionEntity> createSection({
    required String courseId,
    required String title,
    int? orderIndex,
  }) async {
    final response = await _supabase
        .from('course_sections')
        .insert({
          'course_id': courseId,
          'title': title,
          'order_index': orderIndex ?? 0,
        })
        .select()
        .single();

    return _mapSectionFromJson(response);
  }

  @override
  Future<CourseSectionEntity> updateSection({
    required String sectionId,
    String? title,
    int? orderIndex,
  }) async {
    final updateData = <String, dynamic>{};
    if (title != null) updateData['title'] = title;
    if (orderIndex != null) updateData['order_index'] = orderIndex;

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
  Future<List<LessonEntity>> getLessons(String sectionId) async {
    final response = await _supabase
        .from('lessons')
        .select()
        .eq('section_id', sectionId)
        .order('order_index');

    return (response as List).map((json) => _mapLessonFromJson(json)).toList();
  }

  @override
  Future<LessonEntity> createLesson({
    required String sectionId,
    required String title,
    required LessonType type,
    String? content,
    String? videoUrl,
    int? durationMinutes,
    int? orderIndex,
  }) async {
    final response = await _supabase
        .from('lessons')
        .insert({
          'section_id': sectionId,
          'title': title,
          'type': type.value,
          'content': content,
          'video_url': videoUrl,
          'duration_minutes': durationMinutes ?? 0,
          'order_index': orderIndex ?? 0,
        })
        .select()
        .single();

    return _mapLessonFromJson(response);
  }

  @override
  Future<LessonEntity> updateLesson({
    required String lessonId,
    String? title,
    LessonType? type,
    String? content,
    String? videoUrl,
    int? durationMinutes,
    int? orderIndex,
  }) async {
    final updateData = <String, dynamic>{};
    if (title != null) updateData['title'] = title;
    if (type != null) updateData['type'] = type.value;
    if (content != null) updateData['content'] = content;
    if (videoUrl != null) updateData['video_url'] = videoUrl;
    if (durationMinutes != null) updateData['duration_minutes'] = durationMinutes;
    if (orderIndex != null) updateData['order_index'] = orderIndex;

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
  Future<EnrollmentEntity> enrollInCourse(String courseId) async {
    final response = await _supabase
        .from('enrollments')
        .insert({
          'course_id': courseId,
          'user_id': _currentUserId,
          'status': EnrollmentStatus.active.value,
          'progress_percentage': 0,
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
  Future<List<EnrollmentEntity>> getMyEnrollments({
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;

    final response = await _supabase
        .from('enrollments')
        .select('''
          *,
          course:courses(
            *,
            instructor:profiles!instructor_id(*)
          )
        ''')
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapEnrollmentFromJson(json)).toList();
  }

  @override
  Future<EnrollmentEntity> getEnrollment(String courseId) async {
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
        .single();

    return _mapEnrollmentFromJson(response);
  }

  @override
  Future<void> updateProgress({
    required String enrollmentId,
    required String lessonId,
    bool completed = true,
  }) async {
    await _supabase.from('lesson_progress').upsert({
      'enrollment_id': enrollmentId,
      'lesson_id': lessonId,
      'completed': completed,
      'completed_at': completed ? DateTime.now().toIso8601String() : null,
    });

    await _supabase.rpc('update_enrollment_progress', params: {
      'p_enrollment_id': enrollmentId,
    });
  }

  @override
  Future<List<EnrollmentEntity>> getCourseStudents({
    required String courseId,
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;

    final response = await _supabase
        .from('enrollments')
        .select('''
          *,
          user:profiles!user_id(*)
        ''')
        .eq('course_id', courseId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapEnrollmentFromJson(json)).toList();
  }

  @override
  Future<List<CourseEntity>> getInstructorCourses({
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;

    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(*),
          sections:course_sections(count),
          enrollments:enrollments(count)
        ''')
        .eq('instructor_id', _currentUserId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapCourseFromJson(json)).toList();
  }

  @override
  Future<void> rateCourse({
    required String courseId,
    required int rating,
    String? review,
  }) async {
    await _supabase.from('course_ratings').upsert({
      'course_id': courseId,
      'user_id': _currentUserId,
      'rating': rating,
      'review': review,
    });
  }

  CourseEntity _mapCourseFromJson(Map<String, dynamic> json) {
    final sectionsData = json['sections'];
    int sectionsCount = 0;
    List<CourseSectionEntity> sections = [];

    if (sectionsData is List) {
      if (sectionsData.isNotEmpty && sectionsData.first is Map) {
        sections = sectionsData.map((s) => _mapSectionFromJson(s as Map<String, dynamic>)).toList();
        sectionsCount = sections.length;
      } else if (sectionsData.isNotEmpty && sectionsData.first['count'] != null) {
        sectionsCount = sectionsData.first['count'] as int;
      }
    }

    final enrollmentsData = json['enrollments'] as List? ?? [];
    final enrollmentsCount = enrollmentsData.isNotEmpty
        ? (enrollmentsData.first['count'] ?? 0) as int
        : 0;

    return CourseEntity(
      id: json['id'] as String,
      instructorId: json['instructor_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null ? (json['discount_price'] as num).toDouble() : null,
      category: json['category'] as String?,
      level: CourseLevel.fromString(json['level'] as String? ?? 'beginner'),
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      lessonsCount: json['lessons_count'] as int? ?? 0,
      studentsCount: enrollmentsCount,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: json['ratings_count'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      instructorName: json['instructor']?['full_name'] as String?,
      instructorAvatar: json['instructor']?['avatar_url'] as String?,
      sections: sections,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  CourseSectionEntity _mapSectionFromJson(Map<String, dynamic> json) {
    final lessonsData = json['lessons'] as List? ?? [];
    final lessons = lessonsData.map((l) => _mapLessonFromJson(l as Map<String, dynamic>)).toList();

    return CourseSectionEntity(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      lessons: lessons,
    );
  }

  LessonEntity _mapLessonFromJson(Map<String, dynamic> json) {
    return LessonEntity(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      type: LessonType.fromString(json['type'] as String? ?? 'video'),
      content: json['content'] as String?,
      videoUrl: json['video_url'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      orderIndex: json['order_index'] as int? ?? 0,
      isFree: json['is_free'] as bool? ?? false,
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
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      currentLessonId: json['current_lesson_id'] as String?,
      completedLessonsIds: List<String>.from(json['completed_lessons_ids'] ?? []),
      course: course,
      enrolledAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }
}
