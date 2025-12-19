import '../../domain/entities/search_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required SearchRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final SearchRemoteDataSource _remoteDataSource;

  @override
  Future<SearchResults> search(
    String query, {
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  }) {
    return _remoteDataSource.search(
      query,
      filters: filters,
      limit: limit,
      offset: offset,
    );
  }

  @override
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
  }) {
    return _remoteDataSource.searchJobs(
      query,
      location: location,
      employmentType: employmentType,
      minSalary: minSalary,
      maxSalary: maxSalary,
      isRemote: isRemote,
      verifiedOnly: verifiedOnly,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<CourseSearchResult>> searchCourses(
    String query, {
    String? category,
    String? level,
    double? minRating,
    double? maxPrice,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  }) {
    return _remoteDataSource.searchCourses(
      query,
      category: category,
      level: level,
      minRating: minRating,
      maxPrice: maxPrice,
      verifiedOnly: verifiedOnly,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<UserSearchResult>> searchUsers(
    String query, {
    String? role,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  }) {
    return _remoteDataSource.searchUsers(
      query,
      role: role,
      location: location,
      verifiedOnly: verifiedOnly,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<CompanySearchResult>> searchCompanies(
    String query, {
    String? industry,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  }) {
    return _remoteDataSource.searchCompanies(
      query,
      industry: industry,
      location: location,
      verifiedOnly: verifiedOnly,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  }) {
    return _remoteDataSource.getSuggestions(query, limit: limit);
  }

  @override
  Future<List<RecentSearch>> getRecentSearches({int limit = 10}) {
    return _remoteDataSource.getRecentSearches(limit: limit);
  }

  @override
  Future<void> saveRecentSearch(String query, {int? resultCount}) {
    return _remoteDataSource.saveRecentSearch(query, resultCount: resultCount);
  }

  @override
  Future<void> clearRecentSearches() {
    return _remoteDataSource.clearRecentSearches();
  }

  @override
  Future<void> deleteRecentSearch(String query) {
    return _remoteDataSource.deleteRecentSearch(query);
  }

  @override
  Future<List<PopularSearch>> getPopularSearches({int limit = 10}) {
    return _remoteDataSource.getPopularSearches(limit: limit);
  }

  @override
  Future<void> followUser(String userId) {
    return _remoteDataSource.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) {
    return _remoteDataSource.unfollowUser(userId);
  }

  @override
  Future<void> followCompany(String companyId) {
    return _remoteDataSource.followCompany(companyId);
  }

  @override
  Future<void> unfollowCompany(String companyId) {
    return _remoteDataSource.unfollowCompany(companyId);
  }
}
