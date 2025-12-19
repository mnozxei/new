import 'user_role.dart';

/// Permission types available in the platform
enum Permission {
  // Content viewing
  viewPublicPosts,
  viewPublicJobs,
  viewPublicCourses,
  viewPublicCompanies,
  viewPublicProfiles,

  // Authenticated actions
  createPost,
  editOwnPost,
  deleteOwnPost,
  commentOnPost,
  likePost,
  sharePost,

  // Job actions
  applyForJob,
  postJob,
  manageOwnJobs,
  viewJobApplications,

  // Course actions
  enrollInCourse,
  viewEnrolledCourses,
  createCourse,
  editOwnCourse,
  deleteCourse,
  viewCourseAnalytics,
  createQuiz,

  // Company actions
  createCompany,
  editOwnCompany,
  manageCompanyMembers,
  postAsCompany,
  viewCompanyAnalytics,

  // Chat actions
  sendMessages,
  viewChats,

  // Profile actions
  editOwnProfile,
  saveItems,
  viewSavedItems,

  // Notification actions
  viewNotifications,

  // Admin actions
  adminDashboard,
  manageUsers,
  manageAllCompanies,
  manageAllCourses,
  manageAllJobs,
  viewPlatformAnalytics,
  moderateContent,
}

/// Permission checker for role-based access control
class PermissionChecker {
  PermissionChecker._();

  /// Map of roles to their permissions
  static final Map<UserRole, Set<Permission>> _rolePermissions = {
    UserRole.visitor: {
      Permission.viewPublicPosts,
      Permission.viewPublicJobs,
      Permission.viewPublicCourses,
      Permission.viewPublicCompanies,
      Permission.viewPublicProfiles,
    },
    UserRole.user: {
      // All visitor permissions
      Permission.viewPublicPosts,
      Permission.viewPublicJobs,
      Permission.viewPublicCourses,
      Permission.viewPublicCompanies,
      Permission.viewPublicProfiles,
      // Post permissions
      Permission.createPost,
      Permission.editOwnPost,
      Permission.deleteOwnPost,
      Permission.commentOnPost,
      Permission.likePost,
      Permission.sharePost,
      // Job permissions
      Permission.applyForJob,
      // Course permissions
      Permission.enrollInCourse,
      Permission.viewEnrolledCourses,
      // Chat permissions
      Permission.sendMessages,
      Permission.viewChats,
      // Profile permissions
      Permission.editOwnProfile,
      Permission.saveItems,
      Permission.viewSavedItems,
      // Notification permissions
      Permission.viewNotifications,
    },
    UserRole.userInstructor: {
      // All user permissions
      Permission.viewPublicPosts,
      Permission.viewPublicJobs,
      Permission.viewPublicCourses,
      Permission.viewPublicCompanies,
      Permission.viewPublicProfiles,
      Permission.createPost,
      Permission.editOwnPost,
      Permission.deleteOwnPost,
      Permission.commentOnPost,
      Permission.likePost,
      Permission.sharePost,
      Permission.applyForJob,
      Permission.enrollInCourse,
      Permission.viewEnrolledCourses,
      Permission.sendMessages,
      Permission.viewChats,
      Permission.editOwnProfile,
      Permission.saveItems,
      Permission.viewSavedItems,
      Permission.viewNotifications,
      // Instructor permissions
      Permission.createCourse,
      Permission.editOwnCourse,
      Permission.deleteCourse,
      Permission.viewCourseAnalytics,
      Permission.createQuiz,
    },
    UserRole.companyMember: {
      // All user permissions
      Permission.viewPublicPosts,
      Permission.viewPublicJobs,
      Permission.viewPublicCourses,
      Permission.viewPublicCompanies,
      Permission.viewPublicProfiles,
      Permission.createPost,
      Permission.editOwnPost,
      Permission.deleteOwnPost,
      Permission.commentOnPost,
      Permission.likePost,
      Permission.sharePost,
      Permission.applyForJob,
      Permission.enrollInCourse,
      Permission.viewEnrolledCourses,
      Permission.sendMessages,
      Permission.viewChats,
      Permission.editOwnProfile,
      Permission.saveItems,
      Permission.viewSavedItems,
      Permission.viewNotifications,
      // Company member permissions
      Permission.postJob,
      Permission.manageOwnJobs,
      Permission.viewJobApplications,
      Permission.postAsCompany,
      Permission.viewCompanyAnalytics,
    },
    UserRole.companyInstructor: {
      // All user permissions
      Permission.viewPublicPosts,
      Permission.viewPublicJobs,
      Permission.viewPublicCourses,
      Permission.viewPublicCompanies,
      Permission.viewPublicProfiles,
      Permission.createPost,
      Permission.editOwnPost,
      Permission.deleteOwnPost,
      Permission.commentOnPost,
      Permission.likePost,
      Permission.sharePost,
      Permission.applyForJob,
      Permission.enrollInCourse,
      Permission.viewEnrolledCourses,
      Permission.sendMessages,
      Permission.viewChats,
      Permission.editOwnProfile,
      Permission.saveItems,
      Permission.viewSavedItems,
      Permission.viewNotifications,
      // Company member permissions
      Permission.postJob,
      Permission.manageOwnJobs,
      Permission.viewJobApplications,
      Permission.postAsCompany,
      Permission.viewCompanyAnalytics,
      // Instructor permissions
      Permission.createCourse,
      Permission.editOwnCourse,
      Permission.deleteCourse,
      Permission.viewCourseAnalytics,
      Permission.createQuiz,
    },
    UserRole.admin: {
      // All permissions
      ...Permission.values,
    },
  };

  /// Check if a role has a specific permission
  static bool hasPermission(UserRole role, Permission permission) {
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  /// Check if a role has all of the specified permissions
  static bool hasAllPermissions(UserRole role, List<Permission> permissions) {
    return permissions.every((p) => hasPermission(role, p));
  }

  /// Check if a role has any of the specified permissions
  static bool hasAnyPermission(UserRole role, List<Permission> permissions) {
    return permissions.any((p) => hasPermission(role, p));
  }

  /// Get all permissions for a role
  static Set<Permission> getPermissions(UserRole role) {
    return _rolePermissions[role] ?? {};
  }
}

/// Extension on UserRole for permission checking
extension UserRolePermissions on UserRole {
  bool hasPermission(Permission permission) {
    return PermissionChecker.hasPermission(this, permission);
  }

  bool hasAllPermissions(List<Permission> permissions) {
    return PermissionChecker.hasAllPermissions(this, permissions);
  }

  bool hasAnyPermission(List<Permission> permissions) {
    return PermissionChecker.hasAnyPermission(this, permissions);
  }

  Set<Permission> get permissions => PermissionChecker.getPermissions(this);
}
