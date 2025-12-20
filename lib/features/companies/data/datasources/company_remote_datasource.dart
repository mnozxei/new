import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../models/company_model.dart';

abstract class CompanyRemoteDataSource {
  Future<List<CompanyModel>> getMyCompanies();
  Future<CompanyModel?> getCompanyById(String id);
  Future<List<CompanyModel>> getVerifiedCompanies({
    String? industry,
    String? city,
    int limit = 20,
    int offset = 0,
  });
  Future<List<CompanyModel>> searchCompanies(String query);
  Future<CompanyModel> createCompany(CreateCompanyParams params);
  Future<CompanyModel> updateCompany(String id, UpdateCompanyParams params);
  Future<void> deleteCompany(String id);
  Future<String> uploadLogo(String companyId, File file);
  Future<String> uploadCover(String companyId, File file);
  Future<String> uploadVerificationDocument(
    String companyId,
    File file,
    VerificationDocumentType type,
  );
  Future<CompanyModel> submitVerification(
    String companyId,
    VerificationDocuments documents,
  );
  Future<bool> isFollowing(String companyId);
  Future<void> followCompany(String companyId);
  Future<void> unfollowCompany(String companyId);
  Future<int> getFollowersCount(String companyId);
  Future<bool> isCompanyAdmin(String companyId);
  Future<List<CompanyModel>> getPendingVerifications();
  Future<CompanyModel> approveVerification(String companyId, {String? notes});
  Future<CompanyModel> rejectVerification(String companyId, {String? reason});
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  CompanyRemoteDataSourceImpl({required this.supabase});

  final SupabaseClient supabase;

  String get _userId => supabase.auth.currentUser!.id;

