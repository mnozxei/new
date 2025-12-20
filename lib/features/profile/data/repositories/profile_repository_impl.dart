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

  @override
  Future<List<ExperienceEntity>> getExperiences(String userId) {
    return _remoteDataSource.getExperiences(userId);
  }

  @override
  Future<ExperienceEntity> addExperience(String userId, ExperienceEntity experience) {
    return _remoteDataSource.addExperience(userId, experience);
  }

  @override
  Future<ExperienceEntity> updateExperience(String userId, ExperienceEntity experience) {
    return _remoteDataSource.updateExperience(userId, experience);
  }

  @override
  Future<void> deleteExperience(String userId, String experienceId) {
    return _remoteDataSource.deleteExperience(userId, experienceId);
  }

  @override
  Future<LearningStats> getLearningStats(String userId) {
    return _remoteDataSource.getLearningStats(userId);
  }

  @override
  Future<List<CertificatePreview>> getCertificates(
    String userId, {
    int limit = 10,
    int offset = 0,
  }) {
    return _remoteDataSource.getCertificates(userId, limit: limit, offset: offset);
  }

  @override
  Future<List<CompletedCourse>> getCompletedCourses(
    String userId, {
    int limit = 10,
    int offset = 0,
  }) {
    return _remoteDataSource.getCompletedCourses(userId, limit: limit, offset: offset);
  }
}
