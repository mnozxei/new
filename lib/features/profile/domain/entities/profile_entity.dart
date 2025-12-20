import 'package:equatable/equatable.dart';

import '../../../../core/auth/auth.dart';
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
    this.headline,
    this.location,
    this.city,
    this.industry,
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
    this.profileVisibility = 'public',
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.coursesEnrolledCount = 0,
    this.coursesCompletedCount = 0,
    this.coursesCreatedCount = 0,
    this.certificatesCount = 0,
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
  final String? headline;
  final String? location;
  final String? city;
  final String? industry;
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
  final String profileVisibility;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int coursesEnrolledCount;
  final int coursesCompletedCount;
  final int coursesCreatedCount;
  final int certificatesCount;
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
    String? headline,
    String? location,
    String? city,
    String? industry,
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
    String? profileVisibility,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    int? coursesEnrolledCount,
    int? coursesCompletedCount,
    int? coursesCreatedCount,
    int? certificatesCount,
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
      headline: headline ?? this.headline,
      location: location ?? this.location,
      city: city ?? this.city,
      industry: industry ?? this.industry,
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
      profileVisibility: profileVisibility ?? this.profileVisibility,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      coursesEnrolledCount: coursesEnrolledCount ?? this.coursesEnrolledCount,
      coursesCompletedCount: coursesCompletedCount ?? this.coursesCompletedCount,
      coursesCreatedCount: coursesCreatedCount ?? this.coursesCreatedCount,
      certificatesCount: certificatesCount ?? this.certificatesCount,
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
        headline,
        location,
        city,
        industry,
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
        profileVisibility,
        followersCount,
        followingCount,
        postsCount,
        coursesEnrolledCount,
        coursesCompletedCount,
        coursesCreatedCount,
        certificatesCount,
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

  factory ExperienceEntity.fromJson(Map<String, dynamic> json) {
    return ExperienceEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company_name'] as String? ?? json['company'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company_name': company,
      'location': location,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_current': isCurrent,
    };
  }

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
