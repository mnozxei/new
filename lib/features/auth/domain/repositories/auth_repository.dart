import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  });

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<UserEntity?> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> verifyEmail(String token);

  Future<void> resendVerificationEmail();

  Stream<UserEntity?> get authStateChanges;
}

class AuthResult {
  const AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthResult.success(UserEntity user) => AuthResult(
        success: true,
        user: user,
      );

  factory AuthResult.failure({
    required String message,
    String? code,
  }) =>
      AuthResult(
        success: false,
        errorMessage: message,
        errorCode: code,
      );

  final bool success;
  final UserEntity? user;
  final String? errorMessage;
  final String? errorCode;

  bool get isSuccess => success && user != null;
  bool get isFailure => !success;
}
