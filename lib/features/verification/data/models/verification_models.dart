import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';

/// Model for instructor application with JSON serialization
class InstructorApplicationModel extends InstructorApplication {
  const InstructorApplicationModel({
    required super.id,
    required super.userId,
    required super.status,
    super.bio,
    super.expertiseAreas,
    super.yearsOfExperience,
    super.portfolioUrl,
    super.linkedinUrl,
    required super.submittedAt,
    super.reviewedAt,
    super.reviewerId,
    super.rejectionReason,
    super.adminNotes,
    required super.documents,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InstructorApplicationModel.fromJson(Map<String, dynamic> json) {
    return InstructorApplicationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: VerificationStatus.fromString(json['status'] as String? ?? 'pending'),
      bio: json['bio'] as String?,
      expertiseAreas: (json['expertise_areas'] as List<dynamic>?)?.cast<String>(),
      yearsOfExperience: json['years_of_experience'] as int?,
      portfolioUrl: json['portfolio_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewerId: json['reviewer_id'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      adminNotes: json['admin_notes'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((d) => VerificationDocumentModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory InstructorApplicationModel.fromEntity(InstructorApplication entity) {
    return InstructorApplicationModel(
      id: entity.id,
      userId: entity.userId,
      status: entity.status,
      bio: entity.bio,
      expertiseAreas: entity.expertiseAreas,
      yearsOfExperience: entity.yearsOfExperience,
      portfolioUrl: entity.portfolioUrl,
      linkedinUrl: entity.linkedinUrl,
      submittedAt: entity.submittedAt,
      reviewedAt: entity.reviewedAt,
      reviewerId: entity.reviewerId,
      rejectionReason: entity.rejectionReason,
      adminNotes: entity.adminNotes,
      documents: entity.documents,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'status': status.value,
        'bio': bio,
        'expertise_areas': expertiseAreas,
        'years_of_experience': yearsOfExperience,
        'portfolio_url': portfolioUrl,
        'linkedin_url': linkedinUrl,
        'submitted_at': submittedAt.toIso8601String(),
      };

  Map<String, dynamic> toUpdateJson() => {
        'bio': bio,
        'expertise_areas': expertiseAreas,
        'years_of_experience': yearsOfExperience,
        'portfolio_url': portfolioUrl,
        'linkedin_url': linkedinUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };
}

/// Model for company verification with JSON serialization
class CompanyVerificationModel extends CompanyVerificationRequest {
  const CompanyVerificationModel({
    required super.id,
    required super.companyId,
    required super.submittedBy,
    required super.status,
    super.companyType,
    super.employeeCountRange,
    super.industry,
    super.websiteUrl,
    required super.submittedAt,
    super.reviewedAt,
    super.reviewerId,
    super.rejectionReason,
    super.adminNotes,
    required super.documents,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CompanyVerificationModel.fromJson(Map<String, dynamic> json) {
    return CompanyVerificationModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      submittedBy: json['submitted_by'] as String,
      status: VerificationStatus.fromString(json['status'] as String? ?? 'pending'),
      companyType: json['company_type'] as String?,
      employeeCountRange: json['employee_count_range'] as String?,
      industry: json['industry'] as String?,
      websiteUrl: json['website_url'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewerId: json['reviewer_id'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      adminNotes: json['admin_notes'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((d) => VerificationDocumentModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory CompanyVerificationModel.fromEntity(CompanyVerificationRequest entity) {
    return CompanyVerificationModel(
      id: entity.id,
      companyId: entity.companyId,
      submittedBy: entity.submittedBy,
      status: entity.status,
      companyType: entity.companyType,
      employeeCountRange: entity.employeeCountRange,
      industry: entity.industry,
      websiteUrl: entity.websiteUrl,
      submittedAt: entity.submittedAt,
      reviewedAt: entity.reviewedAt,
      reviewerId: entity.reviewerId,
      rejectionReason: entity.rejectionReason,
      adminNotes: entity.adminNotes,
      documents: entity.documents,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'company_id': companyId,
        'submitted_by': submittedBy,
        'status': status.value,
        'company_type': companyType,
        'employee_count_range': employeeCountRange,
        'industry': industry,
        'website_url': websiteUrl,
        'submitted_at': submittedAt.toIso8601String(),
      };

  Map<String, dynamic> toUpdateJson() => {
        'company_type': companyType,
        'employee_count_range': employeeCountRange,
        'industry': industry,
        'website_url': websiteUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };
}

/// Model for verification document with JSON serialization
class VerificationDocumentModel extends VerificationDocument {
  const VerificationDocumentModel({
    required super.id,
    super.applicationId,
    super.verificationId,
    required super.userId,
    super.companyId,
    required super.documentType,
    required super.storagePath,
    required super.originalFilename,
    super.fileSize,
    super.mimeType,
    super.fileHash,
    super.version,
    super.expiryDate,
    super.isVerified,
    super.verifiedAt,
    super.verifiedBy,
    required super.uploadedAt,
    required super.createdAt,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentModel(
      id: json['id'] as String,
      applicationId: json['application_id'] as String?,
      verificationId: json['verification_id'] as String?,
      userId: json['user_id'] as String,
      companyId: json['company_id'] as String?,
      documentType: DocumentType.fromString(json['document_type'] as String),
      storagePath: json['storage_path'] as String,
      originalFilename: json['original_filename'] as String,
      fileSize: json['file_size'] as int?,
      mimeType: json['mime_type'] as String?,
      fileHash: json['file_hash'] as String?,
      version: json['version'] as int? ?? 1,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      verifiedBy: json['verified_by'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory VerificationDocumentModel.fromEntity(VerificationDocument entity) {
    return VerificationDocumentModel(
      id: entity.id,
      applicationId: entity.applicationId,
      verificationId: entity.verificationId,
      userId: entity.userId,
      companyId: entity.companyId,
      documentType: entity.documentType,
      storagePath: entity.storagePath,
      originalFilename: entity.originalFilename,
      fileSize: entity.fileSize,
      mimeType: entity.mimeType,
      fileHash: entity.fileHash,
      version: entity.version,
      expiryDate: entity.expiryDate,
      isVerified: entity.isVerified,
      verifiedAt: entity.verifiedAt,
      verifiedBy: entity.verifiedBy,
      uploadedAt: entity.uploadedAt,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'application_id': applicationId,
        'verification_id': verificationId,
        'user_id': userId,
        'company_id': companyId,
        'document_type': documentType.value,
        'storage_path': storagePath,
        'original_filename': originalFilename,
        'file_size': fileSize,
        'mime_type': mimeType,
        'file_hash': fileHash,
        'version': version,
        'expiry_date': expiryDate?.toIso8601String(),
        'uploaded_at': uploadedAt.toIso8601String(),
      };
}
