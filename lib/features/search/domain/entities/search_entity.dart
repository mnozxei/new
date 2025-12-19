import 'package:equatable/equatable.dart';

/// Search result types
enum SearchResultType {
  job,
  course,
  user,
  company,
  all,
}

/// Unified search result container
class SearchResults extends Equatable {
  const SearchResults({
    required this.query,
    required this.jobs,
    required this.courses,
    required this.users,
    required this.companies,
    required this.totalCount,
  });

  final String query;
  final List<JobSearchResult> jobs;
  final List<CourseSearchResult> courses;
  final List<UserSearchResult> users;
  final List<CompanySearchResult> companies;
  final int totalCount;

  static const empty = SearchResults(
    query: '',
    jobs: [],
    courses: [],
    users: [],
    companies: [],
    totalCount: 0,
  );

  @override
  List<Object?> get props => [query, jobs, courses, users, companies, totalCount];
}

/// Job search result
class JobSearchResult extends Equatable {
  const JobSearchResult({
    required this.id,
    required this.title,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.location,
    required this.employmentType,
    required this.salaryMin,
    required this.salaryMax,
    required this.currency,
    required this.isRemote,
    required this.isCompanyVerified,
    required this.postedAt,
  });

  final String id;
  final String title;
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String location;
  final String employmentType;
  final double salaryMin;
  final double salaryMax;
  final String currency;
  final bool isRemote;
  final bool isCompanyVerified;
  final DateTime postedAt;

