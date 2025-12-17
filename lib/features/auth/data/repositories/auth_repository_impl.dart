import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure(
        message: e.message,
        code: 'AUTH_ERROR',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'An unexpected error occurred',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure(
        message: e.message,
        code: 'AUTH_ERROR',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'An unexpected error occurred',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _remoteDataSource.isAuthenticated();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _remoteDataSource.resetPassword(email);
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _remoteDataSource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> verifyEmail(String token) async {
    throw UnimplementedError('Email verification handled by Supabase');
  }

  @override
  Future<void> resendVerificationEmail() async {
    throw UnimplementedError('Verification email handled by Supabase');
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remoteDataSource.authStateChanges;
}
