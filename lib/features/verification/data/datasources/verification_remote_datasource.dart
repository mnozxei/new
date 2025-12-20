import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';
import '../models/verification_models.dart';

abstract class VerificationRemoteDataSource {
  // Instructor applications
  Future<InstructorApplicationModel?> getMyInstructorApplication();
  Future<InstructorApplicationModel> submitInstructorApplication({
    required String bio,
    required List<String> expertiseAreas,
    required int yearsOfExperience,
    String? portfolioUrl,
    String? linkedinUrl,
  });
  Future<InstructorApplicationModel> updateInstructorApplication({
    required String applicationId,
    required Map<String, dynamic> updates,
  });
  Future<void> withdrawInstructorApplication(String applicationId);

  // Company verifications
  Future<CompanyVerificationModel?> getCompanyVerification(String companyId);
  Future<CompanyVerificationModel> submitCompanyVerification({
    required String companyId,
    String? companyType,
    String? employeeCountRange,
    String? industry,
    String? websiteUrl,
  });
  Future<CompanyVerificationModel> updateCompanyVerification({
    required String verificationId,
    required Map<String, dynamic> updates,
  });

  // Documents
  Future<VerificationDocumentModel> uploadDocument({
    required File file,
    required DocumentType documentType,
    String? applicationId,
    String? verificationId,
    String? companyId,
    DateTime? expiryDate,
  });
  Future<List<VerificationDocumentModel>> getApplicationDocuments(String applicationId);
  Future<List<VerificationDocumentModel>> getCompanyDocuments(String verificationId);
  Future<void> deleteDocument(String documentId);
  Future<VerificationDocumentModel> replaceDocument({
    required String documentId,
    required File newFile,
    DateTime? newExpiryDate,
  });

  // Admin operations
  Future<List<InstructorApplicationModel>> getPendingInstructorApplications({
    int limit = 20,
    int offset = 0,
  });
  Future<List<CompanyVerificationModel>> getPendingCompanyVerifications({
    int limit = 20,
    int offset = 0,
  });
  Future<InstructorApplicationModel> reviewInstructorApplication({
    required String applicationId,
    required VerificationStatus status,
    String? reason,
    String? adminNotes,
  });
  Future<CompanyVerificationModel> reviewCompanyVerification({
    required String verificationId,
    required VerificationStatus status,
    String? reason,
    String? adminNotes,
  });

  // Status queries
  Future<VerificationStatus> getMyVerificationStatus();
  Future<VerificationStatus> getCompanyVerificationStatus(String companyId);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  VerificationRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;
  static const _uuid = Uuid();

  String get _currentUserId => _client.auth.currentUser?.id ?? '';

  // ==================== Instructor Applications ====================

  @override
  Future<InstructorApplicationModel?> getMyInstructorApplication() async {
    final response = await _client
        .from('instructor_applications')
        .select('*, documents:verification_documents(*)')
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return InstructorApplicationModel.fromJson(response);
  }

