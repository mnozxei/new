import '../repositories/auth_repository.dart';

class LoginUser {
  LoginUser(this._repository);

  final AuthRepository _repository;

  Future<AuthResult> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
