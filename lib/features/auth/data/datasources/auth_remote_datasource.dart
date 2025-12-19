import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role,
  });

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<UserModel?> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Login failed: No user returned');
      }

      final userProfile = await _fetchUserProfile(response.user!.id);
      _authStateController.add(userProfile);
      return userProfile;
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.name,
        },
      );

      if (response.user == null) {
        throw AuthException('Registration failed: No user returned');
      }

      // Wait for trigger to create the profile
      await Future.delayed(const Duration(milliseconds: 300));

      // Try to update profile with additional details
      // If it fails (RLS, etc.), the trigger-created profile is still valid
      try {
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          role: role,
        );
      } catch (_) {
        // Ignore - trigger should have created basic profile
      }

      final userProfile = await _fetchUserProfile(response.user!.id);
      _authStateController.add(userProfile);
      return userProfile;
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } on PostgrestException catch (e) {
      throw AuthException('Registration failed: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
    _authStateController.add(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    return _client.auth.currentSession != null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return _fetchUserProfile(user.id);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  Future<UserModel> _fetchUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      // Profile doesn't exist yet - create it from auth metadata
      final user = _client.auth.currentUser;
      final email = user?.email ?? '';
      final fullName = user?.userMetadata?['full_name'] as String? ?? '';
      final roleStr = user?.userMetadata?['role'] as String? ?? 'user';

      await _client.from('profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'role': roleStr,
      });

      // Fetch the newly created profile
      final newResponse = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(newResponse);
    }

    return UserModel.fromJson(response);
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required UserRole role,
  }) async {
    // Use upsert to handle case where trigger already created the profile
    await _client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'is_email_verified': false,
      'is_profile_complete': false,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please verify your email address';
    }
    if (message.contains('User already registered')) {
      return 'An account with this email already exists';
    }
    if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters';
    }
    if (message.contains('Unable to validate email')) {
      return 'Please enter a valid email address';
    }
    return message;
  }
}
