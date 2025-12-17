import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';

abstract class CompanyRemoteDataSource {
  Future<List<CompanyEntity>> getMyCompanies();
  Future<CompanyEntity?> getCompanyById(String id);
  Future<List<CompanyEntity>> getVerifiedCompanies({
    String? industry,
    String? city,
    int limit = 20,
    int offset = 0,
  });
  Future<List<CompanyEntity>> searchCompanies(String query);
  Future<CompanyEntity> createCompany(CreateCompanyParams params);
  Future<CompanyEntity> updateCompany(String id, UpdateCompanyParams params);
  Future<void> deleteCompany(String id);
  Future<String> uploadLogo(String companyId, File file);
  Future<String> uploadCover(String companyId, File file);
  Future<String> uploadVerificationDocument(
    String companyId,
    File file,
    VerificationDocumentType type,
  );
  Future<CompanyEntity> submitVerification(
    String companyId,
    VerificationDocuments documents,
  );
  Future<bool> isFollowing(String companyId);
  Future<void> followCompany(String companyId);
  Future<void> unfollowCompany(String companyId);
  Future<int> getFollowersCount(String companyId);
  Future<bool> isCompanyAdmin(String companyId);
  Future<List<CompanyEntity>> getPendingVerifications();
  Future<CompanyEntity> approveVerification(String companyId, {String? notes});
  Future<CompanyEntity> rejectVerification(String companyId, {String? reason});
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  CompanyRemoteDataSourceImpl({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  String get _userId => supabaseClient.auth.currentUser!.id;

  @override
  Future<List<CompanyEntity>> getMyCompanies() async {
    final response = await supabaseClient
        .from('companies')
        .select()
        .eq('owner_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => CompanyEntity.fromJson(json)).toList();
  }

  @override
  Future<CompanyEntity?> getCompanyById(String id) async {
    final response = await supabaseClient
        .from('companies')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return CompanyEntity.fromJson(response);
  }

  @override
  Future<List<CompanyEntity>> getVerifiedCompanies({
    String? industry,
    String? city,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = supabaseClient
        .from('companies')
        .select()
        .eq('is_verified', true);

    if (industry != null) {
      query = query.eq('industry', industry);
    }
    if (city != null) {
      query = query.eq('city', city);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => CompanyEntity.fromJson(json)).toList();
  }

  @override
  Future<List<CompanyEntity>> searchCompanies(String query) async {
    final response = await supabaseClient
        .from('companies')
        .select()
        .or('name.ilike.%$query%,name_en.ilike.%$query%')
        .eq('is_verified', true)
        .limit(20);

    return (response as List).map((json) => CompanyEntity.fromJson(json)).toList();
  }

  @override
  Future<CompanyEntity> createCompany(CreateCompanyParams params) async {
    final data = params.toJson();
    data['owner_id'] = _userId;

    final response = await supabaseClient
        .from('companies')
        .insert(data)
        .select()
        .single();

    return CompanyEntity.fromJson(response);
  }

  @override
  Future<CompanyEntity> updateCompany(String id, UpdateCompanyParams params) async {
    final response = await supabaseClient
        .from('companies')
        .update(params.toJson())
        .eq('id', id)
        .select()
        .single();

    return CompanyEntity.fromJson(response);
  }

  @override
  Future<void> deleteCompany(String id) async {
    await supabaseClient.from('companies').delete().eq('id', id);
  }

  @override
  Future<String> uploadLogo(String companyId, File file) async {
    final fileName = '${companyId}_logo_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
    final path = 'companies/$companyId/$fileName';

    await supabaseClient.storage.from('companies').upload(path, file);

    final url = supabaseClient.storage.from('companies').getPublicUrl(path);

    await supabaseClient
        .from('companies')
        .update({'logo_url': url})
        .eq('id', companyId);

    return url;
  }

  @override
  Future<String> uploadCover(String companyId, File file) async {
    final fileName = '${companyId}_cover_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
    final path = 'companies/$companyId/$fileName';

    await supabaseClient.storage.from('companies').upload(path, file);

    final url = supabaseClient.storage.from('companies').getPublicUrl(path);

    await supabaseClient
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
    final typeStr = type.name;
    final fileName = '${companyId}_${typeStr}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
    final path = 'companies/$companyId/verification/$fileName';

    await supabaseClient.storage.from('companies').upload(path, file);

    return supabaseClient.storage.from('companies').getPublicUrl(path);
  }

  @override
  Future<CompanyEntity> submitVerification(
    String companyId,
    VerificationDocuments documents,
  ) async {
    final response = await supabaseClient
        .from('companies')
        .update({
          'verification_status': 'pending',
          'verification_documents': documents.toJson(),
          'verification_submitted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', companyId)
        .select()
        .single();

    return CompanyEntity.fromJson(response);
  }

  @override
  Future<bool> isFollowing(String companyId) async {
    final response = await supabaseClient
        .from('company_followers')
        .select('id')
        .eq('company_id', companyId)
        .eq('user_id', _userId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<void> followCompany(String companyId) async {
    await supabaseClient.from('company_followers').insert({
      'company_id': companyId,
      'user_id': _userId,
    });
  }

  @override
  Future<void> unfollowCompany(String companyId) async {
    await supabaseClient
        .from('company_followers')
        .delete()
        .eq('company_id', companyId)
        .eq('user_id', _userId);
  }

  @override
  Future<int> getFollowersCount(String companyId) async {
    final response = await supabaseClient
        .from('company_followers')
        .select('id')
        .eq('company_id', companyId);

    return (response as List).length;
  }

  @override
  Future<bool> isCompanyAdmin(String companyId) async {
    final response = await supabaseClient
        .from('companies')
        .select('owner_id')
        .eq('id', companyId)
        .maybeSingle();

    return response?['owner_id'] == _userId;
  }

  @override
  Future<List<CompanyEntity>> getPendingVerifications() async {
    final response = await supabaseClient
        .from('companies')
        .select()
        .eq('verification_status', 'pending')
        .order('verification_submitted_at', ascending: true);

    return (response as List).map((json) => CompanyEntity.fromJson(json)).toList();
  }

  @override
  Future<CompanyEntity> approveVerification(String companyId, {String? notes}) async {
    final response = await supabaseClient
        .from('companies')
        .update({
          'is_verified': true,
          'verification_status': 'approved',
          'verified_at': DateTime.now().toIso8601String(),
          'verified_by': _userId,
          if (notes != null) 'verification_notes': notes,
        })
        .eq('id', companyId)
        .select()
        .single();

    return CompanyEntity.fromJson(response);
  }

  @override
  Future<CompanyEntity> rejectVerification(String companyId, {String? reason}) async {
    final response = await supabaseClient
        .from('companies')
        .update({
          'verification_status': 'rejected',
          if (reason != null) 'rejection_reason': reason,
        })
        .eq('id', companyId)
        .select()
        .single();

    return CompanyEntity.fromJson(response);
  }
}
