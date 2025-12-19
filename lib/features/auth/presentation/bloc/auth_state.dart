part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  /// Get the current user (authenticated or visitor)
  UserEntity? get currentUser => null;

  /// Check if the state represents an authenticated user
  bool get isAuthenticated => false;

  /// Check if the state represents a visitor
  bool get isVisitor => false;

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  UserEntity get currentUser => user;

  @override
  bool get isAuthenticated => true;

  @override
  List<Object?> get props => [user];
}

/// State for visitor mode (unauthenticated browsing)
class AuthVisitor extends AuthState {
  const AuthVisitor(this.user);

  final UserEntity user;

  @override
  UserEntity get currentUser => user;

  @override
  bool get isVisitor => true;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
