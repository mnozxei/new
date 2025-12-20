import '../entities/profile_entity.dart';

class LearningStats {
  const LearningStats({
    this.enrolledCount = 0,
    this.inProgressCount = 0,
    this.completedCount = 0,
    this.certificatesCount = 0,
  });

  final int enrolledCount;
  final int inProgressCount;
  final int completedCount;
  final int certificatesCount;

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      enrolledCount: (json['enrolled_count'] as num?)?.toInt() ?? 0,
      inProgressCount: (json['in_progress_count'] as num?)?.toInt() ?? 0,
      completedCount: (json['completed_count'] as num?)?.toInt() ?? 0,
      certificatesCount: (json['certificates_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class CertificatePreview {
  const CertificatePreview({
    required this.id,
    required this.serialNumber,
    required this.courseName,
    required this.issuerName,
    required this.issuedAt,
    this.pdfUrl,
    this.status = 'issued',
  });

  final String id;
  final String serialNumber;
  final String courseName;
  final String issuerName;
  final DateTime issuedAt;
  final String? pdfUrl;
  final String status;

  factory CertificatePreview.fromJson(Map<String, dynamic> json) {
    return CertificatePreview(
      id: json['certificate_id'] as String,
      serialNumber: json['serial_number'] as String,
      courseName: json['course_name'] as String,
      issuerName: json['issuer_name'] as String? ?? 'Unknown',
      issuedAt: DateTime.parse(json['issued_at'] as String),
      pdfUrl: json['pdf_url'] as String?,
      status: json['status'] as String? ?? 'issued',
    );
  }
}

class CompletedCourse {
  const CompletedCourse({
    required this.courseId,
    required this.courseTitle,
    this.courseThumbnail,
    this.instructorName,
    required this.completedAt,
    this.certificateId,
    this.certificateSerial,
  });

  final String courseId;
  final String courseTitle;
  final String? courseThumbnail;
  final String? instructorName;
  final DateTime completedAt;
  final String? certificateId;
  final String? certificateSerial;

  factory CompletedCourse.fromJson(Map<String, dynamic> json) {
    return CompletedCourse(
      courseId: json['course_id'] as String,
      courseTitle: json['course_title'] as String,
      courseThumbnail: json['course_thumbnail'] as String?,
      instructorName: json['instructor_name'] as String?,
      completedAt: DateTime.parse(json['completed_at'] as String),
      certificateId: json['certificate_id'] as String?,
      certificateSerial: json['certificate_serial'] as String?,
    );
  }
}

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);

  Future<ProfileEntity> updateProfile(ProfileEntity profile);

  Future<String> uploadAvatar(String userId, String filePath);

  Future<String> uploadCoverImage(String userId, String filePath);

  Future<void> deleteAvatar(String userId);

  Future<void> deleteCoverImage(String userId);

  Future<void> followUser(String userId, String targetUserId);

  Future<void> unfollowUser(String userId, String targetUserId);

  Future<bool> isFollowing(String userId, String targetUserId);

  Future<List<ProfileEntity>> getFollowers(String userId, {int limit, int offset});

  Future<List<ProfileEntity>> getFollowing(String userId, {int limit, int offset});

  Future<List<ProfileEntity>> searchProfiles(String query, {int limit, int offset});

  // Experience CRUD
  Future<List<ExperienceEntity>> getExperiences(String userId);

  Future<ExperienceEntity> addExperience(String userId, ExperienceEntity experience);

  Future<ExperienceEntity> updateExperience(String userId, ExperienceEntity experience);

  Future<void> deleteExperience(String userId, String experienceId);

  // Learning stats and certificates
  Future<LearningStats> getLearningStats(String userId);

  Future<List<CertificatePreview>> getCertificates(String userId, {int limit, int offset});

  Future<List<CompletedCourse>> getCompletedCourses(String userId, {int limit, int offset});
}
