import 'package:equatable/equatable.dart';

enum CourseLevel {
  beginner('beginner', 'مبتدئ'),
  intermediate('intermediate', 'متوسط'),
  advanced('advanced', 'متقدم');

  const CourseLevel(this.value, this.label);
  final String value;
  final String label;

  static CourseLevel fromString(String value) {
    return CourseLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CourseLevel.beginner,
    );
  }
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
    this.isFeatured = false,
    this.durationMinutes = 0,
    this.lessonCount = 0,
    this.enrollmentCount = 0,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.requirements = const [],
    this.objectives = const [],
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
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
  final bool isFeatured;
  final int durationMinutes;
  final int lessonCount;
  final int enrollmentCount;
  final double ratingAverage;
  final int ratingCount;
  final List<String> requirements;
  final List<String> objectives;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final InstructorInfo? instructor;
  final List<CourseSectionEntity>? sections;

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
    bool? isFeatured,
    int? durationMinutes,
    int? lessonCount,
    int? enrollmentCount,
    double? ratingAverage,
    int? ratingCount,
    List<String>? requirements,
    List<String>? objectives,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      isFeatured: isFeatured ?? this.isFeatured,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lessonCount: lessonCount ?? this.lessonCount,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      requirements: requirements ?? this.requirements,
      objectives: objectives ?? this.objectives,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        isFeatured,
        durationMinutes,
        lessonCount,
        enrollmentCount,
        ratingAverage,
        ratingCount,
        requirements,
        objectives,
        tags,
        createdAt,
        updatedAt,
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
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? headline;
  final int courseCount;
  final int studentCount;
  final double rating;

  @override
  List<Object?> get props => [
        id,
        fullName,
        avatarUrl,
        headline,
        courseCount,
        studentCount,
        rating,
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
    required this.createdAt,
    required this.updatedAt,
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
  final DateTime createdAt;
  final DateTime updatedAt;

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
        createdAt,
        updatedAt,
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
