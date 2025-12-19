import 'dart:io';

import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_datasource.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl(this._dataSource);

  final VerificationRemoteDataSource _dataSource;

  // ==================== Instructor Verification ====================

  @override
  Future<InstructorApplication?> getMyInstructorApplication() async {
    try {
      return await _dataSource.getMyInstructorApplication();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<VerificationResult<InstructorApplication>> submitInstructorApplication({
    required String bio,
    required List<String> expertiseAreas,
    required int yearsOfExperience,
    String? portfolioUrl,
    String? linkedinUrl,
  }) async {
    try {
      final result = await _dataSource.submitInstructorApplication(
        bio: bio,
        expertiseAreas: expertiseAreas,
        yearsOfExperience: yearsOfExperience,
        portfolioUrl: portfolioUrl,
        linkedinUrl: linkedinUrl,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<InstructorApplication>> updateInstructorApplication({
    required String applicationId,
    String? bio,
    List<String>? expertiseAreas,
    int? yearsOfExperience,
    String? portfolioUrl,
    String? linkedinUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (bio != null) updates['bio'] = bio;
      if (expertiseAreas != null) updates['expertise_areas'] = expertiseAreas;
      if (yearsOfExperience != null) updates['years_of_experience'] = yearsOfExperience;
      if (portfolioUrl != null) updates['portfolio_url'] = portfolioUrl;
      if (linkedinUrl != null) updates['linkedin_url'] = linkedinUrl;

      final result = await _dataSource.updateInstructorApplication(
        applicationId: applicationId,
        updates: updates,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<void>> withdrawInstructorApplication(String applicationId) async {
    try {
      await _dataSource.withdrawInstructorApplication(applicationId);
      return VerificationResult.success(null);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  // ==================== Company Verification ====================

  @override
  Future<CompanyVerificationRequest?> getCompanyVerification(String companyId) async {
    try {
      return await _dataSource.getCompanyVerification(companyId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<VerificationResult<CompanyVerificationRequest>> submitCompanyVerification({
    required String companyId,
    String? companyType,
    String? employeeCountRange,
    String? industry,
    String? websiteUrl,
  }) async {
    try {
      final result = await _dataSource.submitCompanyVerification(
        companyId: companyId,
        companyType: companyType,
        employeeCountRange: employeeCountRange,
        industry: industry,
        websiteUrl: websiteUrl,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<CompanyVerificationRequest>> updateCompanyVerification({
    required String verificationId,
    String? companyType,
    String? employeeCountRange,
    String? industry,
    String? websiteUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (companyType != null) updates['company_type'] = companyType;
      if (employeeCountRange != null) updates['employee_count_range'] = employeeCountRange;
      if (industry != null) updates['industry'] = industry;
      if (websiteUrl != null) updates['website_url'] = websiteUrl;

      final result = await _dataSource.updateCompanyVerification(
        verificationId: verificationId,
        updates: updates,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  // ==================== Document Management ====================

  @override
  Future<VerificationResult<VerificationDocument>> uploadDocument({
    required File file,
    required DocumentType documentType,
    String? applicationId,
    String? verificationId,
    String? companyId,
    DateTime? expiryDate,
  }) async {
    try {
      final result = await _dataSource.uploadDocument(
        file: file,
        documentType: documentType,
        applicationId: applicationId,
        verificationId: verificationId,
        companyId: companyId,
        expiryDate: expiryDate,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<List<VerificationDocument>> getApplicationDocuments(String applicationId) async {
    try {
      return await _dataSource.getApplicationDocuments(applicationId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<VerificationDocument>> getCompanyDocuments(String verificationId) async {
    try {
      return await _dataSource.getCompanyDocuments(verificationId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<VerificationResult<void>> deleteDocument(String documentId) async {
    try {
      await _dataSource.deleteDocument(documentId);
      return VerificationResult.success(null);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<VerificationDocument>> replaceDocument({
    required String documentId,
    required File newFile,
    DateTime? newExpiryDate,
  }) async {
    try {
      final result = await _dataSource.replaceDocument(
        documentId: documentId,
        newFile: newFile,
        newExpiryDate: newExpiryDate,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  // ==================== Admin Operations ====================

  @override
  Future<List<InstructorApplication>> getPendingInstructorApplications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _dataSource.getPendingInstructorApplications(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CompanyVerificationRequest>> getPendingCompanyVerifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _dataSource.getPendingCompanyVerifications(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<VerificationResult<InstructorApplication>> approveInstructorApplication({
    required String applicationId,
    String? adminNotes,
  }) async {
    try {
      final result = await _dataSource.reviewInstructorApplication(
        applicationId: applicationId,
        status: VerificationStatus.approved,
        adminNotes: adminNotes,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<InstructorApplication>> rejectInstructorApplication({
    required String applicationId,
    required String reason,
    String? adminNotes,
  }) async {
    try {
      final result = await _dataSource.reviewInstructorApplication(
        applicationId: applicationId,
        status: VerificationStatus.rejected,
        reason: reason,
        adminNotes: adminNotes,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<CompanyVerificationRequest>> approveCompanyVerification({
    required String verificationId,
    String? adminNotes,
  }) async {
    try {
      final result = await _dataSource.reviewCompanyVerification(
        verificationId: verificationId,
        status: VerificationStatus.approved,
        adminNotes: adminNotes,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<CompanyVerificationRequest>> rejectCompanyVerification({
    required String verificationId,
    required String reason,
    String? adminNotes,
  }) async {
    try {
      final result = await _dataSource.reviewCompanyVerification(
        verificationId: verificationId,
        status: VerificationStatus.rejected,
        reason: reason,
        adminNotes: adminNotes,
      );
      return VerificationResult.success(result);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  @override
  Future<VerificationResult<void>> requestAdditionalDocuments({
    required String applicationId,
    required List<DocumentType> requiredDocuments,
    required String message,
  }) async {
    try {
      // Update application with request for additional documents
      await _dataSource.updateInstructorApplication(
        applicationId: applicationId,
        updates: {
          'admin_notes': message,
          'requested_documents': requiredDocuments.map((d) => d.value).toList(),
        },
      );
      return VerificationResult.success(null);
    } catch (e) {
      return VerificationResult.failure(message: e.toString());
    }
  }

  // ==================== Status Queries ====================

  @override
  Future<VerificationStatus> getMyVerificationStatus() async {
    try {
      return await _dataSource.getMyVerificationStatus();
    } catch (e) {
      return VerificationStatus.notSubmitted;
    }
  }

  @override
  Future<VerificationStatus> getCompanyVerificationStatus(String companyId) async {
    try {
      return await _dataSource.getCompanyVerificationStatus(companyId);
    } catch (e) {
      return VerificationStatus.notSubmitted;
    }
  }

  @override
  Future<bool> canApplyAsInstructor() async {
    final status = await getMyVerificationStatus();
    return status == VerificationStatus.notSubmitted ||
           status == VerificationStatus.rejected;
  }

  @override
  List<VerificationRequirement> getInstructorRequirements() {
    return VerificationRequirement.instructorRequirements;
  }

  @override
  List<VerificationRequirement> getCompanyRequirements() {
    return VerificationRequirement.companyRequirements;
  }
}
