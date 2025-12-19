import 'package:equatable/equatable.dart';

import '../../../../core/auth/verification_gate.dart';

/// Type of verification
enum VerificationType {
  userInstructor,
  company;

  String get displayName {
    switch (this) {
      case VerificationType.userInstructor:
        return 'مدرب مستقل';
      case VerificationType.company:
        return 'شركة';
    }
  }

  String get value {
    switch (this) {
      case VerificationType.userInstructor:
        return 'user_instructor';
      case VerificationType.company:
        return 'company';
    }
  }

  static VerificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'user_instructor':
      case 'userinstructor':
        return VerificationType.userInstructor;
      case 'company':
        return VerificationType.company;
      default:
        return VerificationType.userInstructor;
    }
  }
}

/// Document type for verification
enum DocumentType {
  identityCard,
  passport,
  degreeCertificate,
  professionalLicense,
  commercialRegistration,
  taxCertificate,
  companyLogo,
  authorizationLetter,
  other;

  String get displayName {
    switch (this) {
      case DocumentType.identityCard:
        return 'بطاقة الهوية';
      case DocumentType.passport:
        return 'جواز السفر';
      case DocumentType.degreeCertificate:
        return 'شهادة أكاديمية';
      case DocumentType.professionalLicense:
        return 'رخصة مهنية';
      case DocumentType.commercialRegistration:
        return 'السجل التجاري';
      case DocumentType.taxCertificate:
        return 'الشهادة الضريبية';
      case DocumentType.companyLogo:
        return 'شعار الشركة';
      case DocumentType.authorizationLetter:
        return 'خطاب تفويض';
      case DocumentType.other:
        return 'أخرى';
    }
  }

  String get value {
    switch (this) {
      case DocumentType.identityCard:
        return 'identity_card';
      case DocumentType.passport:
        return 'passport';
      case DocumentType.degreeCertificate:
        return 'degree_certificate';
      case DocumentType.professionalLicense:
        return 'professional_license';
      case DocumentType.commercialRegistration:
        return 'commercial_registration';
      case DocumentType.taxCertificate:
        return 'tax_certificate';
      case DocumentType.companyLogo:
        return 'company_logo';
      case DocumentType.authorizationLetter:
        return 'authorization_letter';
      case DocumentType.other:
        return 'other';
    }
  }

  static DocumentType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'identity_card':
        return DocumentType.identityCard;
      case 'passport':
        return DocumentType.passport;
      case 'degree_certificate':
        return DocumentType.degreeCertificate;
      case 'professional_license':
        return DocumentType.professionalLicense;
      case 'commercial_registration':
        return DocumentType.commercialRegistration;
      case 'tax_certificate':
        return DocumentType.taxCertificate;
      case 'company_logo':
        return DocumentType.companyLogo;
      case 'authorization_letter':
        return DocumentType.authorizationLetter;
      default:
        return DocumentType.other;
    }
  }

  /// Whether this document type is required for instructor verification
  bool get isRequiredForInstructor {
    return this == DocumentType.identityCard ||
        this == DocumentType.degreeCertificate;
  }

  /// Whether this document type is required for company verification
  bool get isRequiredForCompany {
    return this == DocumentType.commercialRegistration ||
        this == DocumentType.taxCertificate;
  }
}

