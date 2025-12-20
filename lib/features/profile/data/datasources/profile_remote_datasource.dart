import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);

  Future<ProfileModel> updateProfile(ProfileModel profile);

  Future<String> uploadAvatar(String userId, String filePath);

  Future<String> uploadCoverImage(String userId, String filePath);

  Future<void> deleteAvatar(String userId);

  Future<void> deleteCoverImage(String userId);

  Future<void> followUser(String userId, String targetUserId);

  Future<void> unfollowUser(String userId, String targetUserId);

  Future<bool> isFollowing(String userId, String targetUserId);

  Future<List<ProfileModel>> getFollowers(
    String userId, {
    int limit = 20,
    int offset = 0,
  });

  Future<List<ProfileModel>> getFollowing(
    String userId, {
    int limit = 20,
    int offset = 0,
  });

  Future<List<ProfileModel>> searchProfiles(
    String query, {
    int limit = 20,
    int offset = 0,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return ProfileModel.fromJson(response);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final data = profile.toJson()
      ..remove('id')
      ..remove('email')
      ..remove('created_at')
      ..['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('profiles').update(data).eq('id', profile.id);

    final updated = await getProfile(profile.id);
    return updated!;
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    final fileName = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}';

    await _client.storage.from('profiles').upload(
          fileName,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _client.storage.from('profiles').getPublicUrl(fileName);

    await _client
        .from('profiles')
        .update({'avatar_url': publicUrl}).eq('id', userId);

    return publicUrl;
  }

  @override
  Future<String> uploadCoverImage(String userId, String filePath) async {
    final fileName = 'covers/$userId/${DateTime.now().millisecondsSinceEpoch}';

    await _client.storage.from('profiles').upload(
          fileName,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _client.storage.from('profiles').getPublicUrl(fileName);

    await _client
        .from('profiles')
        .update({'cover_image_url': publicUrl}).eq('id', userId);

    return publicUrl;
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    await _client
        .from('profiles')
        .update({'avatar_url': null}).eq('id', userId);
  }

  @override
  Future<void> deleteCoverImage(String userId) async {
    await _client
        .from('profiles')
        .update({'cover_image_url': null}).eq('id', userId);
  }

  @override
  Future<void> followUser(String userId, String targetUserId) async {
    await _client.from('follows').insert({
      'follower_id': userId,
      'following_id': targetUserId,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _client.rpc('increment_followers_count', params: {
      'user_id': targetUserId,
    });

    await _client.rpc('increment_following_count', params: {
      'user_id': userId,
    });
  }

  @override
  Future<void> unfollowUser(String userId, String targetUserId) async {
    await _client
        .from('follows')
        .delete()
        .eq('follower_id', userId)
        .eq('following_id', targetUserId);

    await _client.rpc('decrement_followers_count', params: {
      'user_id': targetUserId,
    });

    await _client.rpc('decrement_following_count', params: {
      'user_id': userId,
    });
  }

  @override
  Future<bool> isFollowing(String userId, String targetUserId) async {
    final response = await _client
        .from('follows')
        .select()
        .eq('follower_id', userId)
        .eq('following_id', targetUserId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<ProfileModel>> getFollowers(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('follows')
        .select('profiles!follower_id(*)')
        .eq('following_id', userId)
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => ProfileModel.fromJson(
            (e as Map<String, dynamic>)['profiles'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProfileModel>> getFollowing(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('follows')
        .select('profiles!following_id(*)')
        .eq('follower_id', userId)
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => ProfileModel.fromJson(
            (e as Map<String, dynamic>)['profiles'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProfileModel>> searchProfiles(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('profiles')
        .select()
        .or('full_name.ilike.%$query%,email.ilike.%$query%,job_title.ilike.%$query%')
        .range(offset, offset + limit - 1)
        .order('full_name', ascending: true);

    return (response as List<dynamic>)
        .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
