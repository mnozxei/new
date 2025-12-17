import 'dart:io';

import '../entities/company_entity.dart';

abstract class CompanyRepository {
  /// Get all companies owned by the current user
  Future<List<CompanyEntity>> getMyCompanies();

  /// Get a company by ID
  Future<CompanyEntity?> getCompanyById(String id);

  /// Get all verified companies (public listing)
  Future<List<CompanyEntity>> getVerifiedCompanies({
    String? industry,
    String? city,
    int limit = 20,
    int offset = 0,
  });

  /// Search companies by name
  Future<List<CompanyEntity>> searchCompanies(String query);

  /// Create a new company
  Future<CompanyEntity> createCompany(CreateCompanyParams params);

  /// Update company details
  Future<CompanyEntity> updateCompany(String id, UpdateCompanyParams params);

  /// Delete a company
  Future<void> deleteCompany(String id);

  /// Upload company logo
  Future<String> uploadLogo(String companyId, File file);

  /// Upload company cover image
  Future<String> uploadCover(String companyId, File file);

  /// Upload verification document
  Future<String> uploadVerificationDocument(
    String companyId,
    File file,
    VerificationDocumentType type,
  );

  /// Submit verification request
  Future<CompanyEntity> submitVerification(
    String companyId,
    VerificationDocuments documents,
  );

  /// Check if user is following a company
  Future<bool> isFollowing(String companyId);

  /// Follow a company
  Future<void> followCompany(String companyId);

  /// Unfollow a company
  Future<void> unfollowCompany(String companyId);

  /// Get company followers count
  Future<int> getFollowersCount(String companyId);

  /// Check if current user is admin of the company
  Future<bool> isCompanyAdmin(String companyId);

  /// Admin: Get pending verification requests
  Future<List<CompanyEntity>> getPendingVerifications();

  /// Admin: Approve verification
  Future<CompanyEntity> approveVerification(String companyId, {String? notes});

  /// Admin: Reject verification
  Future<CompanyEntity> rejectVerification(String companyId, {String? reason});
}

class CreateCompanyParams {
  const CreateCompanyParams({
    required this.name,
    this.nameEn,
    this.description,
    this.industry,
    this.companySize,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country = 'SA',
    this.foundedYear,
    this.socialLinks,
  });

  final String name;
  final String? nameEn;
  final String? description;
  final String? industry;
  final String? companySize;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String country;
  final int? foundedYear;
  final Map<String, dynamic>? socialLinks;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (nameEn != null) 'name_en': nameEn,
        if (description != null) 'description': description,
        if (industry != null) 'industry': industry,
        if (companySize != null) 'company_size': companySize,
        if (website != null) 'website': website,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        'country': country,
        if (foundedYear != null) 'founded_year': foundedYear,
        if (socialLinks != null) 'social_links': socialLinks,
      };
}

class UpdateCompanyParams {
  const UpdateCompanyParams({
    this.name,
    this.nameEn,
    this.description,
    this.industry,
    this.companySize,
    this.website,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.foundedYear,
    this.socialLinks,
  });

  final String? name;
  final String? nameEn;
  final String? description;
  final String? industry;
  final String? companySize;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final int? foundedYear;
  final Map<String, dynamic>? socialLinks;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (nameEn != null) json['name_en'] = nameEn;
    if (description != null) json['description'] = description;
    if (industry != null) json['industry'] = industry;
    if (companySize != null) json['company_size'] = companySize;
    if (website != null) json['website'] = website;
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (address != null) json['address'] = address;
    if (city != null) json['city'] = city;
    if (country != null) json['country'] = country;
    if (foundedYear != null) json['founded_year'] = foundedYear;
    if (socialLinks != null) json['social_links'] = socialLinks;
    return json;
  }
}

enum VerificationDocumentType {
  commercialRegister,
  taxCertificate,
  authorizationLetter,
}