  factory JobSearchResult.fromJson(Map<String, dynamic> json) {
    return JobSearchResult(
      id: json['id'] as String,
      title: json['title'] as String,
      companyId: json['company_id'] as String,
      companyName: json['company']?['name'] as String? ?? '',
      companyLogo: json['company']?['logo_url'] as String?,
      location: json['location'] as String? ?? '',
      employmentType: json['employment_type'] as String? ?? 'full_time',
      salaryMin: (json['salary_min'] as num?)?.toDouble() ?? 0,
      salaryMax: (json['salary_max'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      isRemote: json['is_remote'] as bool? ?? false,
      isCompanyVerified: json['company']?['is_verified'] as bool? ?? false,
      postedAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        companyId,
        companyName,
        companyLogo,
        location,
        employmentType,
        salaryMin,
        salaryMax,
        currency,
        isRemote,
        isCompanyVerified,
        postedAt,
      ];
}

/// Course search result
class CourseSearchResult extends Equatable {
  const CourseSearchResult({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.instructorId,
    required this.instructorName,
    this.instructorAvatar,
    required this.price,
    required this.currency,
    required this.rating,
    required this.ratingCount,
    required this.enrollmentCount,
    required this.level,
    required this.isInstructorVerified,
  });

  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String instructorId;
  final String instructorName;
  final String? instructorAvatar;
  final double price;
  final String currency;
  final double rating;
  final int ratingCount;
  final int enrollmentCount;
  final String level;
  final bool isInstructorVerified;

  factory CourseSearchResult.fromJson(Map<String, dynamic> json) {
    return CourseSearchResult(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      instructorId: json['instructor_id'] as String,
      instructorName: json['instructor']?['display_name'] as String? ?? '',
      instructorAvatar: json['instructor']?['avatar_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      enrollmentCount: json['enrollment_count'] as int? ?? 0,
      level: json['level'] as String? ?? 'beginner',
      isInstructorVerified: json['instructor']?['is_verified'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnailUrl,
        instructorId,
        instructorName,
        instructorAvatar,
        price,
        currency,
        rating,
        ratingCount,
        enrollmentCount,
        level,
        isInstructorVerified,
      ];
}

/// User search result
class UserSearchResult extends Equatable {
  const UserSearchResult({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.headline,
    this.location,
    required this.role,
    required this.followerCount,
    required this.isVerified,
    required this.isFollowing,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? headline;
  final String? location;
  final String role;
  final int followerCount;
  final bool isVerified;
  final bool isFollowing;

  factory UserSearchResult.fromJson(Map<String, dynamic> json, {bool isFollowing = false}) {
    return UserSearchResult(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      headline: json['headline'] as String?,
      location: json['location'] as String?,
      role: json['role'] as String? ?? 'user',
      followerCount: json['follower_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isFollowing: isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        avatarUrl,
        headline,
        location,
        role,
        followerCount,
        isVerified,
        isFollowing,
      ];
}

/// Company search result
class CompanySearchResult extends Equatable {
  const CompanySearchResult({
    required this.id,
    required this.name,
    this.logoUrl,
    this.industry,
    this.location,
    this.description,
    required this.employeeCount,
    required this.openJobsCount,
    required this.followerCount,
    required this.isVerified,
    required this.isFollowing,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? industry;
  final String? location;
  final String? description;
  final int employeeCount;
  final int openJobsCount;
  final int followerCount;
  final bool isVerified;
  final bool isFollowing;

  factory CompanySearchResult.fromJson(Map<String, dynamic> json, {bool isFollowing = false}) {
    return CompanySearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      industry: json['industry'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      employeeCount: json['employee_count'] as int? ?? 0,
      openJobsCount: json['open_jobs_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isFollowing: isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
        industry,
        location,
        description,
        employeeCount,
        openJobsCount,
        followerCount,
        isVerified,
        isFollowing,
      ];
}

/// Search filters
class SearchFilters extends Equatable {
  const SearchFilters({
    this.type = SearchResultType.all,
    this.location,
    this.category,
    this.minSalary,
    this.maxSalary,
    this.employmentType,
    this.isRemote,
    this.courseLevel,
    this.minRating,
    this.maxPrice,
    this.isVerifiedOnly = false,
  });

  final SearchResultType type;
  final String? location;
  final String? category;
  final double? minSalary;
  final double? maxSalary;
  final String? employmentType;
  final bool? isRemote;
  final String? courseLevel;
  final double? minRating;
  final double? maxPrice;
  final bool isVerifiedOnly;

  SearchFilters copyWith({
    SearchResultType? type,
    String? location,
    String? category,
    double? minSalary,
    double? maxSalary,
    String? employmentType,
    bool? isRemote,
    String? courseLevel,
    double? minRating,
    double? maxPrice,
    bool? isVerifiedOnly,
  }) {
    return SearchFilters(
      type: type ?? this.type,
      location: location ?? this.location,
      category: category ?? this.category,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      employmentType: employmentType ?? this.employmentType,
      isRemote: isRemote ?? this.isRemote,
      courseLevel: courseLevel ?? this.courseLevel,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      isVerifiedOnly: isVerifiedOnly ?? this.isVerifiedOnly,
    );
  }

  @override
  List<Object?> get props => [
        type,
        location,
        category,
        minSalary,
        maxSalary,
        employmentType,
        isRemote,
        courseLevel,
        minRating,
        maxPrice,
        isVerifiedOnly,
      ];
}

/// Recent search item
class RecentSearch extends Equatable {
  const RecentSearch({
    required this.query,
    required this.searchedAt,
    this.resultCount,
  });

  final String query;
  final DateTime searchedAt;
  final int? resultCount;

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      query: json['query'] as String,
      searchedAt: DateTime.parse(json['searched_at'] as String),
      resultCount: json['result_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'searched_at': searchedAt.toIso8601String(),
        'result_count': resultCount,
      };

  @override
  List<Object?> get props => [query, searchedAt, resultCount];
}

/// Popular search item
class PopularSearch extends Equatable {
  const PopularSearch({
    required this.query,
    required this.searchCount,
    required this.resultType,
    required this.resultCount,
  });

  final String query;
  final int searchCount;
  final SearchResultType resultType;
  final int resultCount;

  factory PopularSearch.fromJson(Map<String, dynamic> json) {
    return PopularSearch(
      query: json['query'] as String,
      searchCount: json['search_count'] as int,
      resultType: SearchResultType.values.firstWhere(
        (t) => t.name == json['result_type'],
        orElse: () => SearchResultType.all,
      ),
      resultCount: json['result_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [query, searchCount, resultType, resultCount];
}

/// Search suggestion
class SearchSuggestion extends Equatable {
  const SearchSuggestion({
    required this.text,
    required this.type,
    this.entityId,
  });

  final String text;
  final SearchResultType type;
  final String? entityId;

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      text: json['text'] as String,
      type: SearchResultType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SearchResultType.all,
      ),
      entityId: json['entity_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [text, type, entityId];
}
