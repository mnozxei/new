/// User roles for TAMAD HUB platform
///
/// Role hierarchy:
/// - visitor: Unauthenticated user (can browse public content)
/// - user: Authenticated user (can apply for jobs, enroll in courses)
/// - userInstructor: User who can create and sell courses
/// - companyMember: User who belongs to a company
/// - companyInstructor: Teaches on behalf of a company
/// - admin: Platform administrator
enum UserRole {
  visitor,
  user,
  userInstructor,
  companyMember,
  companyInstructor,
  admin;

  /// Alias for userInstructor for backwards compatibility
  static UserRole get instructor => UserRole.userInstructor;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user_instructor':
      case 'userinstructor':
        return UserRole.userInstructor;
      case 'company_member':
      case 'companymember':
        return UserRole.companyMember;
      case 'company_instructor':
      case 'companyinstructor':
        return UserRole.companyInstructor;
      case 'visitor':
        return UserRole.visitor;
      default:
        return UserRole.user;
    }
  }

  String get value {
    switch (this) {
      case UserRole.visitor:
        return 'visitor';
      case UserRole.user:
        return 'user';
      case UserRole.userInstructor:
        return 'user_instructor';
      case UserRole.companyMember:
        return 'company_member';
      case UserRole.companyInstructor:
        return 'company_instructor';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.visitor:
        return 'زائر';
      case UserRole.user:
        return 'مستخدم';
      case UserRole.userInstructor:
        return 'مدرب مستقل';
      case UserRole.companyMember:
        return 'عضو شركة';
      case UserRole.companyInstructor:
        return 'مدرب شركة';
      case UserRole.admin:
        return 'مدير النظام';
    }
  }

  String get displayNameEn {
    switch (this) {
      case UserRole.visitor:
        return 'Visitor';
      case UserRole.user:
        return 'User';
      case UserRole.userInstructor:
        return 'Independent Instructor';
      case UserRole.companyMember:
        return 'Company Member';
      case UserRole.companyInstructor:
        return 'Company Instructor';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  /// Check if this role is authenticated (not a visitor)
  bool get isAuthenticated => this != UserRole.visitor;

  /// Check if this role can create courses
  bool get canCreateCourses =>
      this == UserRole.userInstructor ||
      this == UserRole.companyInstructor ||
      this == UserRole.admin;

  /// Check if this role belongs to a company
  bool get isCompanyRole =>
      this == UserRole.companyMember || this == UserRole.companyInstructor;

  /// Check if this role is an instructor type
  bool get isInstructor =>
      this == UserRole.userInstructor || this == UserRole.companyInstructor;

  /// Check if this role is an admin
  bool get isAdmin => this == UserRole.admin;

  /// Check if this role can post jobs
  bool get canPostJobs =>
      this == UserRole.companyMember ||
      this == UserRole.companyInstructor ||
      this == UserRole.admin;

  /// Check if this role can manage a company
  bool get canManageCompany =>
      this == UserRole.companyMember ||
      this == UserRole.companyInstructor ||
      this == UserRole.admin;

  /// Check if this role can apply for jobs
  bool get canApplyForJobs => isAuthenticated;

  /// Check if this role can enroll in courses
  bool get canEnrollInCourses => isAuthenticated;

  /// Check if this role can follow users and companies
  bool get canFollow => isAuthenticated;

  /// Check if this role can create posts
  bool get canCreatePosts => isAuthenticated;

  /// Check if this role can send messages
  bool get canSendMessages => isAuthenticated;

  /// Check if this role requires instructor verification to access instructor features
  bool get requiresInstructorVerification =>
      this == UserRole.userInstructor || this == UserRole.companyInstructor;

  /// Check if this role requires company verification to access company training features
  bool get requiresCompanyVerification =>
      this == UserRole.companyMember || this == UserRole.companyInstructor;

  /// Check if this role can access instructor dashboard (requires verification check)
  bool get canAccessInstructorDashboard =>
      this == UserRole.userInstructor ||
      this == UserRole.companyInstructor ||
      this == UserRole.admin;

  /// Check if this role can access company training dashboard
  bool get canAccessCompanyTrainingDashboard =>
      this == UserRole.companyMember ||
      this == UserRole.companyInstructor ||
      this == UserRole.admin;

  /// Check if this role can issue certificates
  bool get canIssueCertificates =>
      this == UserRole.userInstructor ||
      this == UserRole.companyInstructor ||
      this == UserRole.admin;

  /// Check if this role can moderate content
  bool get canModerateContent => this == UserRole.admin;

  /// Check if this role can review verifications
  bool get canReviewVerifications => this == UserRole.admin;
}