/// User instructor application entity
class InstructorApplication extends Equatable {
  const InstructorApplication({
    required this.id,
    required this.userId,
    required this.status,
    this.bio,
    this.expertiseAreas,
    this.yearsOfExperience,
    this.portfolioUrl,
    this.linkedinUrl,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerId,
    this.rejectionReason,
    this.adminNotes,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final VerificationStatus status;
  final String? bio;
  final List<String>? expertiseAreas;
  final int? yearsOfExperience;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? rejectionReason;
  final String? adminNotes;
  final List<VerificationDocument> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory InstructorApplication.fromJson(Map<String, dynamic> json) {
    return InstructorApplication(
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
              ?.map((d) => VerificationDocument.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'status': status.value,
        'bio': bio,
        'expertise_areas': expertiseAreas,
        'years_of_experience': yearsOfExperience,
        'portfolio_url': portfolioUrl,
        'linkedin_url': linkedinUrl,
        'submitted_at': submittedAt.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
        'reviewer_id': reviewerId,
        'rejection_reason': rejectionReason,
        'admin_notes': adminNotes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  InstructorApplication copyWith({
    String? id,
    String? userId,
    VerificationStatus? status,
    String? bio,
    List<String>? expertiseAreas,
    int? yearsOfExperience,
    String? portfolioUrl,
    String? linkedinUrl,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewerId,
    String? rejectionReason,
    String? adminNotes,
    List<VerificationDocument>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstructorApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      expertiseAreas: expertiseAreas ?? this.expertiseAreas,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerId: reviewerId ?? this.reviewerId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        bio,
        expertiseAreas,
        yearsOfExperience,
        portfolioUrl,
        linkedinUrl,
        submittedAt,
        reviewedAt,
        reviewerId,
        rejectionReason,
        adminNotes,
        documents,
        createdAt,
        updatedAt,
      ];
}

/// Company verification request entity
class CompanyVerificationRequest extends Equatable {
  const CompanyVerificationRequest({
    required this.id,
    required this.companyId,
    required this.submittedBy,
    required this.status,
    this.companyType,
    this.employeeCountRange,
    this.industry,
    this.websiteUrl,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerId,
    this.rejectionReason,
    this.adminNotes,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String submittedBy;
  final VerificationStatus status;
  final String? companyType;
  final String? employeeCountRange;
  final String? industry;
  final String? websiteUrl;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? rejectionReason;
  final String? adminNotes;
  final List<VerificationDocument> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CompanyVerificationRequest.fromJson(Map<String, dynamic> json) {
    return CompanyVerificationRequest(
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
              ?.map((d) => VerificationDocument.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'submitted_by': submittedBy,
        'status': status.value,
        'company_type': companyType,
        'employee_count_range': employeeCountRange,
        'industry': industry,
        'website_url': websiteUrl,
        'submitted_at': submittedAt.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
        'reviewer_id': reviewerId,
        'rejection_reason': rejectionReason,
        'admin_notes': adminNotes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        companyId,
        submittedBy,
        status,
        companyType,
        employeeCountRange,
        industry,
        websiteUrl,
        submittedAt,
        reviewedAt,
        reviewerId,
        rejectionReason,
        adminNotes,
        documents,
        createdAt,
        updatedAt,
      ];
}

/// Verification document entity
class VerificationDocument extends Equatable {
  const VerificationDocument({
    required this.id,
    this.applicationId,
    this.verificationId,
    required this.userId,
    this.companyId,
    required this.documentType,
    required this.storagePath,
    required this.originalFilename,
    this.fileSize,
    this.mimeType,
    this.fileHash,
    this.version = 1,
    this.expiryDate,
    this.isVerified = false,
    this.verifiedAt,
    this.verifiedBy,
    required this.uploadedAt,
    required this.createdAt,
  });

  final String id;
  final String? applicationId;
  final String? verificationId;
  final String userId;
  final String? companyId;
  final DocumentType documentType;
  final String storagePath;
  final String originalFilename;
  final int? fileSize;
  final String? mimeType;
  final String? fileHash;
  final int version;
  final DateTime? expiryDate;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final DateTime uploadedAt;
  final DateTime createdAt;

  /// Get public URL for the document
  String? get publicUrl => storagePath;

  /// Check if document is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if document is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
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

  Map<String, dynamic> toJson() => {
        'id': id,
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
        'is_verified': isVerified,
        'verified_at': verifiedAt?.toIso8601String(),
        'verified_by': verifiedBy,
        'uploaded_at': uploadedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        applicationId,
        verificationId,
        userId,
        companyId,
        documentType,
        storagePath,
        originalFilename,
        fileSize,
        mimeType,
        fileHash,
        version,
        expiryDate,
        isVerified,
        verifiedAt,
        verifiedBy,
        uploadedAt,
        createdAt,
      ];
}

/// Verification requirement definition
class VerificationRequirement extends Equatable {
  const VerificationRequirement({
    required this.documentType,
    required this.isRequired,
    this.description,
    this.acceptedFormats,
    this.maxFileSizeMb,
    this.requiresExpiry = false,
  });

  final DocumentType documentType;
  final bool isRequired;
  final String? description;
  final List<String>? acceptedFormats;
  final int? maxFileSizeMb;
  final bool requiresExpiry;

  static List<VerificationRequirement> get instructorRequirements => [
        const VerificationRequirement(
          documentType: DocumentType.identityCard,
          isRequired: true,
          description: 'صورة واضحة من بطاقة الهوية الوطنية أو الإقامة',
          acceptedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
          maxFileSizeMb: 5,
        ),
        const VerificationRequirement(
          documentType: DocumentType.degreeCertificate,
          isRequired: true,
          description: 'صورة من أعلى شهادة أكاديمية حصلت عليها',
          acceptedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
          maxFileSizeMb: 10,
        ),
        const VerificationRequirement(
          documentType: DocumentType.professionalLicense,
          isRequired: false,
          description: 'رخصة مهنية إن وجدت (اختياري)',
          acceptedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
          maxFileSizeMb: 5,
          requiresExpiry: true,
        ),
      ];

  static List<VerificationRequirement> get companyRequirements => [
        const VerificationRequirement(
          documentType: DocumentType.commercialRegistration,
          isRequired: true,
          description: 'صورة من السجل التجاري ساري المفعول',
          acceptedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
          maxFileSizeMb: 10,
          requiresExpiry: true,
        ),
        const VerificationRequirement(
          documentType: DocumentType.taxCertificate,
          isRequired: true,
          description: 'شهادة ضريبية أو رقم ضريبي',
          acceptedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
          maxFileSizeMb: 5,
        ),
        const VerificationRequirement(
          documentType: DocumentType.companyLogo,
          isRequired: false,
          description: 'شعار الشركة بجودة عالية (اختياري)',
          acceptedFormats: ['jpg', 'jpeg', 'png', 'svg'],
          maxFileSizeMb: 2,
        ),
        const VerificationRequirement(
          documentType: DocumentType.authorizationLetter,
          isRequired: false,
          description: 'خطاب تفويض إذا لم تكن المالك (اختياري)',
          acceptedFormats: ['pdf'],
          maxFileSizeMb: 5,
        ),
      ];

  @override
  List<Object?> get props => [
        documentType,
        isRequired,
        description,
        acceptedFormats,
        maxFileSizeMb,
        requiresExpiry,
      ];
}
