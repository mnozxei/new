import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../auth/user_role.dart';
import 'login_required_prompt.dart';

/// Wraps interactive widgets to handle visitor restrictions.
///
/// When a visitor taps the wrapped widget, shows LoginRequiredPrompt instead
/// of executing the action.
///
/// Usage:
/// ```dart
/// VisitorActionWrapper(
///   action: 'الإعجاب',
///   onAuthenticated: () => likePost(),
///   child: IconButton(
///     icon: Icon(Icons.favorite),
///     onPressed: null, // Action handled by wrapper
///   ),
/// )
/// ```
class VisitorActionWrapper extends StatelessWidget {
  const VisitorActionWrapper({
    super.key,
    required this.action,
    required this.onAuthenticated,
    required this.child,
    this.showPromptOnTap = true,
    this.hideForVisitor = false,
    this.visitorReplacement,
  });

  /// The action description for the login prompt
  final String action;

  /// Callback executed when user is authenticated
  final VoidCallback onAuthenticated;

  /// The child widget to wrap
  final Widget child;

  /// Whether to show prompt when visitor taps (default: true)
  final bool showPromptOnTap;

  /// Whether to hide the widget entirely for visitors
  final bool hideForVisitor;

  /// Optional replacement widget for visitors
  final Widget? visitorReplacement;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;
        final isVisitor = !isAuthenticated;

        // Hide for visitors if specified
        if (hideForVisitor && isVisitor) {
          return visitorReplacement ?? const SizedBox.shrink();
        }

        // Wrap with gesture detector to intercept taps
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            if (isAuthenticated) {
              onAuthenticated();
            } else if (showPromptOnTap) {
              await LoginRequiredPrompt.show(context, action: action);
            }
          },
          child: IgnorePointer(
            // Let the wrapper handle taps
            ignoring: true,
            child: child,
          ),
        );
      },
    );
  }
}

/// A button that handles visitor restrictions automatically
class AuthenticatedButton extends StatelessWidget {
  const AuthenticatedButton({
    super.key,
    required this.action,
    required this.onPressed,
    required this.child,
    this.style,
    this.hideForVisitor = false,
  });

  final String action;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool hideForVisitor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;

        if (hideForVisitor && !isAuthenticated) {
          return const SizedBox.shrink();
        }

        return ElevatedButton(
          style: style,
          onPressed: () async {
            if (isAuthenticated) {
              onPressed();
            } else {
              await LoginRequiredPrompt.show(context, action: action);
            }
          },
          child: child,
        );
      },
    );
  }
}

/// An icon button that handles visitor restrictions
class AuthenticatedIconButton extends StatelessWidget {
  const AuthenticatedIconButton({
    super.key,
    required this.action,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.size,
    this.hideForVisitor = false,
    this.disabledColor,
  });

  final String action;
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double? size;
  final bool hideForVisitor;
  final Color? disabledColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;

        if (hideForVisitor && !isAuthenticated) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: Icon(
            icon,
            color: isAuthenticated ? color : (disabledColor ?? color?.withOpacity(0.5)),
            size: size,
          ),
          tooltip: tooltip,
          onPressed: () async {
            if (isAuthenticated) {
              onPressed();
            } else {
              await LoginRequiredPrompt.show(context, action: action);
            }
          },
        );
      },
    );
  }
}

/// A text button that handles visitor restrictions
class AuthenticatedTextButton extends StatelessWidget {
  const AuthenticatedTextButton({
    super.key,
    required this.action,
    required this.onPressed,
    required this.child,
    this.style,
    this.hideForVisitor = false,
  });

  final String action;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool hideForVisitor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;

        if (hideForVisitor && !isAuthenticated) {
          return const SizedBox.shrink();
        }

        return TextButton(
          style: style,
          onPressed: () async {
            if (isAuthenticated) {
              onPressed();
            } else {
              await LoginRequiredPrompt.show(context, action: action);
            }
          },
          child: child,
        );
      },
    );
  }
}

/// An outlined button that handles visitor restrictions
class AuthenticatedOutlinedButton extends StatelessWidget {
  const AuthenticatedOutlinedButton({
    super.key,
    required this.action,
    required this.onPressed,
    required this.child,
    this.style,
    this.hideForVisitor = false,
  });

  final String action;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool hideForVisitor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;

        if (hideForVisitor && !isAuthenticated) {
          return const SizedBox.shrink();
        }

        return OutlinedButton(
          style: style,
          onPressed: () async {
            if (isAuthenticated) {
              onPressed();
            } else {
              await LoginRequiredPrompt.show(context, action: action);
            }
          },
          child: child,
        );
      },
    );
  }
}

/// A chip that handles visitor restrictions for actions like follow
class AuthenticatedActionChip extends StatelessWidget {
  const AuthenticatedActionChip({
    super.key,
    required this.action,
    required this.onPressed,
    required this.label,
    this.avatar,
    this.hideForVisitor = false,
  });

  final String action;
  final VoidCallback onPressed;
  final Widget label;
  final Widget? avatar;
  final bool hideForVisitor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;

        if (hideForVisitor && !isAuthenticated) {
          return const SizedBox.shrink();
        }

        return ActionChip(
          avatar: avatar,
          label: label,
          onPressed: () async {
            if (isAuthenticated) {
              onPressed();
            } else {
              await LoginRequiredPrompt.show(context, action: action);
            }
          },
        );
      },
    );
  }
}

/// Extension to check authentication state easily
extension AuthContextExtension on BuildContext {
  /// Check if the current user is authenticated
  bool get isAuthenticated {
    try {
      final state = read<AuthBloc>().state;
      return state is AuthAuthenticated;
    } catch (_) {
      return false;
    }
  }

  /// Check if the current user is a visitor
  bool get isVisitor => !isAuthenticated;

  /// Get current user role
  UserRole get userRole {
    try {
      final state = read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        return state.user.role;
      }
      return UserRole.visitor;
    } catch (_) {
      return UserRole.visitor;
    }
  }

  /// Execute action if authenticated, show prompt otherwise
  Future<void> authenticatedAction({
    required String action,
    required VoidCallback onAuthenticated,
  }) async {
    if (isAuthenticated) {
      onAuthenticated();
    } else {
      await LoginRequiredPrompt.show(this, action: action);
    }
  }
}
