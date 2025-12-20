import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/admin_entity.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStats> getAdminStats();
  Future<List<ActivityLog>> getRecentActivity({int limit = 10});
  Future<List<VerificationRequest>> getPendingVerifications({
    VerificationType? type,
    int limit = 20,
    int offset = 0,
  });
  Future<VerificationRequest?> getVerificationRequest(String id);
  Future<void> approveVerification(String id, {String? notes});
  Future<void> rejectVerification(String id, String reason);
  Future<List<PendingCourseReview>> getPendingCourseReviews({
    int limit = 20,
    int offset = 0,
  });
  Future<void> approveCourse(String courseId);
  Future<void> rejectCourse(String courseId, String reason);
  Future<List<ContentReport>> getContentReports({
    String? status,
    String? contentType,
    int limit = 20,
    int offset = 0,
  });
  Future<ContentReport?> getContentReport(String id);
  Future<void> resolveReport(String id, String resolution);
  Future<void> dismissReport(String id, String reason);
  Future<void> suspendUser(String userId, String reason, {DateTime? until});
  Future<void> unsuspendUser(String userId);
  Future<void> deleteUser(String userId);
  Future<void> suspendCompany(String companyId, String reason);
  Future<void> unsuspendCompany(String companyId);
  Future<void> unpublishCourse(String courseId, String reason);
  Future<void> deleteCourse(String courseId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  AdminRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser?.id ?? '';

  @override
  Future<AdminStats> getAdminStats() async {
    // Get counts from various tables
    final usersCount = await _supabase.from('profiles').select('id').count();
    final companiesCount = await _supabase.from('companies').select('id').count();
    final coursesCount = await _supabase.from('courses').select('id').count();
    final jobsCount = await _supabase.from('jobs').select('id').count();

    final pendingInstructorCount = await _supabase
        .from('instructor_verifications')
        .select('id')
        .eq('status', 'pending')
        .count();

    final pendingCompanyCount = await _supabase
        .from('companies')
        .select('id')
        .eq('verification_status', 'pending')
        .count();

    final pendingCourseCount = await _supabase
        .from('courses')
        .select('id')
        .eq('publish_state', 'pendingReview')
        .count();

    final activeReportsCount = await _supabase
        .from('content_reports')
        .select('id')
        .eq('status', 'pending')
        .count();

    return AdminStats(
      totalUsers: usersCount.count ?? 0,
      totalCompanies: companiesCount.count ?? 0,
      totalCourses: coursesCount.count ?? 0,
      totalJobs: jobsCount.count ?? 0,
      pendingInstructorVerifications: pendingInstructorCount.count ?? 0,
      pendingCompanyVerifications: pendingCompanyCount.count ?? 0,
      pendingCourseReviews: pendingCourseCount.count ?? 0,
      activeReports: activeReportsCount.count ?? 0,
    );
  }

  @override
  Future<List<ActivityLog>> getRecentActivity({int limit = 10}) async {
    final response = await _supabase
        .from('activity_logs')
        .select('''
          *,
          actor:profiles!actor_id(full_name)
        ''')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => _mapActivityLogFromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<VerificationRequest>> getPendingVerifications({
    VerificationType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    List<VerificationRequest> results = [];

    // Instructor verifications
    if (type == null || type == VerificationType.instructor) {
      final instructorResponse = await _supabase
          .from('instructor_verifications')
          .select('''
            *,
            user:profiles!user_id(full_name, email)
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      results.addAll((instructorResponse as List).map((json) {
        final user = json['user'] as Map<String, dynamic>?;
        return VerificationRequest(
          id: json['id'] as String,
          userId: json['user_id'] as String,
          type: VerificationType.instructor,
          status: json['status'] as String,
          userName: user?['full_name'] as String?,
          userEmail: user?['email'] as String?,
          documentUrls: List<String>.from((json['document_urls'] ?? []) as List),
          notes: json['notes'] as String?,
          rejectionReason: json['rejection_reason'] as String?,
          createdAt: DateTime.parse(json['created_at'] as String),
        );
      }));
    }

    // Company verifications
    if (type == null || type == VerificationType.company) {
      final companyResponse = await _supabase
          .from('companies')
          .select('''
            *,
            owner:profiles!owner_id(full_name, email)
          ''')
          .eq('verification_status', 'pending')
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      results.addAll((companyResponse as List).map((json) {
        final owner = json['owner'] as Map<String, dynamic>?;
        return VerificationRequest(
          id: json['id'] as String,
          userId: json['owner_id'] as String,
          type: VerificationType.company,
          status: json['verification_status'] as String,
          companyId: json['id'] as String,
          companyName: json['name'] as String?,
          userName: owner?['full_name'] as String?,
          userEmail: owner?['email'] as String?,
          documentUrls: List<String>.from((json['verification_documents'] ?? []) as List),
          createdAt: DateTime.parse(json['created_at'] as String),
        );
      }));
    }

    // Sort by created date
    results.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return results;
  }

  @override
  Future<VerificationRequest?> getVerificationRequest(String id) async {
    // Try instructor verifications first
    var response = await _supabase
        .from('instructor_verifications')
        .select('''
          *,
          user:profiles!user_id(full_name, email)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response != null) {
      final user = response['user'] as Map<String, dynamic>?;
      return VerificationRequest(
        id: response['id'] as String,
        userId: response['user_id'] as String,
        type: VerificationType.instructor,
        status: response['status'] as String,
        userName: user?['full_name'] as String?,
        userEmail: user?['email'] as String?,
        documentUrls: List<String>.from(response['document_urls'] ?? []),
        notes: response['notes'] as String?,
        rejectionReason: response['rejection_reason'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    }

    // Try companies
    response = await _supabase
        .from('companies')
        .select('''
          *,
          owner:profiles!owner_id(full_name, email)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response != null) {
      final owner = response['owner'] as Map<String, dynamic>?;
      return VerificationRequest(
        id: response['id'] as String,
        userId: response['owner_id'] as String,
        type: VerificationType.company,
        status: response['verification_status'] as String,
        companyId: response['id'] as String,
        companyName: response['name'] as String?,
        userName: owner?['full_name'] as String?,
        userEmail: owner?['email'] as String?,
        documentUrls: List<String>.from((response['verification_documents'] ?? []) as List),
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    }

    return null;
  }

  @override
  Future<void> approveVerification(String id, {String? notes}) async {
    final now = DateTime.now();

    // Try instructor verifications first
    final instructorResponse = await _supabase
        .from('instructor_verifications')
        .select('user_id')
        .eq('id', id)
        .maybeSingle();

    if (instructorResponse != null) {
      await _supabase
          .from('instructor_verifications')
          .update({
            'status': 'approved',
            'notes': notes,
            'reviewed_by': _currentUserId,
            'reviewed_at': now.toIso8601String(),
          })
          .eq('id', id);

      // Update user role to userInstructor
      await _supabase
          .from('profiles')
          .update({'role': 'userInstructor'})
          .eq('id', instructorResponse['user_id'] as Object);

      await _logActivity('approve_instructor_verification', 'verification', id);
      return;
    }

    // Try companies
    await _supabase
        .from('companies')
        .update({
          'verification_status': 'approved',
          'verified_at': now.toIso8601String(),
        })
        .eq('id', id);

    await _logActivity('approve_company_verification', 'company', id);
  }

  @override
  Future<void> rejectVerification(String id, String reason) async {
    final now = DateTime.now();

    // Try instructor verifications first
    final instructorResponse = await _supabase
        .from('instructor_verifications')
        .select('id')
        .eq('id', id)
        .maybeSingle();

    if (instructorResponse != null) {
      await _supabase
          .from('instructor_verifications')
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'reviewed_by': _currentUserId,
            'reviewed_at': now.toIso8601String(),
          })
          .eq('id', id);

      await _logActivity('reject_instructor_verification', 'verification', id);
      return;
    }

    // Try companies
    await _supabase
        .from('companies')
        .update({
          'verification_status': 'rejected',
          'rejection_reason': reason,
        })
        .eq('id', id);

    await _logActivity('reject_company_verification', 'company', id);
  }

  @override
  Future<List<PendingCourseReview>> getPendingCourseReviews({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(full_name),
          sections:course_sections(
            lessons:lessons(id)
          ),
          quizzes(id)
        ''')
        .eq('publish_state', 'pendingReview')
        .order('updated_at', ascending: true)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) {
      final instructor = json['instructor'] as Map<String, dynamic>?;
      final sections = json['sections'] as List? ?? [];
      final quizzes = json['quizzes'] as List? ?? [];

      int lessonCount = 0;
      for (final section in sections) {
        final lessons = section['lessons'] as List? ?? [];
        lessonCount += lessons.length;
      }

      return PendingCourseReview(
        id: json['id'] as String,
        courseId: json['id'] as String,
        courseTitle: json['title'] as String,
        instructorId: json['instructor_id'] as String,
        instructorName: instructor?['full_name'] as String?,
        thumbnailUrl: json['thumbnail_url'] as String?,
        lessonCount: lessonCount,
        quizCount: quizzes.length,
        submittedAt: DateTime.parse(json['updated_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> approveCourse(String courseId) async {
    final now = DateTime.now();
    await _supabase
        .from('courses')
        .update({
          'publish_state': 'published',
          'is_published': true,
          'published_at': now.toIso8601String(),
        })
        .eq('id', courseId);

    await _logActivity('approve_course', 'course', courseId);
  }

  @override
  Future<void> rejectCourse(String courseId, String reason) async {
    await _supabase
        .from('courses')
        .update({
          'publish_state': 'rejected',
          'rejection_reason': reason,
        })
        .eq('id', courseId);

    await _logActivity('reject_course', 'course', courseId);
  }

  @override
  Future<List<ContentReport>> getContentReports({
    String? status,
    String? contentType,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _supabase
        .from('content_reports')
        .select('''
          *,
          reporter:profiles!reporter_id(full_name)
        ''');

    if (status != null) {
      query = query.eq('status', status);
    }
    if (contentType != null) {
      query = query.eq('content_type', contentType);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapContentReportFromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ContentReport?> getContentReport(String id) async {
    final response = await _supabase
        .from('content_reports')
        .select('''
          *,
          reporter:profiles!reporter_id(full_name)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapContentReportFromJson(response);
  }

  @override
  Future<void> resolveReport(String id, String resolution) async {
    final now = DateTime.now();
    await _supabase
        .from('content_reports')
        .update({
          'status': 'resolved',
          'resolution': resolution,
          'resolved_by': _currentUserId,
          'resolved_at': now.toIso8601String(),
        })
        .eq('id', id);

    await _logActivity('resolve_report', 'report', id);
  }

  @override
  Future<void> dismissReport(String id, String reason) async {
    final now = DateTime.now();
    await _supabase
        .from('content_reports')
        .update({
          'status': 'dismissed',
          'resolution': reason,
          'resolved_by': _currentUserId,
          'resolved_at': now.toIso8601String(),
        })
        .eq('id', id);

    await _logActivity('dismiss_report', 'report', id);
  }

  @override
  Future<void> suspendUser(String userId, String reason, {DateTime? until}) async {
    await _supabase
        .from('profiles')
        .update({
          'is_suspended': true,
          'suspended_reason': reason,
          'suspended_until': until?.toIso8601String(),
        })
        .eq('id', userId);

    await _logActivity('suspend_user', 'user', userId);
  }

  @override
  Future<void> unsuspendUser(String userId) async {
    await _supabase
        .from('profiles')
        .update({
          'is_suspended': false,
          'suspended_reason': null,
          'suspended_until': null,
        })
        .eq('id', userId);

    await _logActivity('unsuspend_user', 'user', userId);
  }

  @override
  Future<void> deleteUser(String userId) async {
    // Soft delete - mark as deleted
    await _supabase
        .from('profiles')
        .update({
          'is_deleted': true,
          'deleted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    await _logActivity('delete_user', 'user', userId);
  }

  @override
  Future<void> suspendCompany(String companyId, String reason) async {
    await _supabase
        .from('companies')
        .update({
          'is_suspended': true,
          'suspended_reason': reason,
        })
        .eq('id', companyId);

    await _logActivity('suspend_company', 'company', companyId);
  }

  @override
  Future<void> unsuspendCompany(String companyId) async {
    await _supabase
        .from('companies')
        .update({
          'is_suspended': false,
          'suspended_reason': null,
        })
        .eq('id', companyId);

    await _logActivity('unsuspend_company', 'company', companyId);
  }

  @override
  Future<void> unpublishCourse(String courseId, String reason) async {
    await _supabase
        .from('courses')
        .update({
          'publish_state': 'unpublished',
          'is_published': false,
          'rejection_reason': reason,
        })
        .eq('id', courseId);

    await _logActivity('unpublish_course', 'course', courseId);
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    // Soft delete
    await _supabase
        .from('courses')
        .update({
          'is_deleted': true,
          'deleted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', courseId);

    await _logActivity('delete_course', 'course', courseId);
  }

  Future<void> _logActivity(String action, String targetType, String targetId) async {
    await _supabase.from('activity_logs').insert({
      'actor_id': _currentUserId,
      'action': action,
      'target_type': targetType,
      'target_id': targetId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  ActivityLog _mapActivityLogFromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    return ActivityLog(
      id: json['id'] as String,
      actorId: json['actor_id'] as String,
      action: json['action'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      actorName: actor?['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ContentReport _mapContentReportFromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;
    return ContentReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      contentType: json['content_type'] as String,
      contentId: json['content_id'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      reporterName: reporter?['full_name'] as String?,
      contentTitle: json['content_title'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolution: json['resolution'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
