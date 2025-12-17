import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required LogoutUser logoutUser,
    required CheckAuthStatus checkAuthStatus,
    required GetCurrentUser getCurrentUser,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _logoutUser = logoutUser,
        _checkAuthStatus = checkAuthStatus,
        _getCurrentUser = getCurrentUser,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LogoutUser _logoutUser;
  final CheckAuthStatus _checkAuthStatus;
  final GetCurrentUser _getCurrentUser;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isAuthenticated = await _checkAuthStatus();

      if (isAuthenticated) {
        final user = await _getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUser(
      email: event.email,
      password: event.password,
    );

    if (result.isSuccess) {
      emit(AuthAuthenticated(result.user!));
    } else {
      emit(AuthError(result.errorMessage ?? 'Login failed'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUser(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      role: event.role,
    );

    if (result.isSuccess) {
      emit(AuthAuthenticated(result.user!));
    } else {
      emit(AuthError(result.errorMessage ?? 'Registration failed'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _logoutUser();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthAuthenticated(event.user));
  }
}
