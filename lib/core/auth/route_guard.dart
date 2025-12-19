import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/route_names.dart';
import 'permissions.dart';
import 'user_role.dart';

/// Route guard configuration for role-based access control
class RouteGuard {
  const RouteGuard({
    required this.path,
    this.allowedRoles,
    this.requiredPermissions,
    this.anyPermissions,
    this.redirectTo,
    this.visitorAllowed = false,
  });

  /// The route path this guard applies to
  final String path;

  /// Roles that are allowed to access this route (if null, uses permissions)
  final Set<UserRole>? allowedRoles;

  /// All of these permissions are required to access the route
  final List<Permission>? requiredPermissions;

  /// Any of these permissions allow access to the route
  final List<Permission>? anyPermissions;

  /// Where to redirect if access is denied
  final String? redirectTo;

  /// Whether visitors (unauthenticated users) can access this route
  final bool visitorAllowed;

  /// Check if a role can access this route
  bool canAccess(UserRole role) {
    // Check if visitors are allowed
    if (role == UserRole.visitor && !visitorAllowed) {
      return false;
    }

    // Check role-based access
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      if (!allowedRoles!.contains(role)) {
        return false;
      }
    }

    // Check permission-based access
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      if (!role.hasAllPermissions(requiredPermissions!)) {
        return false;
      }
    }

    if (anyPermissions != null && anyPermissions!.isNotEmpty) {
      if (!role.hasAnyPermission(anyPermissions!)) {
        return false;
      }
    }

    return true;
  }
}

/// Route guards configuration for the entire app
class RouteGuards {
  RouteGuards._();

  /// Routes that visitors (unauthenticated) can access
  static const Set<String> visitorAccessibleRoutes = {
    RouteNames.splash,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
    RouteNames.posts,
    RouteNames.jobs,
    RouteNames.courses,
    RouteNames.companies,
  };

  /// Routes that require authentication
  static const Set<String> authenticatedRoutes = {
    RouteNames.profile,
    RouteNames.editProfile,
    RouteNames.settings,
    RouteNames.chat,
    RouteNames.notifications,
    RouteNames.createPost,
    RouteNames.myApplications,
    RouteNames.savedItems,
  };

  /// Routes that require instructor role
  static const Set<String> instructorRoutes = {
    RouteNames.instructorDashboard,
  };

  /// Routes that require company membership
  static const Set<String> companyRoutes = {
    RouteNames.postJob,
    RouteNames.createCompany,
  };

  /// Routes that require admin role
  static const Set<String> adminRoutes = {
    RouteNames.adminDashboard,
  };

  /// All route guards
  static final List<RouteGuard> guards = [
    // Public routes (visitor allowed)
    const RouteGuard(
      path: RouteNames.splash,
      visitorAllowed: true,
    ),
    const RouteGuard(
      path: RouteNames.login,
      visitorAllowed: true,
    ),
    const RouteGuard(
      path: RouteNames.register,
      visitorAllowed: true,
    ),
    const RouteGuard(
      path: RouteNames.forgotPassword,
      visitorAllowed: true,
    ),
    const RouteGuard(
      path: RouteNames.posts,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicPosts],
    ),
    const RouteGuard(
      path: RouteNames.jobs,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicJobs],
    ),
    const RouteGuard(
      path: RouteNames.courses,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicCourses],
    ),
    const RouteGuard(
      path: RouteNames.companies,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicCompanies],
    ),

    // Authenticated routes
    const RouteGuard(
      path: RouteNames.profile,
      requiredPermissions: [Permission.editOwnProfile],
    ),
    const RouteGuard(
      path: RouteNames.chat,
      requiredPermissions: [Permission.viewChats],
    ),
    const RouteGuard(
      path: RouteNames.notifications,
      requiredPermissions: [Permission.viewNotifications],
    ),
    const RouteGuard(
      path: RouteNames.createPost,
      requiredPermissions: [Permission.createPost],
    ),
    const RouteGuard(
      path: RouteNames.myApplications,
      requiredPermissions: [Permission.applyForJob],
    ),
    const RouteGuard(
      path: RouteNames.savedItems,
      requiredPermissions: [Permission.viewSavedItems],
    ),

    // Instructor routes
    const RouteGuard(
      path: RouteNames.instructorDashboard,
      requiredPermissions: [Permission.createCourse],
    ),

    // Company routes
    const RouteGuard(
      path: RouteNames.postJob,
      requiredPermissions: [Permission.postJob],
    ),
    const RouteGuard(
      path: RouteNames.createCompany,
      requiredPermissions: [Permission.createCompany],
    ),

    // Admin routes
    const RouteGuard(
      path: RouteNames.adminDashboard,
      requiredPermissions: [Permission.adminDashboard],
    ),
  ];

  /// Find a guard for a specific path
  static RouteGuard? findGuard(String path) {
    // First try exact match
    for (final guard in guards) {
      if (guard.path == path) {
        return guard;
      }
    }

    // Then try prefix match for nested routes
    for (final guard in guards) {
      if (path.startsWith(guard.path) && guard.path != '/') {
        return guard;
      }
    }

    return null;
  }

  /// Check if a role can access a path
  static bool canAccess(UserRole role, String path) {
    final guard = findGuard(path);
    if (guard == null) {
      // If no guard defined, allow authenticated users
      return role.isAuthenticated;
    }
    return guard.canAccess(role);
  }

  /// Get redirect path for denied access
  static String getRedirectPath(UserRole role, String deniedPath) {
    final guard = findGuard(deniedPath);
    if (guard?.redirectTo != null) {
      return guard!.redirectTo!;
    }

    // Default redirects based on role
    if (role == UserRole.visitor) {
      return RouteNames.login;
    }

    return RouteNames.posts;
  }

  /// Check if a path is a visitor-accessible route
  static bool isVisitorAccessible(String path) {
    // Check exact match
    if (visitorAccessibleRoutes.contains(path)) {
      return true;
    }

    // Check if path starts with any visitor-accessible route
    for (final route in visitorAccessibleRoutes) {
      if (path.startsWith(route) && route != '/') {
        return true;
      }
    }

    return false;
  }
}

/// Mixin for widgets that need route guard functionality
mixin RouteGuardMixin<T extends StatefulWidget> on State<T> {
  /// Check if current user can access a route before navigating
  bool canNavigateTo(String path, UserRole role) {
    return RouteGuards.canAccess(role, path);
  }

  /// Navigate to a route if allowed, otherwise show error or redirect
  void guardedNavigate(
    BuildContext context,
    String path,
    UserRole role, {
    VoidCallback? onDenied,
  }) {
    if (canNavigateTo(path, role)) {
      context.push(path);
    } else {
      if (onDenied != null) {
        onDenied();
      } else {
        _showAccessDenied(context);
      }
    }
  }

  void _showAccessDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ليس لديك صلاحية للوصول إلى هذه الصفحة'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
