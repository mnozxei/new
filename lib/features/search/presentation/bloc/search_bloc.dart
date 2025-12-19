import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/search_entity.dart';
import '../../domain/repositories/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchRepository repository})
      : _repository = repository,
        super(const SearchInitial()) {
    on<PerformSearch>(_onPerformSearch);
    on<SearchJobs>(_onSearchJobs);
    on<SearchCourses>(_onSearchCourses);
    on<SearchUsers>(_onSearchUsers);
    on<SearchCompanies>(_onSearchCompanies);
    on<GetSuggestions>(_onGetSuggestions);
    on<ClearSuggestions>(_onClearSuggestions);
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<SaveRecentSearch>(_onSaveRecentSearch);
    on<DeleteRecentSearch>(_onDeleteRecentSearch);
    on<ClearRecentSearches>(_onClearRecentSearches);
    on<LoadPopularSearches>(_onLoadPopularSearches);
    on<UpdateFilters>(_onUpdateFilters);
    on<ClearFilters>(_onClearFilters);
    on<FollowUserFromSearch>(_onFollowUser);
    on<UnfollowUserFromSearch>(_onUnfollowUser);
    on<FollowCompanyFromSearch>(_onFollowCompany);
    on<UnfollowCompanyFromSearch>(_onUnfollowCompany);
    on<LoadMoreResults>(_onLoadMoreResults);
    on<ClearSearch>(_onClearSearch);
  }

  final SearchRepository _repository;
  Timer? _debounceTimer;

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(SearchLoading(query: event.query, filters: event.filters));

    try {
      final results = await _repository.search(
        event.query,
        filters: event.filters,
        limit: 20,
        offset: 0,
      );

      // Save to recent searches
      _repository.saveRecentSearch(event.query, resultCount: results.totalCount);

      emit(SearchResultsLoaded(
        results: results,
        filters: event.filters ?? const SearchFilters(),
        hasMore: results.totalCount > 20,
        offset: 20,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchJobs(
    SearchJobs event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(query: event.query, filters: null));

    try {
      final jobs = await _repository.searchJobs(
        event.query,
        location: event.location,
        employmentType: event.employmentType,
        minSalary: event.minSalary,
        maxSalary: event.maxSalary,
        isRemote: event.isRemote,
        verifiedOnly: event.verifiedOnly,
        limit: event.limit,
        offset: event.offset,
      );

      emit(JobsSearchResultsLoaded(
        jobs: jobs,
        query: event.query,
        hasMore: jobs.length >= event.limit,
        offset: event.offset + event.limit,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchCourses(
    SearchCourses event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(query: event.query, filters: null));

    try {
      final courses = await _repository.searchCourses(
        event.query,
        category: event.category,
        level: event.level,
        minRating: event.minRating,
        maxPrice: event.maxPrice,
        verifiedOnly: event.verifiedOnly,
        limit: event.limit,
        offset: event.offset,
      );

      emit(CoursesSearchResultsLoaded(
        courses: courses,
        query: event.query,
        hasMore: courses.length >= event.limit,
        offset: event.offset + event.limit,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(query: event.query, filters: null));

    try {
      final users = await _repository.searchUsers(
        event.query,
        role: event.role,
        location: event.location,
        verifiedOnly: event.verifiedOnly,
        limit: event.limit,
        offset: event.offset,
      );

      emit(UsersSearchResultsLoaded(
        users: users,
        query: event.query,
        hasMore: users.length >= event.limit,
        offset: event.offset + event.limit,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchCompanies(
    SearchCompanies event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(query: event.query, filters: null));

    try {
      final companies = await _repository.searchCompanies(
        event.query,
        industry: event.industry,
        location: event.location,
        verifiedOnly: event.verifiedOnly,
        limit: event.limit,
        offset: event.offset,
      );

      emit(CompaniesSearchResultsLoaded(
        companies: companies,
        query: event.query,
        hasMore: companies.length >= event.limit,
        offset: event.offset + event.limit,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onGetSuggestions(
    GetSuggestions event,
    Emitter<SearchState> emit,
  ) async {
    // Debounce suggestions
    _debounceTimer?.cancel();

    if (event.query.trim().isEmpty) {
      emit(const SuggestionsCleared());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final suggestions = await _repository.getSuggestions(
          event.query,
          limit: event.limit,
        );
        emit(SuggestionsLoaded(suggestions));
      } catch (e) {
        // Silently fail for suggestions
      }
    });
  }

  void _onClearSuggestions(
    ClearSuggestions event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(const SuggestionsCleared());
  }

  Future<void> _onLoadRecentSearches(
    LoadRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final recentSearches = await _repository.getRecentSearches(limit: event.limit);
      emit(RecentSearchesLoaded(recentSearches));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSaveRecentSearch(
    SaveRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.saveRecentSearch(event.query, resultCount: event.resultCount);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onDeleteRecentSearch(
    DeleteRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.deleteRecentSearch(event.query);
      // Reload recent searches
      final recentSearches = await _repository.getRecentSearches();
      emit(RecentSearchesLoaded(recentSearches));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onClearRecentSearches(
    ClearRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.clearRecentSearches();
      emit(const RecentSearchesLoaded([]));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onLoadPopularSearches(
    LoadPopularSearches event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final popularSearches = await _repository.getPopularSearches(limit: event.limit);
      emit(PopularSearchesLoaded(popularSearches));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onUpdateFilters(
    UpdateFilters event,
    Emitter<SearchState> emit,
  ) {
    final currentState = state;
    if (currentState is SearchResultsLoaded) {
      // Re-search with new filters
      add(PerformSearch(
        query: currentState.results.query,
        filters: event.filters,
      ));
    }
  }

  void _onClearFilters(
    ClearFilters event,
    Emitter<SearchState> emit,
  ) {
    final currentState = state;
    if (currentState is SearchResultsLoaded) {
      add(PerformSearch(
        query: currentState.results.query,
        filters: const SearchFilters(),
      ));
    }
  }

  Future<void> _onFollowUser(
    FollowUserFromSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.followUser(event.userId);
      emit(UserFollowStatusChanged(event.userId, isFollowing: true));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUserFromSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.unfollowUser(event.userId);
      emit(UserFollowStatusChanged(event.userId, isFollowing: false));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onFollowCompany(
    FollowCompanyFromSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.followCompany(event.companyId);
      emit(CompanyFollowStatusChanged(event.companyId, isFollowing: true));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onUnfollowCompany(
    UnfollowCompanyFromSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.unfollowCompany(event.companyId);
      emit(CompanyFollowStatusChanged(event.companyId, isFollowing: false));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onLoadMoreResults(
    LoadMoreResults event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchResultsLoaded || !currentState.hasMore) return;

    emit(SearchLoadingMore(currentResults: currentState.results));

    try {
      final moreResults = await _repository.search(
        currentState.results.query,
        filters: currentState.filters,
        limit: 20,
        offset: currentState.offset,
      );

      final combinedResults = SearchResults(
        query: currentState.results.query,
        jobs: [...currentState.results.jobs, ...moreResults.jobs],
        courses: [...currentState.results.courses, ...moreResults.courses],
        users: [...currentState.results.users, ...moreResults.users],
        companies: [...currentState.results.companies, ...moreResults.companies],
        totalCount: currentState.results.totalCount,
      );

      emit(SearchResultsLoaded(
        results: combinedResults,
        filters: currentState.filters,
        hasMore: moreResults.totalCount >= 20,
        offset: currentState.offset + 20,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }
}
