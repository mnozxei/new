import 'package:equatable/equatable.dart';

import '../../../../core/auth/auth.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.jobTitle,
    this.location,
    this.website,
    this.linkedinUrl,
    this.twitterUrl,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    this.companyId,
    this.isInstructorVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final String? jobTitle;
  final String? location;
  final String? website;
  final String? linkedinUrl;
  final String? twitterUrl;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final String? companyId;
  final bool isInstructorVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Check role-related properties
  bool get isAdmin => role.isAdmin;
  bool get isInstructor => role.isInstructor;
  bool get isUser => role == UserRole.user;
  bool get isVisitor => role == UserRole.visitor;
  bool get isCompanyMember => role.isCompanyRole;
  bool get canCreateCourses => role.canCreateCourses;
  bool get isAuthenticated => role.isAuthenticated;

  /// Check if user has a specific permission
  bool hasPermission(Permission permission) => role.hasPermission(permission);

  String get displayName => fullName ?? email.split('@').first;

  String? get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  UserEntity copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? avatarUrl,
    String? phone,
    String? bio,
    String? jobTitle,
    String? location,
    String? website,
    String? linkedinUrl,
    String? twitterUrl,
    bool? isEmailVerified,
    bool? isProfileComplete,
    String? companyId,
    bool? isInstructorVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      jobTitle: jobTitle ?? this.jobTitle,
      location: location ?? this.location,
      website: website ?? this.website,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      companyId: companyId ?? this.companyId,
      isInstructorVerified: isInstructorVerified ?? this.isInstructorVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        fullName,
        avatarUrl,
        phone,
        bio,
        jobTitle,
        location,
        website,
        linkedinUrl,
        twitterUrl,
        isEmailVerified,
        isProfileComplete,
        companyId,
        isInstructorVerified,
        createdAt,
        updatedAt,
      ];
}
