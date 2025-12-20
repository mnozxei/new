import 'package:equatable/equatable.dart';

import '../../../../core/utils/youtube_helper.dart';

/// Course publish state for instructor workflow
enum CoursePublishState {
  draft('draft', 'مسودة'),
  pendingReview('pending_review', 'قيد المراجعة'),
  published('published', 'منشور'),
  unpublished('unpublished', 'غير منشور'),
  rejected('rejected', 'مرفوض');

  const CoursePublishState(this.value, this.label);
  final String value;
  final String label;

  static CoursePublishState fromString(String value) {
    return CoursePublishState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CoursePublishState.draft,
    );
  }

  bool get isDraft => this == CoursePublishState.draft;
  bool get isPendingReview => this == CoursePublishState.pendingReview;
  bool get isPublished => this == CoursePublishState.published;
  bool get isUnpublished => this == CoursePublishState.unpublished;
  bool get isRejected => this == CoursePublishState.rejected;
  bool get canEdit => isDraft || isRejected || isUnpublished;
  bool get canPublish => isDraft || isRejected || isUnpublished;
}

/// Lesson content type enum
enum LessonContentType {
  video('video', 'فيديو'),
  text('text', 'نص'),
  quiz('quiz', 'اختبار');

  const LessonContentType(this.value, this.label);
  final String value;
  final String label;

  static LessonContentType fromString(String value) {
    return LessonContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LessonContentType.video,
    );
  }
}

enum CourseLevel {
  beginner('beginner', 'مبتدئ'),
  intermediate('intermediate', 'متوسط'),
  advanced('advanced', 'متقدم'),
  allLevels('all', 'جميع المستويات');

  const CourseLevel(this.value, this.label);
  final String value;
  final String label;

  static CourseLevel fromString(String value) {
    return CourseLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CourseLevel.beginner,
    );
  }

  /// Get selectable course levels (excluding allLevels for course creation)
  static List<CourseLevel> get selectableLevels => [beginner, intermediate, advanced];
}

enum EnrollmentStatus {
  active('active', 'نشط'),
  completed('completed', 'مكتمل'),
  paused('paused', 'متوقف'),
  refunded('refunded', 'مسترد');

  const EnrollmentStatus(this.value, this.label);
  final String value;
  final String label;

  static EnrollmentStatus fromString(String value) {
    return EnrollmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EnrollmentStatus.active,
    );
  }
}

class CourseEntity extends Equatable {
  const CourseEntity({
    required this.id,
    required this.instructorId,
    required this.title,
    this.description,
    this.shortDescription,
    this.thumbnailUrl,
    this.previewVideoUrl,
    this.level = CourseLevel.beginner,
    this.category,
    this.subcategory,
    this.language = 'ar',
    this.price = 0,
    this.currency = 'SAR',
    this.isFree = false,
    this.isPublished = false,
    this.publishState = CoursePublishState.draft,
    this.isFeatured = false,
    this.durationMinutes = 0,
    this.lessonCount = 0,
    this.enrollmentCount = 0,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.requirements = const [],
    this.objectives = const [],
    this.tags = const [],
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.instructor,
    this.sections,
  });

  final String id;
  final String instructorId;
  final String title;
  final String? description;
  final String? shortDescription;
  final String? thumbnailUrl;
  final String? previewVideoUrl;
  final CourseLevel level;
  final String? category;
  final String? subcategory;
  final String language;
  final double price;
  final String currency;
  final bool isFree;
  final bool isPublished;
  final CoursePublishState publishState;
  final bool isFeatured;
  final int durationMinutes;
  final int lessonCount;
  final int enrollmentCount;
  final double ratingAverage;
  final int ratingCount;
  final List<String> requirements;
  final List<String> objectives;
  final List<String> tags;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final InstructorInfo? instructor;
  final List<CourseSectionEntity>? sections;

  /// Check if course can be edited
  bool get canEdit => publishState.canEdit;

  /// Check if course can be published
  bool get canPublish => publishState.canPublish && hasRequiredContent;

  /// Check if course has minimum required content
  bool get hasRequiredContent {
    if (title.isEmpty) return false;
    if (sections == null || sections!.isEmpty) return false;
    // Must have at least one lesson
    final totalLessons = sections!.fold<int>(0, (sum, s) => sum + s.lessons.length);
    return totalLessons > 0;
  }

  /// Check if course has a final quiz
  bool get hasFinalQuiz => true; // Determined by actual quiz check at runtime