  @override
  Future<InstructorApplicationModel> submitInstructorApplication({
    required String bio,
    required List<String> expertiseAreas,
    required int yearsOfExperience,
    String? portfolioUrl,
    String? linkedinUrl,
  }) async {
    final now = DateTime.now();
    final data = {
      'user_id': _currentUserId,
      'status': VerificationStatus.pending.value,
      'bio': bio,
      'expertise_areas': expertiseAreas,
      'years_of_experience': yearsOfExperience,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedinUrl,
      'submitted_at': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _client
        .from('instructor_applications')
        .insert(data)
        .select('*, documents:verification_documents(*)')
        .single();

    return InstructorApplicationModel.fromJson(response);
  }

  @override
  Future<InstructorApplicationModel> updateInstructorApplication({
    required String applicationId,
    required Map<String, dynamic> updates,
  }) async {
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from('instructor_applications')
        .update(updates)
        .eq('id', applicationId)
        .eq('user_id', _currentUserId)
        .select('*, documents:verification_documents(*)')
        .single();

    return InstructorApplicationModel.fromJson(response);
  }

  @override
  Future<void> withdrawInstructorApplication(String applicationId) async {
    await _client
        .from('instructor_applications')
        .update({
          'status': VerificationStatus.notSubmitted.value,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', applicationId)
        .eq('user_id', _currentUserId);
  }

  // ==================== Company Verifications ====================

  @override
  Future<CompanyVerificationModel?> getCompanyVerification(String companyId) async {
    final response = await _client
        .from('company_verifications')
        .select('*, documents:verification_documents(*)')
        .eq('company_id', companyId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return CompanyVerificationModel.fromJson(response);
  }

  @override
  Future<CompanyVerificationModel> submitCompanyVerification({
    required String companyId,
    String? companyType,
    String? employeeCountRange,
    String? industry,
    String? websiteUrl,
  }) async {
    final now = DateTime.now();
    final data = {
      'company_id': companyId,
      'submitted_by': _currentUserId,
      'status': VerificationStatus.pending.value,
      'company_type': companyType,
      'employee_count_range': employeeCountRange,
      'industry': industry,
      'website_url': websiteUrl,
      'submitted_at': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _client
        .from('company_verifications')
        .insert(data)
        .select('*, documents:verification_documents(*)')
        .single();

    return CompanyVerificationModel.fromJson(response);
  }

  @override
  Future<CompanyVerificationModel> updateCompanyVerification({
    required String verificationId,
    required Map<String, dynamic> updates,
  }) async {
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from('company_verifications')
        .update(updates)
        .eq('id', verificationId)
        .select('*, documents:verification_documents(*)')
        .single();

    return CompanyVerificationModel.fromJson(response);
  }

  // ==================== Document Management ====================

  @override
  Future<VerificationDocumentModel> uploadDocument({
    required File file,
    required DocumentType documentType,
    String? applicationId,
    String? verificationId,
    String? companyId,
    DateTime? expiryDate,
  }) async {
    final filename = path.basename(file.path);
    final extension = path.extension(filename);
    final storagePath = 'verifications/$_currentUserId/${_uuid.v4()}$extension';

    // Upload to storage
    await _client.storage
        .from('documents')
        .upload(storagePath, file);

    // Get file info
    final bytes = await file.readAsBytes();
    final fileSize = bytes.length;
    final mimeType = _getMimeType(extension);

    final now = DateTime.now();
    final data = {
      'application_id': applicationId,
      'verification_id': verificationId,
      'user_id': _currentUserId,
      'company_id': companyId,
      'document_type': documentType.value,
      'storage_path': storagePath,
      'original_filename': filename,
      'file_size': fileSize,
      'mime_type': mimeType,
      'version': 1,
      'expiry_date': expiryDate?.toIso8601String(),
      'uploaded_at': now.toIso8601String(),
      'created_at': now.toIso8601String(),
    };

    final response = await _client
        .from('verification_documents')
        .insert(data)
        .select()
        .single();

    return VerificationDocumentModel.fromJson(response);
  }

  @override
  Future<List<VerificationDocumentModel>> getApplicationDocuments(String applicationId) async {
    final response = await _client
        .from('verification_documents')
        .select()
        .eq('application_id', applicationId)
        .order('created_at');

    return (response as List)
        .map((doc) => VerificationDocumentModel.fromJson(doc as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<VerificationDocumentModel>> getCompanyDocuments(String verificationId) async {
    final response = await _client
        .from('verification_documents')
        .select()
        .eq('verification_id', verificationId)
        .order('created_at');

    return (response as List)
        .map((doc) => VerificationDocumentModel.fromJson(doc as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    // Get document info first
    final doc = await _client
        .from('verification_documents')
        .select('storage_path')
        .eq('id', documentId)
        .eq('user_id', _currentUserId)
        .single();

    // Delete from storage
    await _client.storage
        .from('documents')
        .remove([doc['storage_path'] as String]);

    // Delete record
    await _client
        .from('verification_documents')
        .delete()
        .eq('id', documentId)
        .eq('user_id', _currentUserId);
  }

  @override
  Future<VerificationDocumentModel> replaceDocument({
    required String documentId,
    required File newFile,
    DateTime? newExpiryDate,
  }) async {
    // Get current document
    final currentDoc = await _client
        .from('verification_documents')
        .select()
        .eq('id', documentId)
        .eq('user_id', _currentUserId)
        .single();

    final currentModel = VerificationDocumentModel.fromJson(currentDoc);
    final currentVersion = currentModel.version;

    // Upload new file
    final filename = path.basename(newFile.path);
    final extension = path.extension(filename);
    final storagePath = 'verifications/$_currentUserId/${_uuid.v4()}$extension';

    await _client.storage
        .from('documents')
        .upload(storagePath, newFile);

    // Get new file info
    final bytes = await newFile.readAsBytes();
    final fileSize = bytes.length;
    final mimeType = _getMimeType(extension);

    // Update record with new version
    final now = DateTime.now();
    final response = await _client
        .from('verification_documents')
        .update({
          'storage_path': storagePath,
          'original_filename': filename,
          'file_size': fileSize,
          'mime_type': mimeType,
          'version': currentVersion + 1,
          'expiry_date': newExpiryDate?.toIso8601String() ?? currentModel.expiryDate?.toIso8601String(),
          'uploaded_at': now.toIso8601String(),
          'is_verified': false,
          'verified_at': null,
          'verified_by': null,
        })
        .eq('id', documentId)
        .select()
        .single();

    // Delete old file from storage
    try {
      await _client.storage
          .from('documents')
          .remove([currentModel.storagePath]);
    } catch (_) {
      // Ignore cleanup errors
    }

    return VerificationDocumentModel.fromJson(response);
  }

  // ==================== Admin Operations ====================

  @override
  Future<List<InstructorApplicationModel>> getPendingInstructorApplications({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('instructor_applications')
        .select('*, documents:verification_documents(*), user:profiles!user_id(*)')
        .eq('status', VerificationStatus.pending.value)
        .order('submitted_at')
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((app) => InstructorApplicationModel.fromJson(app as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CompanyVerificationModel>> getPendingCompanyVerifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('company_verifications')
        .select('*, documents:verification_documents(*), company:companies!company_id(*)')
        .eq('status', VerificationStatus.pending.value)
        .order('submitted_at')
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((ver) => CompanyVerificationModel.fromJson(ver as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InstructorApplicationModel> reviewInstructorApplication({
    required String applicationId,
    required VerificationStatus status,
    String? reason,
    String? adminNotes,
  }) async {
    final now = DateTime.now();
    final updates = {
      'status': status.value,
      'reviewed_at': now.toIso8601String(),
      'reviewer_id': _currentUserId,
      'updated_at': now.toIso8601String(),
    };

    if (reason != null) {
      updates['rejection_reason'] = reason;
    }
    if (adminNotes != null) {
      updates['admin_notes'] = adminNotes;
    }

    final response = await _client
        .from('instructor_applications')
        .update(updates)
        .eq('id', applicationId)
        .select('*, documents:verification_documents(*)')
        .single();

    // If approved, update user role
    if (status == VerificationStatus.approved) {
      final appData = InstructorApplicationModel.fromJson(response);
      await _client
          .from('profiles')
          .update({
            'role': 'userInstructor',
            'verification_status': VerificationStatus.approved.value,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', appData.userId);
    }

    return InstructorApplicationModel.fromJson(response);
  }

  @override
  Future<CompanyVerificationModel> reviewCompanyVerification({
    required String verificationId,
    required VerificationStatus status,
    String? reason,
    String? adminNotes,
  }) async {
    final now = DateTime.now();
    final updates = {
      'status': status.value,
      'reviewed_at': now.toIso8601String(),
      'reviewer_id': _currentUserId,
      'updated_at': now.toIso8601String(),
    };

    if (reason != null) {
      updates['rejection_reason'] = reason;
    }
    if (adminNotes != null) {
      updates['admin_notes'] = adminNotes;
    }

    final response = await _client
        .from('company_verifications')
        .update(updates)
        .eq('id', verificationId)
        .select('*, documents:verification_documents(*)')
        .single();

    // If approved, update company verification status
    if (status == VerificationStatus.approved) {
      final verData = CompanyVerificationModel.fromJson(response);
      await _client
          .from('companies')
          .update({
            'verification_status': VerificationStatus.approved.value,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', verData.companyId);
    }

    return CompanyVerificationModel.fromJson(response);
  }

  // ==================== Status Queries ====================

  @override
  Future<VerificationStatus> getMyVerificationStatus() async {
    final response = await _client
        .from('profiles')
        .select('verification_status')
        .eq('id', _currentUserId)
        .single();

    final statusStr = response['verification_status'] as String?;
    if (statusStr == null) return VerificationStatus.notSubmitted;
    return VerificationStatus.fromString(statusStr);
  }

  @override
  Future<VerificationStatus> getCompanyVerificationStatus(String companyId) async {
    final response = await _client
        .from('companies')
        .select('verification_status')
        .eq('id', companyId)
        .single();

    final statusStr = response['verification_status'] as String?;
    if (statusStr == null) return VerificationStatus.notSubmitted;
    return VerificationStatus.fromString(statusStr);
  }

  // ==================== Helpers ====================

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.svg':
        return 'image/svg+xml';
      default:
        return 'application/octet-stream';
    }
  }
}
