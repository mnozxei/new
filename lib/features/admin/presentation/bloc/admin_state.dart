part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// Loading state for dashboard/lists
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// Loading state for moderation operations
class AdminOperationLoading extends AdminState {
  const AdminOperationLoading();
}

/// Dashboard loaded with stats and recent activity
class AdminDashboardLoaded extends AdminState {
  const AdminDashboardLoaded({
    required this.stats,
    required this.recentActivity,
    required this.pendingVerifications,
  });

  final AdminStats stats;
  final List<ActivityLog> recentActivity;
  final List<VerificationRequest> pendingVerifications;

  @override
  List<Object?> get props => [stats, recentActivity, pendingVerifications];
}

/// Pending verifications loaded
class PendingVerificationsLoaded extends AdminState {
  const PendingVerificationsLoaded(this.verifications);

  final List<VerificationRequest> verifications;

  @override
  List<Object?> get props => [verifications];
}

/// Verification approved successfully
class VerificationApproved extends AdminState {
  const VerificationApproved(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Verification rejected successfully
class VerificationRejected extends AdminState {
  const VerificationRejected(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Pending courses loaded
class PendingCoursesLoaded extends AdminState {
  const PendingCoursesLoaded(this.courses);

  final List<PendingCourseReview> courses;

  @override
  List<Object?> get props => [courses];
}

/// Course approved successfully
class CourseApprovedState extends AdminState {
  const CourseApprovedState(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Course rejected successfully
class CourseRejectedState extends AdminState {
  const CourseRejectedState(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Content reports loaded
class ContentReportsLoaded extends AdminState {
  const ContentReportsLoaded(this.reports);

  final List<ContentReport> reports;

  @override
  List<Object?> get props => [reports];
}

/// Report resolved successfully
class ReportResolved extends AdminState {
  const ReportResolved(this.reportId);

  final String reportId;

  @override
  List<Object?> get props => [reportId];
}

/// Report dismissed successfully
class ReportDismissed extends AdminState {
  const ReportDismissed(this.reportId);

  final String reportId;

  @override
  List<Object?> get props => [reportId];
}

/// User suspended successfully
class UserSuspended extends AdminState {
  const UserSuspended(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// User unsuspended successfully
class UserUnsuspended extends AdminState {
  const UserUnsuspended(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// User deleted successfully
class UserDeletedState extends AdminState {
  const UserDeletedState(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Company suspended successfully
class CompanySuspended extends AdminState {
  const CompanySuspended(this.companyId);

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Company unsuspended successfully
class CompanyUnsuspended extends AdminState {
  const CompanyUnsuspended(this.companyId);

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Course unpublished successfully
class CourseUnpublishedState extends AdminState {
  const CourseUnpublishedState(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Course deleted successfully
class CourseDeletedState extends AdminState {
  const CourseDeletedState(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Error state
class AdminError extends AdminState {
  const AdminError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
