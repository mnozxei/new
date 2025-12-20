import '../entities/profile_entity.dart';

/// Profile completion weights as specified
class ProfileCompletionWeights {
  static const double fullName = 0.10;
  static const double avatar = 0.10;
  static const double headline = 0.10;
  static const double bio = 0.10;
  static const double city = 0.05;
  static const double skills = 0.10;
  static const double industry = 0.10;
  static const double workHistory = 0.20;
  static const double completedCourse = 0.10;
  static const double certificate = 0.05;
}

/// Represents a missing item in profile completion
class MissingProfileItem {
  const MissingProfileItem({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.route,
    required this.weight,
  });

  final String key;
  final String labelAr;
  final String labelEn;
  final String route;
  final double weight;

  String getLabel(String locale) => locale == 'ar' ? labelAr : labelEn;
}

/// Result of profile completion calculation
class ProfileCompletionResult {
  const ProfileCompletionResult({
    required this.percent,
    required this.missingItems,
    required this.completedItems,
  });

  final int percent;
  final List<MissingProfileItem> missingItems;
  final List<String> completedItems;

  bool get isComplete => percent >= 100;
  bool get hasWorkHistory => completedItems.contains('workHistory');
  bool get hasCertificate => completedItems.contains('certificate');
}

/// Service to compute profile completion percentage
class ProfileCompletionService {
  const ProfileCompletionService._();

  static const _missingItemDefinitions = <String, MissingProfileItem>{
    'fullName': MissingProfileItem(
      key: 'fullName',
      labelAr: 'الاسم الكامل',
      labelEn: 'Full Name',
      route: '/profile/edit#name',
      weight: ProfileCompletionWeights.fullName,
    ),
    'avatar': MissingProfileItem(
      key: 'avatar',
      labelAr: 'صورة الملف الشخصي',
      labelEn: 'Profile Photo',
      route: '/profile/edit#avatar',
      weight: ProfileCompletionWeights.avatar,
    ),
    'headline': MissingProfileItem(
      key: 'headline',
      labelAr: 'العنوان المهني',
      labelEn: 'Professional Headline',
      route: '/profile/edit#headline',
      weight: ProfileCompletionWeights.headline,
    ),
    'bio': MissingProfileItem(
      key: 'bio',
      labelAr: 'نبذة عنك',
      labelEn: 'About You',
      route: '/profile/edit#bio',
      weight: ProfileCompletionWeights.bio,
    ),
    'city': MissingProfileItem(
      key: 'city',
      labelAr: 'المدينة',
      labelEn: 'City',
      route: '/profile/edit#location',
      weight: ProfileCompletionWeights.city,
    ),
    'skills': MissingProfileItem(
      key: 'skills',
      labelAr: 'المهارات',
      labelEn: 'Skills',
      route: '/profile/edit#skills',
      weight: ProfileCompletionWeights.skills,
    ),
    'industry': MissingProfileItem(
      key: 'industry',
      labelAr: 'مجال العمل',
      labelEn: 'Industry',
      route: '/profile/edit#industry',
      weight: ProfileCompletionWeights.industry,
    ),
    'workHistory': MissingProfileItem(
      key: 'workHistory',
      labelAr: 'الخبرات العملية',
      labelEn: 'Work History',
      route: '/profile/experiences',
      weight: ProfileCompletionWeights.workHistory,
    ),
    'completedCourse': MissingProfileItem(
      key: 'completedCourse',
      labelAr: 'إكمال دورة واحدة',
      labelEn: 'Complete a Course',
      route: '/courses',
      weight: ProfileCompletionWeights.completedCourse,
    ),
    'certificate': MissingProfileItem(
      key: 'certificate',
      labelAr: 'الحصول على شهادة',
      labelEn: 'Earn a Certificate',
      route: '/my-learning',
      weight: ProfileCompletionWeights.certificate,
    ),
  };

