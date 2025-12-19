import 'package:equatable/equatable.dart';

/// Admin dashboard statistics
class AdminStats extends Equatable {
  const AdminStats({
    this.totalUsers = 0,
    this.totalCompanies = 0,
    this.totalCourses = 0,
    this.totalJobs = 0,
    this.pendingInstructorVerifications = 0,
    this.pendingCompanyVerifications = 0,
    this.pendingCourseReviews = 0,
    this.activeReports = 0,
    this.userGrowthPercent = 0,
    this.companyGrowthPercent = 0,
    this.courseGrowthPercent = 0,
    this.jobGrowthPercent = 0,
  });

  final int totalUsers;
  final int totalCompanies;
  final int totalCourses;
  final int totalJobs;
  final int pendingInstructorVerifications;
  final int pendingCompanyVerifications;
  final int pendingCourseReviews;
  final int activeReports;
  final double userGrowthPercent;
  final double companyGrowthPercent;
  final double courseGrowthPercent;
  final double jobGrowthPercent;

  @override
  List<Object?> get props => [
        totalUsers,
        totalCompanies,
        totalCourses,
        totalJobs,
        pendingInstructorVerifications,
        pendingCompanyVerifications,
        pendingCourseReviews,
        activeReports,
        userGrowthPercent,
        companyGrowthPercent,
        courseGrowthPercent,
        jobGrowthPercent,
      ];
}

/// Verification request type
enum VerificationType {
  instructor,
  company;

  static VerificationType fromString(String value) {
    return VerificationType.values.firstWhere(
      (v) => v.name == value,
      orElse: () => VerificationType.instructor,
    );
  }
}

/// Verification request entity
class VerificationRequest extends Equatable {
  const VerificationRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.companyId,
    this.companyName,
    this.userName,
    this.userEmail,
    this.documentUrls = const [],
    this.notes,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final VerificationType type;
  final String status; // pending, approved, rejected
  final String? companyId;
  final String? companyName;
  final String? userName;
  final String? userEmail;
  final List<String> documentUrls;
  final String? notes;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        status,
        companyId,
        companyName,
        userName,
        userEmail,
        documentUrls,
        notes,
        rejectionReason,
        reviewedBy,
        reviewedAt,
        createdAt,
        updatedAt,
      ];
}

/// Course pending review
class PendingCourseReview extends Equatable {
  const PendingCourseReview({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.instructorId,
    this.instructorName,
    this.thumbnailUrl,
    this.lessonCount = 0,
    this.quizCount = 0,
    required this.submittedAt,
  });

  final String id;
  final String courseId;
  final String courseTitle;
  final String instructorId;
  final String? instructorName;
  final String? thumbnailUrl;
  final int lessonCount;
  final int quizCount;
  final DateTime submittedAt;

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseTitle,
        instructorId,
        instructorName,
        thumbnailUrl,
        lessonCount,
        quizCount,
        submittedAt,
      ];
}

/// Report/complaint entity
class ContentReport extends Equatable {
  const ContentReport({
    required this.id,
    required this.reporterId,
    required this.contentType,
    required this.contentId,
    required this.reason,
    this.description,
    this.status = 'pending',
    this.reporterName,
    this.contentTitle,
    this.resolvedBy,
    this.resolvedAt,
    this.resolution,
    required this.createdAt,
  });

  final String id;
  final String reporterId;
  final String contentType; // course, job, post, user, company
  final String contentId;
  final String reason;
  final String? description;
  final String status; // pending, reviewed, resolved, dismissed
  final String? reporterName;
  final String? contentTitle;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolution;
  final DateTime createdAt;

  bool get isPending => status == 'pending';
  bool get isResolved => status == 'resolved';

  @override
  List<Object?> get props => [
        id,
        reporterId,
        contentType,
        contentId,
        reason,
        description,
        status,
        reporterName,
        contentTitle,
        resolvedBy,
        resolvedAt,
        resolution,
        createdAt,
      ];
}

/// Activity log entry
class ActivityLog extends Equatable {
  const ActivityLog({
    required this.id,
    required this.actorId,
    required this.action,
    required this.targetType,
    this.targetId,
    this.details,
    this.actorName,
    required this.createdAt,
  });

  final String id;
  final String actorId;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, dynamic>? details;
  final String? actorName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        actorId,
        action,
        targetType,
        targetId,
        details,
        actorName,
        createdAt,
      ];
}
