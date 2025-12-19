part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Perform a global search
class PerformSearch extends SearchEvent {
  const PerformSearch({
    required this.query,
    this.filters,
  });

  final String query;
  final SearchFilters? filters;

  @override
  List<Object?> get props => [query, filters];
}

/// Search only jobs
class SearchJobs extends SearchEvent {
  const SearchJobs({
    required this.query,
    this.location,
    this.employmentType,
    this.minSalary,
    this.maxSalary,
    this.isRemote,
    this.verifiedOnly,
    this.limit = 20,
    this.offset = 0,
  });

  final String query;
  final String? location;
  final String? employmentType;
  final double? minSalary;
  final double? maxSalary;
  final bool? isRemote;
  final bool? verifiedOnly;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [
        query,
        location,
        employmentType,
        minSalary,
        maxSalary,
        isRemote,
        verifiedOnly,
        limit,
        offset,
      ];
}

/// Search only courses
class SearchCourses extends SearchEvent {
  const SearchCourses({
    required this.query,
    this.category,
    this.level,
    this.minRating,
    this.maxPrice,
    this.verifiedOnly,
    this.limit = 20,
    this.offset = 0,
  });

  final String query;
  final String? category;
  final String? level;
  final double? minRating;
  final double? maxPrice;
  final bool? verifiedOnly;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [
        query,
        category,
        level,
        minRating,
        maxPrice,
        verifiedOnly,
        limit,
        offset,
      ];
}

/// Search only users
class SearchUsers extends SearchEvent {
  const SearchUsers({
    required this.query,
    this.role,
    this.location,
    this.verifiedOnly,
    this.limit = 20,
    this.offset = 0,
  });

  final String query;
  final String? role;
  final String? location;
  final bool? verifiedOnly;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [query, role, location, verifiedOnly, limit, offset];
}

/// Search only companies
class SearchCompanies extends SearchEvent {
  const SearchCompanies({
    required this.query,
    this.industry,
    this.location,
    this.verifiedOnly,
    this.limit = 20,
    this.offset = 0,
  });

  final String query;
  final String? industry;
  final String? location;
  final bool? verifiedOnly;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [query, industry, location, verifiedOnly, limit, offset];
}

/// Get search suggestions
class GetSuggestions extends SearchEvent {
  const GetSuggestions(this.query, {this.limit = 10});

  final String query;
  final int limit;

  @override
  List<Object?> get props => [query, limit];
}

/// Clear suggestions
class ClearSuggestions extends SearchEvent {
  const ClearSuggestions();
}

/// Load recent searches
class LoadRecentSearches extends SearchEvent {
  const LoadRecentSearches({this.limit = 10});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

/// Save a recent search
class SaveRecentSearch extends SearchEvent {
  const SaveRecentSearch(this.query, {this.resultCount});

  final String query;
  final int? resultCount;

  @override
  List<Object?> get props => [query, resultCount];
}

/// Delete a recent search
class DeleteRecentSearch extends SearchEvent {
  const DeleteRecentSearch(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Clear all recent searches
class ClearRecentSearches extends SearchEvent {
  const ClearRecentSearches();
}

/// Load popular searches
class LoadPopularSearches extends SearchEvent {
  const LoadPopularSearches({this.limit = 10});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

/// Update search filters
class UpdateFilters extends SearchEvent {
  const UpdateFilters(this.filters);

  final SearchFilters filters;

  @override
  List<Object?> get props => [filters];
}

/// Clear all filters
class ClearFilters extends SearchEvent {
  const ClearFilters();
}

/// Follow a user from search results
class FollowUserFromSearch extends SearchEvent {
  const FollowUserFromSearch(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Unfollow a user from search results
class UnfollowUserFromSearch extends SearchEvent {
  const UnfollowUserFromSearch(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Follow a company from search results
class FollowCompanyFromSearch extends SearchEvent {
  const FollowCompanyFromSearch(this.companyId);

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Unfollow a company from search results
class UnfollowCompanyFromSearch extends SearchEvent {
  const UnfollowCompanyFromSearch(this.companyId);

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Load more results (pagination)
class LoadMoreResults extends SearchEvent {
  const LoadMoreResults();
}

/// Clear search state
class ClearSearch extends SearchEvent {
  const ClearSearch();
}
