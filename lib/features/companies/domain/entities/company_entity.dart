import 'package:equatable/equatable.dart';

enum CompanyStatus {
  unverified('unverified'),
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  const CompanyStatus(this.value);
  final String value;

  static CompanyStatus fromString(String value) {
    return CompanyStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CompanyStatus.unverified,
    );
  }
}

class CompanyEntity extends Equatable {
  const CompanyEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    this.nameEn,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.industry,
    this.companySize,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country = 'SA',
    this.foundedYear,
    this.status = CompanyStatus.unverified,
    this.isFeatured = false,
    this.socialLinks = const {},
    this.commercialRegisterNumber,
    this.commercialRegisterUrl,
    this.taxCertificateNumber,
    this.taxCertificateUrl,
    this.authorizationLetterUrl,
    this.verificationSubmittedAt,
    this.verificationReviewedAt,
    this.verificationReviewedBy,
    this.verificationNotes,
    this.followerCount = 0,
    this.employeeCount = 0,
    this.jobCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? nameEn;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? industry;
  final String? companySize;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String country;
  final int? foundedYear;
  final CompanyStatus status;
  final bool isFeatured;
  final Map<String, dynamic> socialLinks;
  final String? commercialRegisterNumber;
  final String? commercialRegisterUrl;
  final String? taxCertificateNumber;
  final String? taxCertificateUrl;
  final String? authorizationLetterUrl;
  final DateTime? verificationSubmittedAt;
  final DateTime? verificationReviewedAt;
  final String? verificationReviewedBy;
  final String? verificationNotes;
  final int followerCount;
  final int employeeCount;
  final int jobCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isVerified => status == CompanyStatus.verified;
  bool get isPending => status == CompanyStatus.pending;
  bool get canPostJobs => isVerified;

  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}';
    }
    return name.length >= 2 ? name.substring(0, 2) : name;
  }

  CompanyEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? nameEn,
    String? description,
    String? logoUrl,
    String? coverUrl,
    String? industry,
    String? companySize,
    String? website,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    int? foundedYear,
    CompanyStatus? status,
    bool? isFeatured,
    Map<String, dynamic>? socialLinks,
    String? commercialRegisterNumber,
    String? commercialRegisterUrl,
    String? taxCertificateNumber,
    String? taxCertificateUrl,
    String? authorizationLetterUrl,
    DateTime? verificationSubmittedAt,
    DateTime? verificationReviewedAt,
    String? verificationReviewedBy,
    String? verificationNotes,
    int? followerCount,
    int? employeeCount,
    int? jobCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      socialLinks: socialLinks ?? this.socialLinks,
      commercialRegisterNumber: commercialRegisterNumber ?? this.commercialRegisterNumber,
      commercialRegisterUrl: commercialRegisterUrl ?? this.commercialRegisterUrl,
      taxCertificateNumber: taxCertificateNumber ?? this.taxCertificateNumber,
      taxCertificateUrl: taxCertificateUrl ?? this.taxCertificateUrl,
      authorizationLetterUrl: authorizationLetterUrl ?? this.authorizationLetterUrl,
      verificationSubmittedAt: verificationSubmittedAt ?? this.verificationSubmittedAt,
      verificationReviewedAt: verificationReviewedAt ?? this.verificationReviewedAt,
      verificationReviewedBy: verificationReviewedBy ?? this.verificationReviewedBy,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      followerCount: followerCount ?? this.followerCount,
      employeeCount: employeeCount ?? this.employeeCount,
      jobCount: jobCount ?? this.jobCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        nameEn,
        description,
        logoUrl,
        coverUrl,
        industry,
        companySize,
        website,
        email,
        phone,
        address,
        city,
        country,
        foundedYear,
        status,
        isFeatured,
        socialLinks,
        commercialRegisterNumber,
        commercialRegisterUrl,
        taxCertificateNumber,
        taxCertificateUrl,
        authorizationLetterUrl,
        verificationSubmittedAt,
        verificationReviewedAt,
        verificationReviewedBy,
        verificationNotes,
        followerCount,
        employeeCount,
        jobCount,
        createdAt,
        updatedAt,
      ];
}

class VerificationDocuments extends Equatable {
  const VerificationDocuments({
    this.commercialRegisterNumber,
    this.commercialRegisterUrl,
    this.taxCertificateNumber,
    this.taxCertificateUrl,
    this.authorizationLetterUrl,
  });

  final String? commercialRegisterNumber;
  final String? commercialRegisterUrl;
  final String? taxCertificateNumber;
  final String? taxCertificateUrl;
  final String? authorizationLetterUrl;

  bool get hasCommercialRegister =>
      commercialRegisterNumber != null && commercialRegisterUrl != null;

  bool get hasTaxCertificate =>
      taxCertificateNumber != null && taxCertificateUrl != null;

  bool get hasAuthorizationLetter => authorizationLetterUrl != null;

  bool get isComplete => hasCommercialRegister && hasTaxCertificate;

  @override
  List<Object?> get props => [
        commercialRegisterNumber,
        commercialRegisterUrl,
        taxCertificateNumber,
        taxCertificateUrl,
        authorizationLetterUrl,
      ];
}
