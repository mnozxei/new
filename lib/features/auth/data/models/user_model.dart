import '../../../../core/auth/auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.fullName,
    super.avatarUrl,
    super.phone,
    super.bio,
    super.jobTitle,
    super.location,
    super.website,
    super.linkedinUrl,
    super.twitterUrl,
    super.isEmailVerified,
    super.isProfileComplete,
    super.companyId,
    super.isInstructorVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      jobTitle: json['job_title'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      companyId: json['company_id'] as String?,
      isInstructorVerified: json['is_instructor_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      role: entity.role,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      phone: entity.phone,
      bio: entity.bio,
      jobTitle: entity.jobTitle,
      location: entity.location,
      website: entity.website,
      linkedinUrl: entity.linkedinUrl,
      twitterUrl: entity.twitterUrl,
      isEmailVerified: entity.isEmailVerified,
      isProfileComplete: entity.isProfileComplete,
      companyId: entity.companyId,
      isInstructorVerified: entity.isInstructorVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create a visitor user model (for unauthenticated browsing)
  factory UserModel.visitor() {
    return const UserModel(
      id: 'visitor',
      email: 'visitor@tamad.hub',
      role: UserRole.visitor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'bio': bio,
      'job_title': jobTitle,
      'location': location,
      'website': website,
      'linkedin_url': linkedinUrl,
      'twitter_url': twitterUrl,
      'is_email_verified': isEmailVerified,
      'is_profile_complete': isProfileComplete,
      'company_id': companyId,
      'is_instructor_verified': isInstructorVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
}
