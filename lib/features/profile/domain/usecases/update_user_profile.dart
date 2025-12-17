import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfile {
  UpdateUserProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call(ProfileEntity profile) {
    return _repository.updateProfile(profile);
  }
}
