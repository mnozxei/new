import '../../domain/entities/instructor_entity.dart';

class InstructorModel extends InstructorEntity {
  const InstructorModel({
    required super.id,
    required super.userId,
    required super.type,
    super.companyId,
    super.headline,
    super.biography,
    super.specializations,
    super.qualifications,
    super.socialLinks,
    super.portfolioUrl,
    super.videoIntroUrl,
    super.verificationStatus,
    super.verificationDocuments,
    super.verificationSubmittedAt,
    super.verificationReviewedAt,
    super.verificationReviewedBy,
    super.verificationNotes,
    super.isActive,
    super.isFeatured,
    super.rating,
    super.reviewCount,
    super.studentCount,
    super.courseCount,
    super.totalRevenue,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: InstructorType.fromString(json['type'] as String? ?? 'user'),
      companyId: json['company_id'] as String?,
      headline: json['headline'] as String?,
      biography: json['biography'] as String?,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      qualifications: (json['qualifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      socialLinks: (json['social_links'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      portfolioUrl: json['portfolio_url'] as String?,
      videoIntroUrl: json['video_intro_url'] as String?,
      verificationStatus: InstructorVerificationStatus.fromString(
          json['verification_status'] as String? ?? 'unverified'),
      verificationDocuments:
          (json['verification_documents'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as String)) ??
              {},
      verificationSubmittedAt: json['verification_submitted_at'] != null
          ? DateTime.parse(json['verification_submitted_at'] as String)
          : null,
      verificationReviewedAt: json['verification_reviewed_at'] != null
          ? DateTime.parse(json['verification_reviewed_at'] as String)
          : null,
      verificationReviewedBy: json['verification_reviewed_by'] as String?,
      verificationNotes: json['verification_notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      studentCount: json['student_count'] as int? ?? 0,
      courseCount: json['course_count'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'company_id': companyId,
      'headline': headline,
      'biography': biography,
      'specializations': specializations,
      'qualifications': qualifications,
      'social_links': socialLinks,
      'portfolio_url': portfolioUrl,
      'video_intro_url': videoIntroUrl,
      'verification_status': verificationStatus.value,
      'verification_documents': verificationDocuments,
      'verification_submitted_at': verificationSubmittedAt?.toIso8601String(),
      'verification_reviewed_at': verificationReviewedAt?.toIso8601String(),
      'verification_reviewed_by': verificationReviewedBy,
      'verification_notes': verificationNotes,
      'is_active': isActive,
      'is_featured': isFeatured,
      'rating': rating,
      'review_count': reviewCount,
      'student_count': studentCount,
      'course_count': courseCount,
      'total_revenue': totalRevenue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory InstructorModel.fromEntity(InstructorEntity entity) {
    return InstructorModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      companyId: entity.companyId,
      headline: entity.headline,
      biography: entity.biography,
      specializations: entity.specializations,
      qualifications: entity.qualifications,
      socialLinks: entity.socialLinks,
      portfolioUrl: entity.portfolioUrl,
      videoIntroUrl: entity.videoIntroUrl,
      verificationStatus: entity.verificationStatus,
      verificationDocuments: entity.verificationDocuments,
      verificationSubmittedAt: entity.verificationSubmittedAt,
      verificationReviewedAt: entity.verificationReviewedAt,
      verificationReviewedBy: entity.verificationReviewedBy,
      verificationNotes: entity.verificationNotes,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      studentCount: entity.studentCount,
      courseCount: entity.courseCount,
      totalRevenue: entity.totalRevenue,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
