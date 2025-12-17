import '../repositories/auth_repository.dart';

class LogoutUser {
  LogoutUser(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
