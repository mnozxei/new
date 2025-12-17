import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileEntity?> getProfile(String userId) {
    return _remoteDataSource.getProfile(userId);
  }

  @override
  Future<ProfileEntity> updateProfile(ProfileEntity profile) {
    return _remoteDataSource.updateProfile(ProfileModel.fromEntity(profile));
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) {
    return _remoteDataSource.uploadAvatar(userId, filePath);
  }

  @override
  Future<String> uploadCoverImage(String userId, String filePath) {
    return _remoteDataSource.uploadCoverImage(userId, filePath);
  }

  @override
  Future<void> deleteAvatar(String userId) {
    return _remoteDataSource.deleteAvatar(userId);
  }

  @override
  Future<void> deleteCoverImage(String userId) {
    return _remoteDataSource.deleteCoverImage(userId);
  }

  @override
  Future<void> followUser(String userId, String targetUserId) {
    return _remoteDataSource.followUser(userId, targetUserId);
  }

  @override
  Future<void> unfollowUser(String userId, String targetUserId) {
    return _remoteDataSource.unfollowUser(userId, targetUserId);
  }

  @override
  Future<bool> isFollowing(String userId, String targetUserId) {
    return _remoteDataSource.isFollowing(userId, targetUserId);
  }

  @override
  Future<List<ProfileEntity>> getFollowers(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) {
    return _remoteDataSource.getFollowers(userId, limit: limit, offset: offset);
  }

  @override
  Future<List<ProfileEntity>> getFollowing(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) {
    return _remoteDataSource.getFollowing(userId, limit: limit, offset: offset);
  }

  @override
  Future<List<ProfileEntity>> searchProfiles(
    String query, {
    int limit = 20,
    int offset = 0,
  }) {
    return _remoteDataSource.searchProfiles(query, limit: limit, offset: offset);
  }
}
