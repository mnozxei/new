import '../entities/search_entity.dart';

abstract class SearchRepository {
  /// Perform a global search across all entity types
  Future<SearchResults> search(
    String query, {
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  });

  /// Search only jobs
  Future<List<JobSearchResult>> searchJobs(
    String query, {
    String? location,
    String? employmentType,
    double? minSalary,
    double? maxSalary,
    bool? isRemote,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  });

  /// Search only courses
  Future<List<CourseSearchResult>> searchCourses(
    String query, {
    String? category,
    String? level,
    double? minRating,
    double? maxPrice,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  });

  /// Search only users
  Future<List<UserSearchResult>> searchUsers(
    String query, {
    String? role,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  });

  /// Search only companies
  Future<List<CompanySearchResult>> searchCompanies(
    String query, {
    String? industry,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  });

  /// Get search suggestions as user types
  Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  });

  /// Get recent searches for current user
  Future<List<RecentSearch>> getRecentSearches({int limit = 10});

  /// Save a search to recent searches
  Future<void> saveRecentSearch(String query, {int? resultCount});

  /// Clear recent searches
  Future<void> clearRecentSearches();

  /// Delete a specific recent search
  Future<void> deleteRecentSearch(String query);

  /// Get popular searches
  Future<List<PopularSearch>> getPopularSearches({int limit = 10});

  /// Follow/unfollow a user from search
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);

  /// Follow/unfollow a company from search
  Future<void> followCompany(String companyId);
  Future<void> unfollowCompany(String companyId);
}
