part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading search results
class SearchLoading extends SearchState {
  const SearchLoading({
    required this.query,
    this.filters,
  });

  final String query;
  final SearchFilters? filters;

  @override
  List<Object?> get props => [query, filters];
}

/// Loading more results (pagination)
class SearchLoadingMore extends SearchState {
  const SearchLoadingMore({required this.currentResults});

  final SearchResults currentResults;

  @override
  List<Object?> get props => [currentResults];
}

/// Global search results loaded
class SearchResultsLoaded extends SearchState {
  const SearchResultsLoaded({
    required this.results,
    required this.filters,
    required this.hasMore,
    required this.offset,
  });

  final SearchResults results;
  final SearchFilters filters;
  final bool hasMore;
  final int offset;

  @override
  List<Object?> get props => [results, filters, hasMore, offset];
}

/// Jobs search results loaded
class JobsSearchResultsLoaded extends SearchState {
  const JobsSearchResultsLoaded({
    required this.jobs,
    required this.query,
    required this.hasMore,
    required this.offset,
  });

  final List<JobSearchResult> jobs;
  final String query;
  final bool hasMore;
  final int offset;

  @override
  List<Object?> get props => [jobs, query, hasMore, offset];
}

/// Courses search results loaded
class CoursesSearchResultsLoaded extends SearchState {
  const CoursesSearchResultsLoaded({
    required this.courses,
    required this.query,
    required this.hasMore,
    required this.offset,
  });

  final List<CourseSearchResult> courses;
  final String query;
  final bool hasMore;
  final int offset;

  @override
  List<Object?> get props => [courses, query, hasMore, offset];
}

/// Users search results loaded
class UsersSearchResultsLoaded extends SearchState {
  const UsersSearchResultsLoaded({
    required this.users,
    required this.query,
    required this.hasMore,
    required this.offset,
  });

  final List<UserSearchResult> users;
  final String query;
  final bool hasMore;
  final int offset;

  @override
  List<Object?> get props => [users, query, hasMore, offset];
}

/// Companies search results loaded
class CompaniesSearchResultsLoaded extends SearchState {
  const CompaniesSearchResultsLoaded({
    required this.companies,
    required this.query,
    required this.hasMore,
    required this.offset,
  });

  final List<CompanySearchResult> companies;
  final String query;
  final bool hasMore;
  final int offset;

  @override
  List<Object?> get props => [companies, query, hasMore, offset];
}

/// Suggestions loaded
class SuggestionsLoaded extends SearchState {
  const SuggestionsLoaded(this.suggestions);

  final List<SearchSuggestion> suggestions;

  @override
  List<Object?> get props => [suggestions];
}

/// Suggestions cleared
class SuggestionsCleared extends SearchState {
  const SuggestionsCleared();
}

/// Recent searches loaded
class RecentSearchesLoaded extends SearchState {
  const RecentSearchesLoaded(this.recentSearches);

  final List<RecentSearch> recentSearches;

  @override
  List<Object?> get props => [recentSearches];
}

/// Popular searches loaded
class PopularSearchesLoaded extends SearchState {
  const PopularSearchesLoaded(this.popularSearches);

  final List<PopularSearch> popularSearches;

  @override
  List<Object?> get props => [popularSearches];
}

/// User follow status changed
class UserFollowStatusChanged extends SearchState {
  const UserFollowStatusChanged(this.userId, {required this.isFollowing});

  final String userId;
  final bool isFollowing;

  @override
  List<Object?> get props => [userId, isFollowing];
}

/// Company follow status changed
class CompanyFollowStatusChanged extends SearchState {
  const CompanyFollowStatusChanged(this.companyId, {required this.isFollowing});

  final String companyId;
  final bool isFollowing;

  @override
  List<Object?> get props => [companyId, isFollowing];
}

/// Error state
class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