  /// Compute profile completion percentage and missing items
  static ProfileCompletionResult compute({
    required ProfileEntity profile,
    int? experiencesCount,
    int? completedCoursesCount,
    int? certificatesCount,
  }) {
    double score = 0;
    final missingItems = <MissingProfileItem>[];
    final completedItems = <String>[];

    // Full Name (10%)
    if (profile.fullName != null && profile.fullName!.trim().isNotEmpty) {
      score += ProfileCompletionWeights.fullName;
      completedItems.add('fullName');
    } else {
      missingItems.add(_missingItemDefinitions['fullName']!);
    }

    // Avatar (10%)
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      score += ProfileCompletionWeights.avatar;
      completedItems.add('avatar');
    } else {
      missingItems.add(_missingItemDefinitions['avatar']!);
    }

    // Headline (10%) - use headline or jobTitle
    final hasHeadline = (profile.headline != null && profile.headline!.trim().isNotEmpty) ||
        (profile.jobTitle != null && profile.jobTitle!.trim().isNotEmpty);
    if (hasHeadline) {
      score += ProfileCompletionWeights.headline;
      completedItems.add('headline');
    } else {
      missingItems.add(_missingItemDefinitions['headline']!);
    }

    // Bio (10%)
    if (profile.bio != null && profile.bio!.trim().isNotEmpty) {
      score += ProfileCompletionWeights.bio;
      completedItems.add('bio');
    } else {
      missingItems.add(_missingItemDefinitions['bio']!);
    }

    // City (5%) - use city or location
    final hasCity = (profile.city != null && profile.city!.trim().isNotEmpty) ||
        (profile.location != null && profile.location!.trim().isNotEmpty);
    if (hasCity) {
      score += ProfileCompletionWeights.city;
      completedItems.add('city');
    } else {
      missingItems.add(_missingItemDefinitions['city']!);
    }

    // Skills (10%)
    if (profile.skills.isNotEmpty) {
      score += ProfileCompletionWeights.skills;
      completedItems.add('skills');
    } else {
      missingItems.add(_missingItemDefinitions['skills']!);
    }

    // Industry (10%)
    if (profile.industry != null && profile.industry!.trim().isNotEmpty) {
      score += ProfileCompletionWeights.industry;
      completedItems.add('industry');
    } else {
      missingItems.add(_missingItemDefinitions['industry']!);
    }

    // Work History (20%) - at least 1 experience
    final expCount = experiencesCount ?? profile.experience.length;
    if (expCount > 0) {
      score += ProfileCompletionWeights.workHistory;
      completedItems.add('workHistory');
    } else {
      missingItems.add(_missingItemDefinitions['workHistory']!);
    }

    // Completed Course (10%) - at least 1 completed course
    final coursesCount = completedCoursesCount ?? profile.coursesCompletedCount;
    if (coursesCount > 0) {
      score += ProfileCompletionWeights.completedCourse;
      completedItems.add('completedCourse');
    } else {
      missingItems.add(_missingItemDefinitions['completedCourse']!);
    }

    // Certificate (5%) - at least 1 certificate
    final certsCount = certificatesCount ?? profile.certificatesCount;
    if (certsCount > 0) {
      score += ProfileCompletionWeights.certificate;
      completedItems.add('certificate');
    } else {
      missingItems.add(_missingItemDefinitions['certificate']!);
    }

    return ProfileCompletionResult(
      percent: (score * 100).round(),
      missingItems: missingItems,
      completedItems: completedItems,
    );
  }

  /// Get the next actionable item to improve profile
  static MissingProfileItem? getNextAction(ProfileCompletionResult result) {
    if (result.missingItems.isEmpty) return null;

    // Sort by weight (highest first) to suggest most impactful action
    final sorted = List<MissingProfileItem>.from(result.missingItems)
      ..sort((a, b) => b.weight.compareTo(a.weight));

    return sorted.first;
  }
}
