import 'package:equatable/equatable.dart';

/// Type of instructor
enum InstructorType {
  user('user'),
  company('company');

  const InstructorType(this.value);
  final String value;

  static InstructorType fromString(String value) {
    return InstructorType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InstructorType.user,
    );
  }

  String get displayName {
    switch (this) {
      case InstructorType.user:
        return 'مدرب مستقل';
      case InstructorType.company:
        return 'مدرب شركة';
    }
  }

  String get displayNameEn {
    switch (this) {
      case InstructorType.user:
        return 'Independent Instructor';
      case InstructorType.company:
        return 'Company Instructor';
    }
  }
}

/// Verification status for instructor
enum InstructorVerificationStatus {
  unverified('unverified'),
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  const InstructorVerificationStatus(this.value);
  final String value;

  static InstructorVerificationStatus fromString(String value) {
    return InstructorVerificationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InstructorVerificationStatus.unverified,
    );
  }
}

/// Instructor profile entity
class InstructorEntity extends Equatable {
  const InstructorEntity({
    required this.id,
    required this.userId,
    required this.type,
    this.companyId,
    this.headline,
    this.biography,
    this.specializations = const [],
    this.qualifications = const [],
    this.socialLinks = const {},
    this.portfolioUrl,
    this.videoIntroUrl,
    this.verificationStatus = InstructorVerificationStatus.unverified,
    this.verificationDocuments = const {},
    this.verificationSubmittedAt,
    this.verificationReviewedAt,
    this.verificationReviewedBy,
    this.verificationNotes,
    this.isActive = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.studentCount = 0,
    this.courseCount = 0,
    this.totalRevenue = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final InstructorType type;
  final String? companyId;
  final String? headline;
  final String? biography;
  final List<String> specializations;
  final List<String> qualifications;
  final Map<String, String> socialLinks;
  final String? portfolioUrl;
  final String? videoIntroUrl;
  final InstructorVerificationStatus verificationStatus;
  final Map<String, String> verificationDocuments;
  final DateTime? verificationSubmittedAt;
  final DateTime? verificationReviewedAt;
  final String? verificationReviewedBy;
  final String? verificationNotes;
  final bool isActive;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final int studentCount;
  final int courseCount;
  final double totalRevenue;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Check if instructor is verified
  bool get isVerified =>
      verificationStatus == InstructorVerificationStatus.verified;

  /// Check if verification is pending
  bool get isPendingVerification =>
      verificationStatus == InstructorVerificationStatus.pending;

  /// Check if instructor is a user instructor (independent)
  bool get isUserInstructor => type == InstructorType.user;

  /// Check if instructor is a company instructor
  bool get isCompanyInstructor => type == InstructorType.company;

  /// Check if instructor can publish courses (verified and active)
  bool get canPublishCourses => isVerified && isActive;

  InstructorEntity copyWith({
    String? id,
    String? userId,
    InstructorType? type,
    String? companyId,
    String? headline,
    String? biography,
    List<String>? specializations,
    List<String>? qualifications,
    Map<String, String>? socialLinks,
    String? portfolioUrl,
    String? videoIntroUrl,
    InstructorVerificationStatus? verificationStatus,
    Map<String, String>? verificationDocuments,
    DateTime? verificationSubmittedAt,
    DateTime? verificationReviewedAt,
    String? verificationReviewedBy,
    String? verificationNotes,
    bool? isActive,
    bool? isFeatured,
    double? rating,
    int? reviewCount,
    int? studentCount,
    int? courseCount,
    double? totalRevenue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstructorEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      companyId: companyId ?? this.companyId,
      headline: headline ?? this.headline,
      biography: biography ?? this.biography,
      specializations: specializations ?? this.specializations,
      qualifications: qualifications ?? this.qualifications,
      socialLinks: socialLinks ?? this.socialLinks,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      videoIntroUrl: videoIntroUrl ?? this.videoIntroUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
      verificationSubmittedAt:
          verificationSubmittedAt ?? this.verificationSubmittedAt,
      verificationReviewedAt:
          verificationReviewedAt ?? this.verificationReviewedAt,
      verificationReviewedBy:
          verificationReviewedBy ?? this.verificationReviewedBy,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      studentCount: studentCount ?? this.studentCount,
      courseCount: courseCount ?? this.courseCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        companyId,
        headline,
        biography,
        specializations,
        qualifications,
        socialLinks,
        portfolioUrl,
        videoIntroUrl,
        verificationStatus,
        verificationDocuments,
        verificationSubmittedAt,
        verificationReviewedAt,
        verificationReviewedBy,
        verificationNotes,
        isActive,
        isFeatured,
        rating,
        reviewCount,
        studentCount,
        courseCount,
        totalRevenue,
        createdAt,
        updatedAt,
      ];
}