  /// Check if course awards a certificate
  bool get hasCertificate => true; // Courses typically award certificates on completion

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      return '$hours ساعة';
    } else {
      return '$minutes دقيقة';
    }
  }

  String get formattedPrice {
    if (isFree || price == 0) {
      return 'مجاني';
    }
    return '${price.toStringAsFixed(0)} $currency';
  }

  CourseEntity copyWith({
    String? id,
    String? instructorId,
    String? title,
    String? description,
    String? shortDescription,
    String? thumbnailUrl,
    String? previewVideoUrl,
    CourseLevel? level,
    String? category,
    String? subcategory,
    String? language,
    double? price,
    String? currency,
    bool? isFree,
    bool? isPublished,
    CoursePublishState? publishState,
    bool? isFeatured,
    int? durationMinutes,
    int? lessonCount,
    int? enrollmentCount,
    double? ratingAverage,
    int? ratingCount,
    List<String>? requirements,
    List<String>? objectives,
    List<String>? tags,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    InstructorInfo? instructor,
    List<CourseSectionEntity>? sections,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      instructorId: instructorId ?? this.instructorId,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      previewVideoUrl: previewVideoUrl ?? this.previewVideoUrl,
      level: level ?? this.level,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      language: language ?? this.language,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isFree: isFree ?? this.isFree,
      isPublished: isPublished ?? this.isPublished,
      publishState: publishState ?? this.publishState,
      isFeatured: isFeatured ?? this.isFeatured,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lessonCount: lessonCount ?? this.lessonCount,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      requirements: requirements ?? this.requirements,
      objectives: objectives ?? this.objectives,
      tags: tags ?? this.tags,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      instructor: instructor ?? this.instructor,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
        id,
        instructorId,
        title,
        description,
        shortDescription,
        thumbnailUrl,
        previewVideoUrl,
        level,
        category,
        subcategory,
        language,
        price,
        currency,
        isFree,
        isPublished,
        publishState,
        isFeatured,
        durationMinutes,
        lessonCount,
        enrollmentCount,
        ratingAverage,
        ratingCount,
        requirements,
        objectives,
        tags,
        rejectionReason,
        createdAt,
        updatedAt,
        publishedAt,
        instructor,
        sections,
      ];
}

class InstructorInfo extends Equatable {
  const InstructorInfo({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.headline,
    this.courseCount = 0,
    this.studentCount = 0,
    this.rating = 0,
    this.isVerified = false,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? headline;
  final int courseCount;
  final int studentCount;
  final double rating;
  final bool isVerified;

  @override
  List<Object?> get props => [
        id,
        fullName,
        avatarUrl,
        headline,
        courseCount,
        studentCount,
        rating,
        isVerified,
      ];
}

class CourseSectionEntity extends Equatable {
  const CourseSectionEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lessons = const [],
  });

  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<LessonEntity> lessons;

  int get totalDurationSeconds =>
      lessons.fold(0, (sum, lesson) => sum + lesson.durationSeconds);

  String get formattedDuration {
    final totalMinutes = totalDurationSeconds ~/ 60;
    return '$totalMinutes دقيقة';
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        orderIndex,
        createdAt,
        updatedAt,
        lessons,
      ];
}

class LessonEntity extends Equatable {
  const LessonEntity({
    required this.id,
    required this.sectionId,
    required this.courseId,
    required this.title,
    this.description,
    this.contentType = 'video',
    this.videoUrl,
    this.durationSeconds = 0,
    this.content,
    this.isFreePreview = false,
    this.orderIndex = 0,
    this.isLocked = false,
    this.unlockAfterLessonId,
    this.requiresQuizPass = false,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.hasQuiz = false,
    this.quizPassed = false,
    this.quizId,
  });

  final String id;
  final String sectionId;
  final String courseId;
  final String title;
  final String? description;
  final String contentType;
  final String? videoUrl;
  final int durationSeconds;
  final String? content;
  final bool isFreePreview;
  final int orderIndex;
  final bool isLocked;
  final String? unlockAfterLessonId;
  final bool requiresQuizPass;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final bool hasQuiz;
  final bool quizPassed;
  final String? quizId;

  /// Check if lesson is unlocked (either not locked, or free preview)
  bool get isUnlocked => !isLocked || isFreePreview;

  /// Check if this is a video lesson
  bool get isVideo => contentType == 'video' || contentType == LessonContentType.video.value;

  /// Check if video URL is a valid YouTube URL
  bool get hasValidYouTubeUrl =>
      videoUrl != null && YouTubeHelper.isValidYouTubeUrl(videoUrl!);

  /// Get the YouTube video ID if URL is valid
  String? get youTubeVideoId =>
      videoUrl != null ? YouTubeHelper.extractVideoId(videoUrl!) : null;

  /// Get the YouTube embed URL
  String? get youTubeEmbedUrl =>
      videoUrl != null ? YouTubeHelper.getEmbedUrl(videoUrl!) : null;

