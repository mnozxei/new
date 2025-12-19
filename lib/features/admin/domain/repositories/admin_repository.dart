import '../entities/admin_entity.dart';

abstract class AdminRepository {
  // Dashboard
  Future<AdminStats> getAdminStats();
  Future<List<ActivityLog>> getRecentActivity({int limit = 10});

  // Verification Management
  Future<List<VerificationRequest>> getPendingVerifications({
    VerificationType? type,
    int limit = 20,
    int offset = 0,
  });
  Future<VerificationRequest?> getVerificationRequest(String id);
  Future<void> approveVerification(String id, {String? notes});
  Future<void> rejectVerification(String id, String reason);

  // Course Review
  Future<List<PendingCourseReview>> getPendingCourseReviews({
    int limit = 20,
    int offset = 0,
  });
  Future<void> approveCourse(String courseId);
  Future<void> rejectCourse(String courseId, String reason);

  // Content Reports
  Future<List<ContentReport>> getContentReports({
    String? status,
    String? contentType,
    int limit = 20,
    int offset = 0,
  });
  Future<ContentReport?> getContentReport(String id);
  Future<void> resolveReport(String id, String resolution);
  Future<void> dismissReport(String id, String reason);

  // User Management
  Future<void> suspendUser(String userId, String reason, {DateTime? until});
  Future<void> unsuspendUser(String userId);
  Future<void> deleteUser(String userId);

  // Company Management
  Future<void> suspendCompany(String companyId, String reason);
  Future<void> unsuspendCompany(String companyId);

  // Course Management
  Future<void> unpublishCourse(String courseId, String reason);
  Future<void> deleteCourse(String courseId);
}
