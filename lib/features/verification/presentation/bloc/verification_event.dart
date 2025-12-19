part of 'verification_bloc.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load current user's verification status and application
class LoadVerificationStatus extends VerificationEvent {
  const LoadVerificationStatus();
}

/// Load instructor application for current user
class LoadInstructorApplication extends VerificationEvent {
  const LoadInstructorApplication();
}

/// Submit instructor application
class SubmitInstructorApplication extends VerificationEvent {
  const SubmitInstructorApplication({
    required this.bio,
    required this.expertiseAreas,
    required this.yearsOfExperience,
    this.portfolioUrl,
    this.linkedinUrl,
  });

  final String bio;
  final List<String> expertiseAreas;
  final int yearsOfExperience;
  final String? portfolioUrl;
  final String? linkedinUrl;

  @override
  List<Object?> get props => [bio, expertiseAreas, yearsOfExperience, portfolioUrl, linkedinUrl];
}

/// Update existing instructor application
class UpdateInstructorApplication extends VerificationEvent {
  const UpdateInstructorApplication({
    required this.applicationId,
    this.bio,
    this.expertiseAreas,
    this.yearsOfExperience,
    this.portfolioUrl,
    this.linkedinUrl,
  });

  final String applicationId;
  final String? bio;
  final List<String>? expertiseAreas;
  final int? yearsOfExperience;
  final String? portfolioUrl;
  final String? linkedinUrl;

  @override
  List<Object?> get props => [applicationId, bio, expertiseAreas, yearsOfExperience, portfolioUrl, linkedinUrl];
}

/// Withdraw instructor application
class WithdrawInstructorApplication extends VerificationEvent {
  const WithdrawInstructorApplication(this.applicationId);

  final String applicationId;

  @override
  List<Object?> get props => [applicationId];
}

/// Upload document for verification
class UploadVerificationDocument extends VerificationEvent {
  const UploadVerificationDocument({
    required this.file,
    required this.documentType,
    this.applicationId,
    this.verificationId,
    this.companyId,
    this.expiryDate,
  });

  final File file;
  final DocumentType documentType;
  final String? applicationId;
  final String? verificationId;
  final String? companyId;
  final DateTime? expiryDate;

  @override
  List<Object?> get props => [file, documentType, applicationId, verificationId, companyId, expiryDate];
}

/// Delete verification document
class DeleteVerificationDocument extends VerificationEvent {
  const DeleteVerificationDocument(this.documentId);

  final String documentId;

  @override
  List<Object?> get props => [documentId];
}

/// Replace verification document
class ReplaceVerificationDocument extends VerificationEvent {
  const ReplaceVerificationDocument({
    required this.documentId,
    required this.newFile,
    this.newExpiryDate,
  });

  final String documentId;
  final File newFile;
  final DateTime? newExpiryDate;

  @override
  List<Object?> get props => [documentId, newFile, newExpiryDate];
}

/// Load company verification
class LoadCompanyVerification extends VerificationEvent {
  const LoadCompanyVerification(this.companyId);

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Submit company verification
class SubmitCompanyVerification extends VerificationEvent {
  const SubmitCompanyVerification({
    required this.companyId,
    this.companyType,
    this.employeeCountRange,
    this.industry,
    this.websiteUrl,
  });

  final String companyId;
  final String? companyType;
  final String? employeeCountRange;
  final String? industry;
  final String? websiteUrl;

  @override
  List<Object?> get props => [companyId, companyType, employeeCountRange, industry, websiteUrl];
}

// ==================== Admin Events ====================

/// Load pending instructor applications (admin)
class LoadPendingInstructorApplications extends VerificationEvent {
  const LoadPendingInstructorApplications({
    this.limit = 20,
    this.offset = 0,
  });

  final int limit;
  final int offset;

  @override
  List<Object?> get props => [limit, offset];
}

/// Load pending company verifications (admin)
class LoadPendingCompanyVerifications extends VerificationEvent {
  const LoadPendingCompanyVerifications({
    this.limit = 20,
    this.offset = 0,
  });

  final int limit;
  final int offset;

  @override
  List<Object?> get props => [limit, offset];
}

/// Approve instructor application (admin)
class ApproveInstructorApplication extends VerificationEvent {
  const ApproveInstructorApplication({
    required this.applicationId,
    this.adminNotes,
  });

  final String applicationId;
  final String? adminNotes;

  @override
  List<Object?> get props => [applicationId, adminNotes];
}

/// Reject instructor application (admin)
class RejectInstructorApplication extends VerificationEvent {
  const RejectInstructorApplication({
    required this.applicationId,
    required this.reason,
    this.adminNotes,
  });

  final String applicationId;
  final String reason;
  final String? adminNotes;

  @override
  List<Object?> get props => [applicationId, reason, adminNotes];
}

/// Approve company verification (admin)
class ApproveCompanyVerification extends VerificationEvent {
  const ApproveCompanyVerification({
    required this.verificationId,
    this.adminNotes,
  });

  final String verificationId;
  final String? adminNotes;

  @override
  List<Object?> get props => [verificationId, adminNotes];
}

/// Reject company verification (admin)
class RejectCompanyVerification extends VerificationEvent {
  const RejectCompanyVerification({
    required this.verificationId,
    required this.reason,
    this.adminNotes,
  });

  final String verificationId;
  final String reason;
  final String? adminNotes;

  @override
  List<Object?> get props => [verificationId, reason, adminNotes];
}
