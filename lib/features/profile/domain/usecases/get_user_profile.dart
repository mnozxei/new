import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile {
  GetUserProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity?> call(String userId) {
    return _repository.getProfile(userId);
  }
}
