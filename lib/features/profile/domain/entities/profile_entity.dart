import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.coverImageUrl,
    this.phone,
    this.bio,
    this.jobTitle,
    this.location,
    this.website,
    this.linkedinUrl,
    this.twitterUrl,
    this.githubUrl,
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.certifications = const [],
    this.languages = const [],
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    this.isAvailableForHire = true,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.coursesEnrolledCount = 0,
    this.coursesCompletedCount = 0,
    this.coursesCreatedCount = 0,
    this.companiesOwned = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? phone;
  final String? bio;
  final String? jobTitle;
  final String? location;
  final String? website;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? githubUrl;
  final List<String> skills;
  final List<ExperienceEntity> experience;
  final List<EducationEntity> education;
  final List<CertificationEntity> certifications;
  final List<String> languages;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final bool isAvailableForHire;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int coursesEnrolledCount;
  final int coursesCompletedCount;
  final int coursesCreatedCount;
  final List<String> companiesOwned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role == UserRole.admin;
  bool get isInstructor => role == UserRole.instructor;
  bool get isUser => role == UserRole.user;

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

  ProfileEntity copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? avatarUrl,
    String? coverImageUrl,
    String? phone,
    String? bio,
    String? jobTitle,
    String? location,
    String? website,
    String? linkedinUrl,
    String? twitterUrl,
    String? githubUrl,
    List<String>? skills,
    List<ExperienceEntity>? experience,
    List<EducationEntity>? education,
    List<CertificationEntity>? certifications,
    List<String>? languages,
    bool? isEmailVerified,
    bool? isProfileComplete,
    bool? isAvailableForHire,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    int? coursesEnrolledCount,
    int? coursesCompletedCount,
    int? coursesCreatedCount,
    List<String>? companiesOwned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      jobTitle: jobTitle ?? this.jobTitle,
      location: location ?? this.location,
      website: website ?? this.website,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isAvailableForHire: isAvailableForHire ?? this.isAvailableForHire,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      coursesEnrolledCount: coursesEnrolledCount ?? this.coursesEnrolledCount,
      coursesCompletedCount: coursesCompletedCount ?? this.coursesCompletedCount,
      coursesCreatedCount: coursesCreatedCount ?? this.coursesCreatedCount,
      companiesOwned: companiesOwned ?? this.companiesOwned,
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
        coverImageUrl,
        phone,
        bio,
        jobTitle,
        location,
        website,
        linkedinUrl,
        twitterUrl,
        githubUrl,
        skills,
        experience,
        education,
        certifications,
        languages,
        isEmailVerified,
        isProfileComplete,
        isAvailableForHire,
        followersCount,
        followingCount,
        postsCount,
        coursesEnrolledCount,
        coursesCompletedCount,
        coursesCreatedCount,
        companiesOwned,
        createdAt,
        updatedAt,
      ];
}

class ExperienceEntity extends Equatable {
  const ExperienceEntity({
    required this.id,
    required this.title,
    required this.company,
    this.location,
    this.description,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  final String id;
  final String title;
  final String company;
  final String? location;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;

  @override
  List<Object?> get props => [
        id,
        title,
        company,
        location,
        description,
        startDate,
        endDate,
        isCurrent,
      ];
}

class EducationEntity extends Equatable {
  const EducationEntity({
    required this.id,
    required this.institution,
    required this.degree,
    this.field,
    this.description,
    this.startDate,
    this.endDate,
    this.grade,
  });

  final String id;
  final String institution;
  final String degree;
  final String? field;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? grade;

  @override
  List<Object?> get props => [
        id,
        institution,
        degree,
        field,
        description,
        startDate,
        endDate,
        grade,
      ];
}

class CertificationEntity extends Equatable {
  const CertificationEntity({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    this.credentialId,
    this.credentialUrl,
    this.issueDate,
    this.expirationDate,
    this.doesNotExpire = false,
  });

  final String id;
  final String name;
  final String issuingOrganization;
  final String? credentialId;
  final String? credentialUrl;
  final DateTime? issueDate;
  final DateTime? expirationDate;
  final bool doesNotExpire;

  @override
  List<Object?> get props => [
        id,
        name,
        issuingOrganization,
        credentialId,
        credentialUrl,
        issueDate,
        expirationDate,
        doesNotExpire,
      ];
}
