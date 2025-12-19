part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Load admin dashboard with stats, activity, and verifications
class LoadAdminDashboard extends AdminEvent {
  const LoadAdminDashboard();
}

/// Load pending verifications
class LoadPendingVerifications extends AdminEvent {
  const LoadPendingVerifications({
    this.type,
    this.limit = 20,
    this.offset = 0,
  });

  final VerificationType? type;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [type, limit, offset];
}

/// Approve a verification request
class ApproveVerification extends AdminEvent {
  const ApproveVerification(this.id, {this.notes});

  final String id;
  final String? notes;

  @override
  List<Object?> get props => [id, notes];
}

/// Reject a verification request
class RejectVerification extends AdminEvent {
  const RejectVerification(this.id, this.reason);

  final String id;
  final String reason;

  @override
  List<Object?> get props => [id, reason];
}

/// Load pending course reviews
class LoadPendingCourses extends AdminEvent {
  const LoadPendingCourses({
    this.limit = 20,
    this.offset = 0,
  });

  final int limit;
  final int offset;

  @override
  List<Object?> get props => [limit, offset];
}

/// Approve a course for publication
class ApproveCourse extends AdminEvent {
  const ApproveCourse(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Reject a course
class RejectCourse extends AdminEvent {
  const RejectCourse(this.courseId, this.reason);

  final String courseId;
  final String reason;

  @override
  List<Object?> get props => [courseId, reason];
}

/// Load content reports
class LoadContentReports extends AdminEvent {
  const LoadContentReports({
    this.status,
    this.contentType,
    this.limit = 20,
    this.offset = 0,
  });

  final String? status;
  final String? contentType;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [status, contentType, limit, offset];
}

/// Resolve a content report
class ResolveReport extends AdminEvent {
  const ResolveReport(this.reportId, this.resolution);

  final String reportId;
  final String resolution;

  @override
  List<Object?> get props => [reportId, resolution];
}

/// Dismiss a content report
class DismissReport extends AdminEvent {
  const DismissReport(this.reportId, this.reason);

  final String reportId;
  final String reason;

  @override
  List<Object?> get props => [reportId, reason];
}

/// Suspend a user
class SuspendUser extends AdminEvent {
  const SuspendUser({
    required this.userId,
    required this.reason,
    this.until,
  });

  final String userId;
  final String reason;
  final DateTime? until;

  @override
  List<Object?> get props => [userId, reason, until];
}

/// Unsuspend a user
class UnsuspendUser extends AdminEvent {
  const UnsuspendUser(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Delete a user
class DeleteUser extends AdminEvent {
  const DeleteUser(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Suspend a company
class SuspendCompany extends AdminEvent {
  const SuspendCompany(this.companyId, this.reason);

  final String companyId;
  final String reason;

  @override
  List<Object?> get props => [companyId, reason];
}

/// Unsuspend a company
class UnsuspendCompany extends AdminEvent {
  const UnsuspendCompany(this.companyId);

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Unpublish a course
class UnpublishCourse extends AdminEvent {
  const UnpublishCourse(this.courseId, this.reason);

  final String courseId;
  final String reason;

  @override
  List<Object?> get props => [courseId, reason];
}

/// Delete a course
class DeleteCourse extends AdminEvent {
  const DeleteCourse(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}
