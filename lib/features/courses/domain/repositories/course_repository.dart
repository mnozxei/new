import '../entities/course_entity.dart';

abstract class CourseRepository {
  /// Get published courses with filters
  Future<List<CourseEntity>> getCourses({
    String? category,
    CourseLevel? level,
    bool? isFree,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  /// Get featured courses
  Future<List<CourseEntity>> getFeaturedCourses({int limit = 10});

  /// Get course by ID with full details
  Future<CourseEntity?> getCourseById(String id);

  /// Get course with sections and lessons
  Future<CourseEntity?> getCourseWithContent(String id);

  /// Get instructor's courses
  Future<List<CourseEntity>> getInstructorCourses(String instructorId);

  /// Get my courses (as instructor)
  Future<List<CourseEntity>> getMyCourses();

  /// Create a new course
  Future<CourseEntity> createCourse(CreateCourseParams params);

  /// Update course
  Future<CourseEntity> updateCourse(String id, UpdateCourseParams params);

  /// Delete course
  Future<void> deleteCourse(String id);

  /// Publish/unpublish course
  Future<CourseEntity> togglePublish(String id);

  /// Upload course thumbnail
  Future<String> uploadThumbnail(String courseId, dynamic file);

  /// Create section
  Future<CourseSectionEntity> createSection(CreateSectionParams params);

  /// Update section
  Future<CourseSectionEntity> updateSection(
      String sectionId, UpdateSectionParams params);

  /// Delete section
  Future<void> deleteSection(String sectionId);

  /// Reorder sections
  Future<void> reorderSections(String courseId, List<String> sectionIds);

  /// Create lesson
  Future<LessonEntity> createLesson(CreateLessonParams params);

  /// Update lesson
  Future<LessonEntity> updateLesson(String lessonId, UpdateLessonParams params);

  /// Delete lesson
  Future<void> deleteLesson(String lessonId);

  /// Reorder lessons
  Future<void> reorderLessons(String sectionId, List<String> lessonIds);

  /// Check if enrolled
  Future<bool> isEnrolled(String courseId);

  /// Get enrollment
  Future<EnrollmentEntity?> getEnrollment(String courseId);

  /// Get my enrollments
  Future<List<EnrollmentEntity>> getMyEnrollments({
    EnrollmentStatus? status,
    int limit = 20,
    int offset = 0,
  });

  /// Enroll in course
  Future<EnrollmentEntity> enrollInCourse(String courseId, {String? paymentId});

  /// Update lesson progress
  Future<LessonProgressEntity> updateLessonProgress(
    String lessonId, {
    int? watchTimeSeconds,
    int? lastPositionSeconds,
    bool? isCompleted,
  });

  /// Get lesson progress
  Future<LessonProgressEntity?> getLessonProgress(String lessonId);

  /// Mark lesson as complete
  Future<void> markLessonComplete(String lessonId);

  /// Get course reviews
  Future<List<CourseReviewEntity>> getCourseReviews(
    String courseId, {
    int limit = 20,
    int offset = 0,
  });

  /// Add review
  Future<CourseReviewEntity> addReview(AddReviewParams params);

  /// Update review
  Future<CourseReviewEntity> updateReview(String reviewId, int rating,
      {String? comment});

  /// Delete review
  Future<void> deleteReview(String reviewId);

  /// Get instructor stats
  Future<InstructorStats> getInstructorStats();

  /// Get course stats
  Future<CourseStats> getCourseStats(String courseId);
}

class CreateCourseParams {
  const CreateCourseParams({
    required this.title,
    this.description,
    this.shortDescription,
    this.level = CourseLevel.beginner,
    this.category,
    this.subcategory,
    this.language = 'ar',
    this.price = 0,
    this.currency = 'SAR',
    this.isFree = false,
    this.requirements = const [],
    this.objectives = const [],
    this.tags = const [],
  });

  final String title;
  final String? description;
  final String? shortDescription;
  final CourseLevel level;
  final String? category;
  final String? subcategory;
  final String language;
  final double price;
  final String currency;
  final bool isFree;
  final List<String> requirements;
  final List<String> objectives;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (shortDescription != null) 'short_description': shortDescription,
        'level': level.value,
        if (category != null) 'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        'language': language,
        'price': price,
        'currency': currency,
        'is_free': isFree,
        'requirements': requirements,
        'objectives': objectives,
        'tags': tags,
      };
}

class UpdateCourseParams {
  const UpdateCourseParams({
    this.title,
    this.description,
    this.shortDescription,
    this.level,
    this.category,
    this.subcategory,
    this.language,
    this.price,
    this.currency,
    this.isFree,
    this.requirements,
    this.objectives,
    this.tags,
  });

  final String? title;
  final String? description;
  final String? shortDescription;
  final CourseLevel? level;
  final String? category;
  final String? subcategory;
  final String? language;
  final double? price;
  final String? currency;
  final bool? isFree;
  final List<String>? requirements;
  final List<String>? objectives;
  final List<String>? tags;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (shortDescription != null) json['short_description'] = shortDescription;
    if (level != null) json['level'] = level!.value;
    if (category != null) json['category'] = category;
    if (subcategory != null) json['subcategory'] = subcategory;
    if (language != null) json['language'] = language;
    if (price != null) json['price'] = price;
    if (currency != null) json['currency'] = currency;
    if (isFree != null) json['is_free'] = isFree;
    if (requirements != null) json['requirements'] = requirements;
    if (objectives != null) json['objectives'] = objectives;
    if (tags != null) json['tags'] = tags;
    return json;
  }
}

class CreateSectionParams {
  const CreateSectionParams({
    required this.courseId,
    required this.title,
    this.description,
  });

  final String courseId;
  final String title;
  final String? description;
}

class UpdateSectionParams {
  const UpdateSectionParams({
    this.title,
    this.description,
  });

  final String? title;
  final String? description;
}

class CreateLessonParams {
  const CreateLessonParams({
    required this.sectionId,
    required this.courseId,
    required this.title,
    this.description,
    this.contentType = 'video',
    this.videoUrl,
    this.durationSeconds = 0,
    this.content,
    this.isFreePreview = false,
  });

  final String sectionId;
  final String courseId;
  final String title;
  final String? description;
  final String contentType;
  final String? videoUrl;
  final int durationSeconds;
  final String? content;
  final bool isFreePreview;
}

class UpdateLessonParams {
  const UpdateLessonParams({
    this.title,
    this.description,
    this.contentType,
    this.videoUrl,
    this.durationSeconds,
    this.content,
    this.isFreePreview,
  });

  final String? title;
  final String? description;
  final String? contentType;
  final String? videoUrl;
  final int? durationSeconds;
  final String? content;
  final bool? isFreePreview;
}

class AddReviewParams {
  const AddReviewParams({
    required this.courseId,
    required this.rating,
    this.comment,
  });

  final String courseId;
  final int rating;
  final String? comment;
}

class InstructorStats {
  const InstructorStats({
    this.totalCourses = 0,
    this.totalStudents = 0,
    this.totalRevenue = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  final int totalCourses;
  final int totalStudents;
  final double totalRevenue;
  final double averageRating;
  final int totalReviews;
}

class CourseStats {
  const CourseStats({
    this.enrollments = 0,
    this.completions = 0,
    this.revenue = 0,
    this.averageProgress = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  final int enrollments;
  final int completions;
  final double revenue;
  final double averageProgress;
  final double averageRating;
  final int totalReviews;
}
