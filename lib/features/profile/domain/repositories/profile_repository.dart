import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);

  Future<ProfileEntity> updateProfile(ProfileEntity profile);

  Future<String> uploadAvatar(String userId, String filePath);

  Future<String> uploadCoverImage(String userId, String filePath);

  Future<void> deleteAvatar(String userId);

  Future<void> deleteCoverImage(String userId);

  Future<void> followUser(String userId, String targetUserId);

  Future<void> unfollowUser(String userId, String targetUserId);

  Future<bool> isFollowing(String userId, String targetUserId);

  Future<List<ProfileEntity>> getFollowers(String userId, {int limit, int offset});

  Future<List<ProfileEntity>> getFollowing(String userId, {int limit, int offset});

  Future<List<ProfileEntity>> searchProfiles(String query, {int limit, int offset});
}