  /// Get the YouTube thumbnail URL
  String? get youTubeThumbnailUrl =>
      videoUrl != null ? YouTubeHelper.getThumbnailUrl(videoUrl!) : null;

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  LessonEntity copyWith({
    String? id,
    String? sectionId,
    String? courseId,
    String? title,
    String? description,
    String? contentType,
    String? videoUrl,
    int? durationSeconds,
    String? content,
    bool? isFreePreview,
    int? orderIndex,
    bool? isLocked,
    String? unlockAfterLessonId,
    bool? requiresQuizPass,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    bool? hasQuiz,
    bool? quizPassed,
    String? quizId,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      videoUrl: videoUrl ?? this.videoUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      content: content ?? this.content,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      orderIndex: orderIndex ?? this.orderIndex,
      isLocked: isLocked ?? this.isLocked,
      unlockAfterLessonId: unlockAfterLessonId ?? this.unlockAfterLessonId,
      requiresQuizPass: requiresQuizPass ?? this.requiresQuizPass,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      hasQuiz: hasQuiz ?? this.hasQuiz,
      quizPassed: quizPassed ?? this.quizPassed,
      quizId: quizId ?? this.quizId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sectionId,
        courseId,
        title,
        description,
        contentType,
        videoUrl,
        durationSeconds,
        content,
        isFreePreview,
        orderIndex,
        isLocked,
        unlockAfterLessonId,
        requiresQuizPass,
        createdAt,
        updatedAt,
        isCompleted,
        hasQuiz,
        quizPassed,
        quizId,
      ];
}

class EnrollmentEntity extends Equatable {
  const EnrollmentEntity({
    required this.id,
    required this.courseId,
    required this.userId,
    this.status = EnrollmentStatus.active,
    this.progressPercent = 0,
    this.completedLessons = const [],
    this.currentLessonId,
    required this.enrolledAt,
    this.completedAt,
    this.certificateUrl,
    this.paymentId,
    this.amountPaid = 0,
    this.course,
  });

  final String id;
  final String courseId;
  final String userId;
  final EnrollmentStatus status;
  final int progressPercent;
  final List<String> completedLessons;
  final String? currentLessonId;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final String? certificateUrl;
  final String? paymentId;
  final double amountPaid;
  final CourseEntity? course;

  bool get isCompleted => status == EnrollmentStatus.completed;
  bool get isActive => status == EnrollmentStatus.active;

  EnrollmentEntity copyWith({
    String? id,
    String? courseId,
    String? userId,
    EnrollmentStatus? status,
    int? progressPercent,
    List<String>? completedLessons,
    String? currentLessonId,
    DateTime? enrolledAt,
    DateTime? completedAt,
    String? certificateUrl,
    String? paymentId,
    double? amountPaid,
    CourseEntity? course,
  }) {
    return EnrollmentEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      completedLessons: completedLessons ?? this.completedLessons,
      currentLessonId: currentLessonId ?? this.currentLessonId,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completedAt: completedAt ?? this.completedAt,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      paymentId: paymentId ?? this.paymentId,
      amountPaid: amountPaid ?? this.amountPaid,
      course: course ?? this.course,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        userId,
        status,
        progressPercent,
        completedLessons,
        currentLessonId,
        enrolledAt,
        completedAt,
        certificateUrl,
        paymentId,
        amountPaid,
        course,
      ];
}

class LessonProgressEntity extends Equatable {
  const LessonProgressEntity({
    required this.id,
    required this.enrollmentId,
    required this.lessonId,
    required this.userId,
    this.isCompleted = false,
    this.watchTimeSeconds = 0,
    this.lastPositionSeconds = 0,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String enrollmentId;
  final String lessonId;
  final String userId;
  final bool isCompleted;
  final int watchTimeSeconds;
  final int lastPositionSeconds;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        enrollmentId,
        lessonId,
        userId,
        isCompleted,
        watchTimeSeconds,
        lastPositionSeconds,
        completedAt,
        createdAt,
        updatedAt,
      ];
}

class CourseReviewEntity extends Equatable {
  const CourseReviewEntity({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.rating,
    this.comment,
    this.isVisible = true,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  final String id;
  final String courseId;
  final String userId;
  final int rating;
  final String? comment;
  final bool isVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewUserInfo? user;

  @override
  List<Object?> get props => [
        id,
        courseId,
        userId,
        rating,
        comment,
        isVisible,
        createdAt,
        updatedAt,
        user,
      ];
}

class ReviewUserInfo extends Equatable {
  const ReviewUserInfo({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, fullName, avatarUrl];
}
