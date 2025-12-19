import '../../../../core/auth/auth.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.role,
    super.fullName,
    super.avatarUrl,
    super.coverImageUrl,
    super.phone,
    super.bio,
    super.jobTitle,
    super.location,
    super.website,
    super.linkedinUrl,
    super.twitterUrl,
    super.githubUrl,
    super.skills,
    super.experience,
    super.education,
    super.certifications,
    super.languages,
    super.isEmailVerified,
    super.isProfileComplete,
    super.isAvailableForHire,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.coursesEnrolledCount,
    super.coursesCompletedCount,
    super.coursesCreatedCount,
    super.companiesOwned,
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      jobTitle: json['job_title'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      githubUrl: json['github_url'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      experience: (json['experience'] as List<dynamic>?)
              ?.map((e) =>
                  ExperienceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      education: (json['education'] as List<dynamic>?)
              ?.map(
                  (e) => EducationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) =>
                  CertificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      isAvailableForHire: json['is_available_for_hire'] as bool? ?? true,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      coursesEnrolledCount: json['courses_enrolled_count'] as int? ?? 0,
      coursesCompletedCount: json['courses_completed_count'] as int? ?? 0,
      coursesCreatedCount: json['courses_created_count'] as int? ?? 0,
      companiesOwned:
          (json['companies_owned'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      role: entity.role,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      coverImageUrl: entity.coverImageUrl,
      phone: entity.phone,
      bio: entity.bio,
      jobTitle: entity.jobTitle,
      location: entity.location,
      website: entity.website,
      linkedinUrl: entity.linkedinUrl,
      twitterUrl: entity.twitterUrl,
      githubUrl: entity.githubUrl,
      skills: entity.skills,
      experience: entity.experience,
      education: entity.education,
      certifications: entity.certifications,
      languages: entity.languages,
      isEmailVerified: entity.isEmailVerified,
      isProfileComplete: entity.isProfileComplete,
      isAvailableForHire: entity.isAvailableForHire,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
      postsCount: entity.postsCount,
      coursesEnrolledCount: entity.coursesEnrolledCount,
      coursesCompletedCount: entity.coursesCompletedCount,
      coursesCreatedCount: entity.coursesCreatedCount,
      companiesOwned: entity.companiesOwned,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'cover_image_url': coverImageUrl,
      'phone': phone,
      'bio': bio,
      'job_title': jobTitle,
      'location': location,
      'website': website,
      'linkedin_url': linkedinUrl,
      'twitter_url': twitterUrl,
      'github_url': githubUrl,
      'skills': skills,
      'experience': experience
          .map((e) => ExperienceModel.fromEntity(e).toJson())
          .toList(),
      'education':
          education.map((e) => EducationModel.fromEntity(e).toJson()).toList(),
      'certifications': certifications
          .map((e) => CertificationModel.fromEntity(e).toJson())
          .toList(),
      'languages': languages,
      'is_email_verified': isEmailVerified,
      'is_profile_complete': isProfileComplete,
      'is_available_for_hire': isAvailableForHire,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'courses_enrolled_count': coursesEnrolledCount,
      'courses_completed_count': coursesCompletedCount,
      'courses_created_count': coursesCreatedCount,
      'companies_owned': companiesOwned,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ExperienceModel extends ExperienceEntity {
  const ExperienceModel({
    required super.id,
    required super.title,
    required super.company,
    super.location,
    super.description,
    super.startDate,
    super.endDate,
    super.isCurrent,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
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

  factory ExperienceModel.fromEntity(ExperienceEntity entity) {
    return ExperienceModel(
      id: entity.id,
      title: entity.title,
      company: entity.company,
      location: entity.location,
      description: entity.description,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isCurrent: entity.isCurrent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_current': isCurrent,
    };
  }
}

class EducationModel extends EducationEntity {
  const EducationModel({
    required super.id,
    required super.institution,
    required super.degree,
    super.field,
    super.description,
    super.startDate,
    super.endDate,
    super.grade,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] as String,
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      field: json['field'] as String?,
      description: json['description'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      grade: json['grade'] as String?,
    );
  }

  factory EducationModel.fromEntity(EducationEntity entity) {
    return EducationModel(
      id: entity.id,
      institution: entity.institution,
      degree: entity.degree,
      field: entity.field,
      description: entity.description,
      startDate: entity.startDate,
      endDate: entity.endDate,
      grade: entity.grade,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'field': field,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'grade': grade,
    };
  }
}

class CertificationModel extends CertificationEntity {
  const CertificationModel({
    required super.id,
    required super.name,
    required super.issuingOrganization,
    super.credentialId,
    super.credentialUrl,
    super.issueDate,
    super.expirationDate,
    super.doesNotExpire,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      issuingOrganization: json['issuing_organization'] as String,
      credentialId: json['credential_id'] as String?,
      credentialUrl: json['credential_url'] as String?,
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'] as String)
          : null,
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      doesNotExpire: json['does_not_expire'] as bool? ?? false,
    );
  }

  factory CertificationModel.fromEntity(CertificationEntity entity) {
    return CertificationModel(
      id: entity.id,
      name: entity.name,
      issuingOrganization: entity.issuingOrganization,
      credentialId: entity.credentialId,
      credentialUrl: entity.credentialUrl,
      issueDate: entity.issueDate,
      expirationDate: entity.expirationDate,
      doesNotExpire: entity.doesNotExpire,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuing_organization': issuingOrganization,
      'credential_id': credentialId,
      'credential_url': credentialUrl,
      'issue_date': issueDate?.toIso8601String(),
      'expiration_date': expirationDate?.toIso8601String(),
      'does_not_expire': doesNotExpire,
    };
  }
}
