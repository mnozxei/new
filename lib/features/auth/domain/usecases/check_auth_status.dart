import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  CheckAuthStatus(this._repository);

  final AuthRepository _repository;

  Future<bool> call() {
    return _repository.isAuthenticated();
  }
}
