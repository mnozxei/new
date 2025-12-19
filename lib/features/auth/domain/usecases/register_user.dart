import '../../../../core/auth/auth.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<AuthResult> call({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) {
    return _repository.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
