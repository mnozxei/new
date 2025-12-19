import 'dart:io';

import '../../../../core/auth/verification_gate.dart';
import '../entities/verification_entity.dart';

/// Result wrapper for verification operations
class VerificationResult<T> {
  const VerificationResult({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
  });

  factory VerificationResult.success(T data) => VerificationResult(
        success: true,
        data: data,
      );

  factory VerificationResult.failure({
    required String message,
    String? code,
  }) =>
      VerificationResult(
        success: false,
        errorMessage: message,
        errorCode: code,
      );

  final bool success;
  final T? data;
  final String? errorMessage;
  final String? errorCode;

  bool get isSuccess => success && data != null;
  bool get isFailure => !success;
}

/// Abstract repository for verification operations
abstract class VerificationRepository {
  // ==================== Instructor Verification ====================

  /// Get current user's instructor application
  Future<InstructorApplication?> getMyInstructorApplication();

  /// Submit instructor verification application
  Future<VerificationResult<InstructorApplication>> submitInstructorApplication({
    required String bio,
    required List<String> expertiseAreas,
    required int yearsOfExperience,
    String? portfolioUrl,
    String? linkedinUrl,
  });

  /// Update pending instructor application
  Future<VerificationResult<InstructorApplication>> updateInstructorApplication({
    required String applicationId,
    String? bio,
    List<String>? expertiseAreas,
    int? yearsOfExperience,
    String? portfolioUrl,
    String? linkedinUrl,
  });

  /// Cancel/withdraw instructor application
  Future<VerificationResult<void>> withdrawInstructorApplication(String applicationId);

  // ==================== Company Verification ====================

  /// Get company verification request
  Future<CompanyVerificationRequest?> getCompanyVerification(String companyId);

  /// Submit company verification request
  Future<VerificationResult<CompanyVerificationRequest>> submitCompanyVerification({
    required String companyId,
    String? companyType,
    String? employeeCountRange,
    String? industry,
    String? websiteUrl,
  });

  /// Update pending company verification
  Future<VerificationResult<CompanyVerificationRequest>> updateCompanyVerification({
    required String verificationId,
    String? companyType,
    String? employeeCountRange,
    String? industry,
    String? websiteUrl,
  });

  // ==================== Document Management ====================

  /// Upload verification document
  Future<VerificationResult<VerificationDocument>> uploadDocument({
    required File file,
    required DocumentType documentType,
    String? applicationId,
    String? verificationId,
    String? companyId,
    DateTime? expiryDate,
  });

  /// Get documents for application
  Future<List<VerificationDocument>> getApplicationDocuments(String applicationId);

  /// Get documents for company verification
  Future<List<VerificationDocument>> getCompanyDocuments(String verificationId);

  /// Delete document
  Future<VerificationResult<void>> deleteDocument(String documentId);

  /// Replace document with new version
  Future<VerificationResult<VerificationDocument>> replaceDocument({
    required String documentId,
    required File newFile,
    DateTime? newExpiryDate,
  });

  // ==================== Admin Operations ====================

  /// Get pending instructor applications (admin)
  Future<List<InstructorApplication>> getPendingInstructorApplications({
    int limit = 20,
    int offset = 0,
  });

  /// Get pending company verifications (admin)
  Future<List<CompanyVerificationRequest>> getPendingCompanyVerifications({
    int limit = 20,
    int offset = 0,
  });

  /// Approve instructor application (admin)
  Future<VerificationResult<InstructorApplication>> approveInstructorApplication({
    required String applicationId,
    String? adminNotes,
  });

  /// Reject instructor application (admin)
  Future<VerificationResult<InstructorApplication>> rejectInstructorApplication({
    required String applicationId,
    required String reason,
    String? adminNotes,
  });

  /// Approve company verification (admin)
  Future<VerificationResult<CompanyVerificationRequest>> approveCompanyVerification({
    required String verificationId,
    String? adminNotes,
  });

  /// Reject company verification (admin)
  Future<VerificationResult<CompanyVerificationRequest>> rejectCompanyVerification({
    required String verificationId,
    required String reason,
    String? adminNotes,
  });

  /// Request additional documents (admin)
  Future<VerificationResult<void>> requestAdditionalDocuments({
    required String applicationId,
    required List<DocumentType> requiredDocuments,
    required String message,
  });

  // ==================== Status Queries ====================

  /// Get verification status for current user
  Future<VerificationStatus> getMyVerificationStatus();

  /// Get verification status for a company
  Future<VerificationStatus> getCompanyVerificationStatus(String companyId);

  /// Check if user can become instructor
  Future<bool> canApplyAsInstructor();

  /// Get verification requirements
  List<VerificationRequirement> getInstructorRequirements();
  List<VerificationRequirement> getCompanyRequirements();
}
