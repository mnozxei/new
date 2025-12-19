import 'package:equatable/equatable.dart';

/// Role within a company
enum CompanyMemberRole {
  owner('owner'),
  admin('admin'),
  instructor('instructor'),
  member('member');

  const CompanyMemberRole(this.value);
  final String value;

  static CompanyMemberRole fromString(String value) {
    return CompanyMemberRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CompanyMemberRole.member,
    );
  }

  String get displayName {
    switch (this) {
      case CompanyMemberRole.owner:
        return 'مالك';
      case CompanyMemberRole.admin:
        return 'مدير';
      case CompanyMemberRole.instructor:
        return 'مدرب';
      case CompanyMemberRole.member:
        return 'عضو';
    }
  }

  String get displayNameEn {
    switch (this) {
      case CompanyMemberRole.owner:
        return 'Owner';
      case CompanyMemberRole.admin:
        return 'Admin';
      case CompanyMemberRole.instructor:
        return 'Instructor';
      case CompanyMemberRole.member:
        return 'Member';
    }
  }
}

/// Status of company membership
enum CompanyMemberStatus {
  pending('pending'),
  active('active'),
  suspended('suspended'),
  removed('removed');

  const CompanyMemberStatus(this.value);
  final String value;

  static CompanyMemberStatus fromString(String value) {
    return CompanyMemberStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CompanyMemberStatus.pending,
    );
  }
}

/// Company member entity - represents a user's membership in a company
class CompanyMemberEntity extends Equatable {
  const CompanyMemberEntity({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.role,
    this.status = CompanyMemberStatus.active,
    this.title,
    this.department,
    this.canPostJobs = false,
    this.canManageMembers = false,
    this.canCreateCourses = false,
    this.canManageCourses = false,
    this.invitedBy,
    this.invitedAt,
    this.joinedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String userId;
  final CompanyMemberRole role;
  final CompanyMemberStatus status;
  final String? title;
  final String? department;
  final bool canPostJobs;
  final bool canManageMembers;
  final bool canCreateCourses;
  final bool canManageCourses;
  final String? invitedBy;
  final DateTime? invitedAt;
  final DateTime? joinedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Check if this member is active
  bool get isActive => status == CompanyMemberStatus.active;

  /// Check if this member is an owner
  bool get isOwner => role == CompanyMemberRole.owner;

  /// Check if this member is an admin (owner or admin)
  bool get isAdmin =>
      role == CompanyMemberRole.owner || role == CompanyMemberRole.admin;

  /// Check if this member is an instructor
  bool get isInstructor => role == CompanyMemberRole.instructor;

  /// Check if this member can perform administrative actions
  bool get canAdminister => isOwner || (isAdmin && canManageMembers);

  CompanyMemberEntity copyWith({
    String? id,
    String? companyId,
    String? userId,
    CompanyMemberRole? role,
    CompanyMemberStatus? status,
    String? title,
    String? department,
    bool? canPostJobs,
    bool? canManageMembers,
    bool? canCreateCourses,
    bool? canManageCourses,
    String? invitedBy,
    DateTime? invitedAt,
    DateTime? joinedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyMemberEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      title: title ?? this.title,
      department: department ?? this.department,
      canPostJobs: canPostJobs ?? this.canPostJobs,
      canManageMembers: canManageMembers ?? this.canManageMembers,
      canCreateCourses: canCreateCourses ?? this.canCreateCourses,
      canManageCourses: canManageCourses ?? this.canManageCourses,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedAt: invitedAt ?? this.invitedAt,
      joinedAt: joinedAt ?? this.joinedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        userId,
        role,
        status,
        title,
        department,
        canPostJobs,
        canManageMembers,
        canCreateCourses,
        canManageCourses,
        invitedBy,
        invitedAt,
        joinedAt,
        createdAt,
        updatedAt,
      ];
}
