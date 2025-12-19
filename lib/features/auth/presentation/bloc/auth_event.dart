part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.role = UserRole.user,
  });

  final String email;
  final String password;
  final String fullName;
  final UserRole role;

  @override
  List<Object?> get props => [email, password, fullName, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Event to enter visitor mode (browse without authentication)
class AuthVisitorModeRequested extends AuthEvent {
  const AuthVisitorModeRequested();
}

/// Event to upgrade from visitor to authenticated user
class AuthUpgradeFromVisitorRequested extends AuthEvent {
  const AuthUpgradeFromVisitorRequested();
}
