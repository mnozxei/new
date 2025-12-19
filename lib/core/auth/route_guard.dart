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

  /// Routes that visitors (unauthenticated) can access - READ ONLY
  /// Visitors can ONLY view public content, no write actions
  static const Set<String> visitorAccessibleRoutes = {
    RouteNames.splash,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
    // Public viewing routes
    RouteNames.posts,
    RouteNames.jobs,
    RouteNames.courses,
    RouteNames.companies,
    // Detail views (read-only)
    RouteNames.postDetail,
    RouteNames.jobDetail,
    RouteNames.courseDetail,
    RouteNames.companyDetail,
    RouteNames.publicProfile,
  };

  /// Routes that require authentication (any logged-in user)
  static const Set<String> authenticatedRoutes = {
    RouteNames.profile,
    RouteNames.editProfile,
    RouteNames.settings,
    RouteNames.chat,
    RouteNames.notifications,
    RouteNames.createPost,
    RouteNames.myApplications,
    RouteNames.savedItems,
    RouteNames.enrollCourse,
    RouteNames.applyJob,
    RouteNames.myEnrollments,
    RouteNames.myCourses,
  };

  /// Routes that require instructor role + verification
  static const Set<String> instructorRoutes = {
    RouteNames.instructorDashboard,
    RouteNames.createCourse,
    RouteNames.editCourse,
    RouteNames.courseAnalytics,
    RouteNames.createQuiz,
    RouteNames.editQuiz,
    RouteNames.issueCertificate,
  };

  /// Routes that require company membership
  static const Set<String> companyRoutes = {
    RouteNames.postJob,
    RouteNames.createCompany,
    RouteNames.editCompany,
    RouteNames.companyDashboard,
    RouteNames.companyAnalytics,
  };

  /// Routes that require company training access (verified company)
  static const Set<String> companyTrainingRoutes = {
    RouteNames.companyTrainingDashboard,
    RouteNames.createCompanyCourse,
  };

  /// Routes that require admin role
  static const Set<String> adminRoutes = {
    RouteNames.adminDashboard,
    RouteNames.adminUsers,
    RouteNames.adminCompanies,
    RouteNames.adminCourses,
    RouteNames.adminVerifications,
    RouteNames.adminReports,
    RouteNames.adminAuditLog,
  };

  /// Routes that require verification (instructor or company)
  static const Set<String> verificationGatedRoutes = {
    ...instructorRoutes,
    ...companyTrainingRoutes,
  };

  /// All route guards
  static final List<RouteGuard> guards = [
    // ===== PUBLIC ROUTES (visitor allowed - READ ONLY) =====
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
      path: RouteNames.postDetail,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicPosts],
    ),
    const RouteGuard(
      path: RouteNames.jobs,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicJobs],
    ),
    const RouteGuard(
      path: RouteNames.jobDetail,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicJobs],
    ),
    const RouteGuard(
      path: RouteNames.courses,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicCourses],
    ),
    const RouteGuard(
      path: RouteNames.courseDetail,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicCourses],
    ),
    const RouteGuard(
      path: RouteNames.companies,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicCompanies],
    ),
    const RouteGuard(
      path: RouteNames.companyDetail,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicCompanies],
    ),
    const RouteGuard(
      path: RouteNames.publicProfile,
      visitorAllowed: true,
      requiredPermissions: [Permission.viewPublicProfiles],
    ),

    // ===== AUTHENTICATED ROUTES =====
    const RouteGuard(
      path: RouteNames.profile,
      requiredPermissions: [Permission.editOwnProfile],
    ),
    const RouteGuard(
      path: RouteNames.editProfile,
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
    const RouteGuard(
      path: RouteNames.settings,
      requiredPermissions: [Permission.editOwnProfile],
    ),

    // ===== COURSE ENROLLMENT ROUTES (authenticated) =====
    const RouteGuard(
      path: RouteNames.enrollCourse,
      requiredPermissions: [Permission.enrollInCourse],
    ),
    const RouteGuard(
      path: RouteNames.myEnrollments,
      requiredPermissions: [Permission.viewEnrolledCourses],
    ),
    const RouteGuard(
      path: RouteNames.myCourses,
      requiredPermissions: [Permission.viewEnrolledCourses],
    ),

    // ===== JOB APPLICATION ROUTES (authenticated) =====
    const RouteGuard(
      path: RouteNames.applyJob,
      requiredPermissions: [Permission.applyForJob],
    ),

    // ===== INSTRUCTOR ROUTES (requires verification) =====
    const RouteGuard(
      path: RouteNames.instructorDashboard,
      requiredPermissions: [Permission.accessInstructorDashboard],
    ),
    const RouteGuard(
      path: RouteNames.createCourse,
      requiredPermissions: [Permission.createCourse],
    ),
    const RouteGuard(
      path: RouteNames.editCourse,
      requiredPermissions: [Permission.editOwnCourse],
    ),
    const RouteGuard(
      path: RouteNames.courseAnalytics,
      requiredPermissions: [Permission.viewCourseAnalytics],
    ),
    const RouteGuard(
      path: RouteNames.createQuiz,
      requiredPermissions: [Permission.createQuiz],
    ),
    const RouteGuard(
      path: RouteNames.editQuiz,
      requiredPermissions: [Permission.editQuiz],
    ),
    const RouteGuard(
      path: RouteNames.issueCertificate,
      requiredPermissions: [Permission.issueCertificate],
    ),

    // ===== COMPANY ROUTES =====
    const RouteGuard(
      path: RouteNames.postJob,
      requiredPermissions: [Permission.postJob],
    ),
    const RouteGuard(
      path: RouteNames.createCompany,
      requiredPermissions: [Permission.createCompany],
    ),
    const RouteGuard(
      path: RouteNames.editCompany,
      requiredPermissions: [Permission.editOwnCompany],
    ),
    const RouteGuard(
      path: RouteNames.companyDashboard,
      requiredPermissions: [Permission.viewCompanyAnalytics],
    ),
    const RouteGuard(
      path: RouteNames.companyAnalytics,
      requiredPermissions: [Permission.viewCompanyAnalytics],
    ),

    // ===== COMPANY TRAINING ROUTES (requires company verification) =====
    const RouteGuard(
      path: RouteNames.companyTrainingDashboard,
      requiredPermissions: [Permission.accessCompanyTrainingDashboard],
    ),
    const RouteGuard(
      path: RouteNames.createCompanyCourse,
      requiredPermissions: [Permission.createCompanyCourse],
    ),

    // ===== ADMIN ROUTES =====
    const RouteGuard(
      path: RouteNames.adminDashboard,
      requiredPermissions: [Permission.adminDashboard],
    ),
    const RouteGuard(
      path: RouteNames.adminUsers,
      requiredPermissions: [Permission.manageUsers],
    ),
    const RouteGuard(
      path: RouteNames.adminCompanies,
      requiredPermissions: [Permission.manageAllCompanies],
    ),
    const RouteGuard(
      path: RouteNames.adminCourses,
      requiredPermissions: [Permission.manageAllCourses],
    ),
    const RouteGuard(
      path: RouteNames.adminVerifications,
      requiredPermissions: [Permission.reviewVerifications],
    ),
    const RouteGuard(
      path: RouteNames.adminReports,
      requiredPermissions: [Permission.moderateContent],
    ),
    const RouteGuard(
      path: RouteNames.adminAuditLog,
      requiredPermissions: [Permission.viewAuditLogs],
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

    // Try pattern matching (for routes with :id, :courseId, etc.)
    for (final guard in guards) {
      if (_matchesPattern(guard.path, path)) {
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

  /// Check if a path matches a route pattern (e.g., /courses/:id matches /courses/123)
  static bool _matchesPattern(String pattern, String path) {
    if (!pattern.contains(':')) return false;

    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    if (patternParts.length != pathParts.length) return false;

    for (var i = 0; i < patternParts.length; i++) {
      final patternPart = patternParts[i];
      final pathPart = pathParts[i];

      // If pattern part starts with ':', it's a parameter - matches anything
      if (patternPart.startsWith(':')) continue;

      // Otherwise, must match exactly
      if (patternPart != pathPart) return false;
    }

    return true;
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

    // Check pattern matching for visitor routes
    for (final route in visitorAccessibleRoutes) {
      if (_matchesPattern(route, path)) {
        return true;
      }
    }

    return false;
  }

  /// Check if a path requires instructor verification
  static bool requiresInstructorVerification(String path) {
    for (final route in instructorRoutes) {
      if (route == path || _matchesPattern(route, path)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a path requires company verification
  static bool requiresCompanyVerification(String path) {
    for (final route in companyTrainingRoutes) {
      if (route == path || _matchesPattern(route, path)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a path requires any verification
  static bool requiresVerification(String path) {
    return requiresInstructorVerification(path) ||
        requiresCompanyVerification(path);
  }

  /// Get the appropriate verification redirect for a path
  static String? getVerificationRedirect(String path, UserRole role) {
    if (requiresInstructorVerification(path)) {
      return RouteNames.instructorVerification;
    }
    if (requiresCompanyVerification(path)) {
      // Extract company ID from path and redirect to company verification
      final match = RegExp(r'/companies/([^/]+)').firstMatch(path);
      if (match != null) {
        return '/companies/${match.group(1)}/verification';
      }
      return RouteNames.companies;
    }
    return null;
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
