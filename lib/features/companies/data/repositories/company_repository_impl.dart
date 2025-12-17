import 'dart:io';

import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl({required this.remoteDataSource});

  final CompanyRemoteDataSource remoteDataSource;

  @override
  Future<List<CompanyEntity>> getMyCompanies() {
    return remoteDataSource.getMyCompanies();
  }

  @override
  Future<CompanyEntity?> getCompanyById(String id) {
    return remoteDataSource.getCompanyById(id);
  }

  @override
  Future<List<CompanyEntity>> getVerifiedCompanies({
    String? industry,
    String? city,
    int limit = 20,
    int offset = 0,
  }) {
    return remoteDataSource.getVerifiedCompanies(
      industry: industry,
      city: city,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<CompanyEntity>> searchCompanies(String query) {
    return remoteDataSource.searchCompanies(query);
  }

  @override
  Future<CompanyEntity> createCompany(CreateCompanyParams params) {
    return remoteDataSource.createCompany(params);
  }

  @override
  Future<CompanyEntity> updateCompany(String id, UpdateCompanyParams params) {
    return remoteDataSource.updateCompany(id, params);
  }

  @override
  Future<void> deleteCompany(String id) {
    return remoteDataSource.deleteCompany(id);
  }

  @override
  Future<String> uploadLogo(String companyId, File file) {
    return remoteDataSource.uploadLogo(companyId, file);
  }

  @override
  Future<String> uploadCover(String companyId, File file) {
    return remoteDataSource.uploadCover(companyId, file);
  }

  @override
  Future<String> uploadVerificationDocument(
    String companyId,
    File file,
    VerificationDocumentType type,
  ) {
    return remoteDataSource.uploadVerificationDocument(companyId, file, type);
  }

  @override
  Future<CompanyEntity> submitVerification(
    String companyId,
    VerificationDocuments documents,
  ) {
    return remoteDataSource.submitVerification(companyId, documents);
  }

  @override
  Future<bool> isFollowing(String companyId) {
    return remoteDataSource.isFollowing(companyId);
  }

  @override
  Future<void> followCompany(String companyId) {
    return remoteDataSource.followCompany(companyId);
  }

  @override
  Future<void> unfollowCompany(String companyId) {
    return remoteDataSource.unfollowCompany(companyId);
  }

  @override
  Future<int> getFollowersCount(String companyId) {
    return remoteDataSource.getFollowersCount(companyId);
  }

  @override
  Future<bool> isCompanyAdmin(String companyId) {
    return remoteDataSource.isCompanyAdmin(companyId);
  }

  @override
  Future<List<CompanyEntity>> getPendingVerifications() {
    return remoteDataSource.getPendingVerifications();
  }

  @override
  Future<CompanyEntity> approveVerification(String companyId, {String? notes}) {
    return remoteDataSource.approveVerification(companyId, notes: notes);
  }

  @override
  Future<CompanyEntity> rejectVerification(String companyId, {String? reason}) {
    return remoteDataSource.rejectVerification(companyId, reason: reason);
  }
}
