import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl({required AdminRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AdminRemoteDataSource _remoteDataSource;

  @override
  Future<AdminStats> getAdminStats() async {
    return _remoteDataSource.getAdminStats();
  }

  @override
  Future<List<ActivityLog>> getRecentActivity({int limit = 10}) async {
    return _remoteDataSource.getRecentActivity(limit: limit);
  }

  @override
  Future<List<VerificationRequest>> getPendingVerifications({
    VerificationType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getPendingVerifications(
      type: type,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<VerificationRequest?> getVerificationRequest(String id) async {
    return _remoteDataSource.getVerificationRequest(id);
  }

  @override
  Future<void> approveVerification(String id, {String? notes}) async {
    await _remoteDataSource.approveVerification(id, notes: notes);
  }

  @override
  Future<void> rejectVerification(String id, String reason) async {
    await _remoteDataSource.rejectVerification(id, reason);
  }

  @override
  Future<List<PendingCourseReview>> getPendingCourseReviews({
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getPendingCourseReviews(limit: limit, offset: offset);
  }

  @override
  Future<void> approveCourse(String courseId) async {
    await _remoteDataSource.approveCourse(courseId);
  }

  @override
  Future<void> rejectCourse(String courseId, String reason) async {
    await _remoteDataSource.rejectCourse(courseId, reason);
  }

  @override
  Future<List<ContentReport>> getContentReports({
    String? status,
    String? contentType,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getContentReports(
      status: status,
      contentType: contentType,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<ContentReport?> getContentReport(String id) async {
    return _remoteDataSource.getContentReport(id);
  }

  @override
  Future<void> resolveReport(String id, String resolution) async {
    await _remoteDataSource.resolveReport(id, resolution);
  }

  @override
  Future<void> dismissReport(String id, String reason) async {
    await _remoteDataSource.dismissReport(id, reason);
  }

  @override
  Future<void> suspendUser(String userId, String reason, {DateTime? until}) async {
    await _remoteDataSource.suspendUser(userId, reason, until: until);
  }

  @override
  Future<void> unsuspendUser(String userId) async {
    await _remoteDataSource.unsuspendUser(userId);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _remoteDataSource.deleteUser(userId);
  }

  @override
  Future<void> suspendCompany(String companyId, String reason) async {
    await _remoteDataSource.suspendCompany(companyId, reason);
  }

  @override
  Future<void> unsuspendCompany(String companyId) async {
    await _remoteDataSource.unsuspendCompany(companyId);
  }

  @override
  Future<void> unpublishCourse(String courseId, String reason) async {
    await _remoteDataSource.unpublishCourse(courseId, reason);
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _remoteDataSource.deleteCourse(courseId);
  }
}