  @override
  Future<List<CompanyModel>> getMyCompanies() async {
    final response = await supabase
        .from('companies')
        .select()
        .or('owner_id.eq.$_userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CompanyModel?> getCompanyById(String id) async {
    final response = await supabase
        .from('companies')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return CompanyModel.fromJson(response);
  }

  @override
  Future<List<CompanyModel>> getVerifiedCompanies({
    String? industry,
    String? city,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = supabase
        .from('companies')
        .select()
        .eq('status', 'verified');

    if (industry != null) {
      query = query.eq('industry', industry);
    }
    if (city != null) {
      query = query.eq('city', city);
    }

    final response = await query
        .order('follower_count', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CompanyModel>> searchCompanies(String query) async {
    final response = await supabase
        .from('companies')
        .select()
        .eq('status', 'verified')
        .or('name.ilike.%$query%,name_en.ilike.%$query%')
        .limit(20);

    return (response as List)
        .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CompanyModel> createCompany(CreateCompanyParams params) async {
    final data = {
      ...params.toJson(),
      'owner_id': _userId,
    };

    final response = await supabase
        .from('companies')
        .insert(data)
        .select()
        .single();

    return CompanyModel.fromJson(response);
  }

  @override
  Future<CompanyModel> updateCompany(String id, UpdateCompanyParams params) async {
    final response = await supabase
        .from('companies')
        .update(params.toJson())
        .eq('id', id)
        .select()
        .single();

    return CompanyModel.fromJson(response);
  }

  @override
  Future<void> deleteCompany(String id) async {
    await supabase.from('companies').delete().eq('id', id);
  }

  @override
  Future<String> uploadLogo(String companyId, File file) async {
    final fileName = '$companyId/logo_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';

    await supabase.storage
        .from('company-assets')
        .upload(fileName, file);

    final url = supabase.storage
        .from('company-assets')
        .getPublicUrl(fileName);

    await supabase
        .from('companies')
        .update({'logo_url': url})
        .eq('id', companyId);

    return url;
  }

  @override
  Future<String> uploadCover(String companyId, File file) async {
    final fileName = '$companyId/cover_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';

    await supabase.storage
        .from('company-assets')
        .upload(fileName, file);

    final url = supabase.storage
        .from('company-assets')
        .getPublicUrl(fileName);

    await supabase
        .from('companies')
        .update({'cover_url': url})
        .eq('id', companyId);

    return url;
  }

  @override
  Future<String> uploadVerificationDocument(
    String companyId,
    File file,
    VerificationDocumentType type,
  ) async {
    final typeStr = switch (type) {
      VerificationDocumentType.commercialRegister => 'commercial_register',
      VerificationDocumentType.taxCertificate => 'tax_certificate',
      VerificationDocumentType.authorizationLetter => 'authorization_letter',
    };

    final fileName = '$companyId/verification/${typeStr}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';

    await supabase.storage
        .from('company-documents')
        .upload(fileName, file);

    final url = supabase.storage
        .from('company-documents')
        .getPublicUrl(fileName);

    final columnName = switch (type) {
      VerificationDocumentType.commercialRegister => 'commercial_register_url',
      VerificationDocumentType.taxCertificate => 'tax_certificate_url',
      VerificationDocumentType.authorizationLetter => 'authorization_letter_url',
    };

    await supabase
        .from('companies')
        .update({columnName: url})
        .eq('id', companyId);

    return url;
  }

  @override
  Future<CompanyModel> submitVerification(
    String companyId,
    VerificationDocuments documents,
  ) async {
    final data = <String, dynamic>{
      'status': 'pending',
      'verification_submitted_at': DateTime.now().toIso8601String(),
    };

    if (documents.commercialRegisterNumber != null) {
      data['commercial_register_number'] = documents.commercialRegisterNumber;
    }
    if (documents.taxCertificateNumber != null) {
      data['tax_certificate_number'] = documents.taxCertificateNumber;
    }

    final response = await supabase
        .from('companies')
        .update(data)
        .eq('id', companyId)
        .select()
        .single();

    return CompanyModel.fromJson(response);
  }

  @override
  Future<bool> isFollowing(String companyId) async {
    final response = await supabase
        .from('company_followers')
        .select()
        .eq('company_id', companyId)
        .eq('user_id', _userId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<void> followCompany(String companyId) async {
    await supabase.from('company_followers').insert({
      'company_id': companyId,
      'user_id': _userId,
    });
  }

  @override
  Future<void> unfollowCompany(String companyId) async {
    await supabase
        .from('company_followers')
        .delete()
        .eq('company_id', companyId)
        .eq('user_id', _userId);
  }

  @override
  Future<int> getFollowersCount(String companyId) async {
    final response = await supabase
        .from('company_followers')
        .select()
        .eq('company_id', companyId);

    return (response as List).length;
  }

  @override
  Future<bool> isCompanyAdmin(String companyId) async {
    // Check if owner
    final company = await supabase
        .from('companies')
        .select('owner_id')
        .eq('id', companyId)
        .maybeSingle();

    if (company != null && company['owner_id'] == _userId) {
      return true;
    }

    // Check if admin
    final admin = await supabase
        .from('company_admins')
        .select()
        .eq('company_id', companyId)
        .eq('user_id', _userId)
        .maybeSingle();

    return admin != null;
  }

  @override
  Future<List<CompanyModel>> getPendingVerifications() async {
    final response = await supabase
        .from('companies')
        .select()
        .eq('status', 'pending')
        .order('verification_submitted_at', ascending: true);

    return (response as List)
        .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CompanyModel> approveVerification(String companyId, {String? notes}) async {
    final response = await supabase
        .from('companies')
        .update({
          'status': 'verified',
          'verification_reviewed_at': DateTime.now().toIso8601String(),
          'verification_reviewed_by': _userId,
          if (notes != null) 'verification_notes': notes,
        })
        .eq('id', companyId)
        .select()
        .single();

    return CompanyModel.fromJson(response);
  }

  @override
  Future<CompanyModel> rejectVerification(String companyId, {String? reason}) async {
    final response = await supabase
        .from('companies')
        .update({
          'status': 'rejected',
          'verification_reviewed_at': DateTime.now().toIso8601String(),
          'verification_reviewed_by': _userId,
          if (reason != null) 'verification_notes': reason,
        })
        .eq('id', companyId)
        .select()
        .single();

    return CompanyModel.fromJson(response);
  }
}
