import 'package:equatable/equatable.dart';

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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role == UserRole.admin;
  bool get isInstructor => role == UserRole.instructor;
  bool get isUser => role == UserRole.user;

  String get displayName => fullName ?? email.split('@').first;

  String? get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return email[0].toUpperCase();
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
        createdAt,
        updatedAt,
      ];
}

enum UserRole {
  user,
  instructor,
  admin;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'instructor':
        return UserRole.instructor;
      default:
        return UserRole.user;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.user:
        return 'User';
    }
  }
}
