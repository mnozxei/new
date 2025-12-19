import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/search_entity.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResults> search(
    String query, {
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  });

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

  Future<List<UserSearchResult>> searchUsers(
    String query, {
    String? role,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  });

  Future<List<CompanySearchResult>> searchCompanies(
    String query, {
    String? industry,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  });

  Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  });

  Future<List<RecentSearch>> getRecentSearches({int limit = 10});
  Future<void> saveRecentSearch(String query, {int? resultCount});
  Future<void> clearRecentSearches();
  Future<void> deleteRecentSearch(String query);
  Future<List<PopularSearch>> getPopularSearches({int limit = 10});

  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> followCompany(String companyId);
  Future<void> unfollowCompany(String companyId);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  final SupabaseClient _client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<SearchResults> search(
    String query, {
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    // Perform parallel searches based on filter type
    final searchType = filters?.type ?? SearchResultType.all;

    List<JobSearchResult> jobs = [];
    List<CourseSearchResult> courses = [];
    List<UserSearchResult> users = [];
    List<CompanySearchResult> companies = [];

    if (searchType == SearchResultType.all || searchType == SearchResultType.job) {
      jobs = await searchJobs(
        query,
        location: filters?.location,
        employmentType: filters?.employmentType,
        minSalary: filters?.minSalary,
        maxSalary: filters?.maxSalary,
        isRemote: filters?.isRemote,
        verifiedOnly: filters?.isVerifiedOnly,
        limit: searchType == SearchResultType.all ? 5 : limit,
        offset: searchType == SearchResultType.all ? 0 : offset,
      );
    }

    if (searchType == SearchResultType.all || searchType == SearchResultType.course) {
      courses = await searchCourses(
        query,
        category: filters?.category,
        level: filters?.courseLevel,
        minRating: filters?.minRating,
        maxPrice: filters?.maxPrice,
        verifiedOnly: filters?.isVerifiedOnly,
        limit: searchType == SearchResultType.all ? 5 : limit,
        offset: searchType == SearchResultType.all ? 0 : offset,
      );
    }

    if (searchType == SearchResultType.all || searchType == SearchResultType.user) {
      users = await searchUsers(
        query,
        location: filters?.location,
        verifiedOnly: filters?.isVerifiedOnly,
        limit: searchType == SearchResultType.all ? 5 : limit,
        offset: searchType == SearchResultType.all ? 0 : offset,
      );
    }

    if (searchType == SearchResultType.all || searchType == SearchResultType.company) {
      companies = await searchCompanies(
        query,
        location: filters?.location,
        verifiedOnly: filters?.isVerifiedOnly,
        limit: searchType == SearchResultType.all ? 5 : limit,
        offset: searchType == SearchResultType.all ? 0 : offset,
      );
    }

    final totalCount = jobs.length + courses.length + users.length + companies.length;

    return SearchResults(
      query: query,
      jobs: jobs,
      courses: courses,
      users: users,
      companies: companies,
      totalCount: totalCount,
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
  }) async {
    var queryBuilder = _client
        .from('jobs')
        .select('''
          *,
          company:companies(id, name, logo_url, is_verified)
        ''')
        .eq('status', 'active')
        .or('title.ilike.%$query%,description.ilike.%$query%');

    if (location != null) {
      queryBuilder = queryBuilder.ilike('location', '%$location%');
    }
    if (employmentType != null) {
      queryBuilder = queryBuilder.eq('employment_type', employmentType);
    }
    if (minSalary != null) {
      queryBuilder = queryBuilder.gte('salary_min', minSalary);
    }
    if (maxSalary != null) {
      queryBuilder = queryBuilder.lte('salary_max', maxSalary);
    }
    if (isRemote == true) {
      queryBuilder = queryBuilder.eq('is_remote', true);
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    var results = (response as List)
        .map((json) => JobSearchResult.fromJson(json as Map<String, dynamic>))
        .toList();

    // Filter verified only after fetching (since it's on the company relation)
    if (verifiedOnly == true) {
      results = results.where((job) => job.isCompanyVerified).toList();
    }

    return results;
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
  }) async {
    var queryBuilder = _client
        .from('courses')
        .select('''
          *,
          instructor:profiles!instructor_id(id, display_name, avatar_url, is_verified)
        ''')
        .eq('status', 'published')
        .or('title.ilike.%$query%,description.ilike.%$query%');

    if (category != null) {
      queryBuilder = queryBuilder.eq('category', category);
    }
    if (level != null) {
      queryBuilder = queryBuilder.eq('level', level);
    }
    if (minRating != null) {
      queryBuilder = queryBuilder.gte('rating', minRating);
    }
    if (maxPrice != null) {
      queryBuilder = queryBuilder.lte('price', maxPrice);
    }

    final response = await queryBuilder
        .order('enrollment_count', ascending: false)
        .range(offset, offset + limit - 1);

    var results = (response as List)
        .map((json) => CourseSearchResult.fromJson(json as Map<String, dynamic>))
        .toList();

    // Filter verified only after fetching
    if (verifiedOnly == true) {
      results = results.where((course) => course.isInstructorVerified).toList();
    }

    return results;
  }

  @override
  Future<List<UserSearchResult>> searchUsers(
    String query, {
    String? role,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  }) async {
    var queryBuilder = _client
        .from('profiles')
        .select()
        .or('display_name.ilike.%$query%,headline.ilike.%$query%');

    if (role != null) {
      queryBuilder = queryBuilder.eq('role', role);
    }
    if (location != null) {
      queryBuilder = queryBuilder.ilike('location', '%$location%');
    }
    if (verifiedOnly == true) {
      queryBuilder = queryBuilder.eq('is_verified', true);
    }

    final response = await queryBuilder
        .order('follower_count', ascending: false)
        .range(offset, offset + limit - 1);

    // Get following status for current user
    Set<String> followingIds = {};
    if (_currentUserId != null) {
      final userIds = (response as List).map((u) => u['id'] as String).toList();
      if (userIds.isNotEmpty) {
        final followingResponse = await _client
            .from('user_follows')
            .select('following_id')
            .eq('follower_id', _currentUserId!)
            .inFilter('following_id', userIds);

        followingIds = (followingResponse as List)
            .map((f) => f['following_id'] as String)
            .toSet();
      }
    }

    return (response as List)
        .map((json) => UserSearchResult.fromJson(
              json as Map<String, dynamic>,
              isFollowing: followingIds.contains(json['id']),
            ))
        .toList();
  }

  @override
  Future<List<CompanySearchResult>> searchCompanies(
    String query, {
    String? industry,
    String? location,
    bool? verifiedOnly,
    int limit = 20,
    int offset = 0,
  }) async {
    var queryBuilder = _client
        .from('companies')
        .select()
        .or('name.ilike.%$query%,description.ilike.%$query%');

    if (industry != null) {
      queryBuilder = queryBuilder.eq('industry', industry);
    }
    if (location != null) {
      queryBuilder = queryBuilder.ilike('location', '%$location%');
    }
    if (verifiedOnly == true) {
      queryBuilder = queryBuilder.eq('is_verified', true);
    }

    final response = await queryBuilder
        .order('follower_count', ascending: false)
        .range(offset, offset + limit - 1);

    // Get following status and open jobs count
    Set<String> followingIds = {};
    if (_currentUserId != null) {
      final companyIds = (response as List).map((c) => c['id'] as String).toList();
      if (companyIds.isNotEmpty) {
        final followingResponse = await _client
            .from('company_follows')
            .select('company_id')
            .eq('user_id', _currentUserId!)
            .inFilter('company_id', companyIds);

        followingIds = (followingResponse as List)
            .map((f) => f['company_id'] as String)
            .toSet();
      }
    }

    return (response as List)
        .map((json) => CompanySearchResult.fromJson(
              json as Map<String, dynamic>,
              isFollowing: followingIds.contains(json['id']),
            ))
        .toList();
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) return [];

    final suggestions = <SearchSuggestion>[];

    // Get job title suggestions
    final jobsResponse = await _client
        .from('jobs')
        .select('id, title')
        .eq('status', 'active')
        .ilike('title', '%$query%')
        .limit(3);

    suggestions.addAll(
      (jobsResponse as List).map((j) => SearchSuggestion(
            text: j['title'] as String,
            type: SearchResultType.job,
            entityId: j['id'] as String,
          )),
    );

    // Get course suggestions
    final coursesResponse = await _client
        .from('courses')
        .select('id, title')
        .eq('status', 'published')
        .ilike('title', '%$query%')
        .limit(3);

    suggestions.addAll(
      (coursesResponse as List).map((c) => SearchSuggestion(
            text: c['title'] as String,
            type: SearchResultType.course,
            entityId: c['id'] as String,
          )),
    );

    // Get user suggestions
    final usersResponse = await _client
        .from('profiles')
        .select('id, display_name')
        .ilike('display_name', '%$query%')
        .limit(2);

    suggestions.addAll(
      (usersResponse as List).map((u) => SearchSuggestion(
            text: u['display_name'] as String,
            type: SearchResultType.user,
            entityId: u['id'] as String,
          )),
    );

    // Get company suggestions
    final companiesResponse = await _client
        .from('companies')
        .select('id, name')
        .ilike('name', '%$query%')
        .limit(2);

    suggestions.addAll(
      (companiesResponse as List).map((c) => SearchSuggestion(
            text: c['name'] as String,
            type: SearchResultType.company,
            entityId: c['id'] as String,
          )),
    );

    return suggestions.take(limit).toList();
  }

  @override
  Future<List<RecentSearch>> getRecentSearches({int limit = 10}) async {
    if (_currentUserId == null) return [];

    final response = await _client
        .from('recent_searches')
        .select()
        .eq('user_id', _currentUserId!)
        .order('searched_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => RecentSearch.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRecentSearch(String query, {int? resultCount}) async {
    if (_currentUserId == null) return;

    // Upsert to update timestamp if query exists
    await _client.from('recent_searches').upsert({
      'user_id': _currentUserId,
      'query': query,
      'searched_at': DateTime.now().toIso8601String(),
      'result_count': resultCount,
    }, onConflict: 'user_id, query');

    // Keep only last 20 searches
    final allSearches = await _client
        .from('recent_searches')
        .select('id')
        .eq('user_id', _currentUserId!)
        .order('searched_at', ascending: false);

    if ((allSearches as List).length > 20) {
      final toDelete = allSearches.skip(20).map((s) => s['id'] as String).toList();
      await _client.from('recent_searches').delete().inFilter('id', toDelete);
    }
  }

  @override
  Future<void> clearRecentSearches() async {
    if (_currentUserId == null) return;

    await _client.from('recent_searches').delete().eq('user_id', _currentUserId!);
  }

  @override
  Future<void> deleteRecentSearch(String query) async {
    if (_currentUserId == null) return;

    await _client
        .from('recent_searches')
        .delete()
        .eq('user_id', _currentUserId!)
        .eq('query', query);
  }

  @override
  Future<List<PopularSearch>> getPopularSearches({int limit = 10}) async {
    final response = await _client
        .from('popular_searches')
        .select()
        .order('search_count', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => PopularSearch.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> followUser(String userId) async {
    if (_currentUserId == null) return;

    await _client.from('user_follows').insert({
      'follower_id': _currentUserId,
      'following_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Increment follower count
    await _client.rpc('increment_follower_count', params: {'user_id': userId});
  }

  @override
  Future<void> unfollowUser(String userId) async {
    if (_currentUserId == null) return;

    await _client
        .from('user_follows')
        .delete()
        .eq('follower_id', _currentUserId!)
        .eq('following_id', userId);

    // Decrement follower count
    await _client.rpc('decrement_follower_count', params: {'user_id': userId});
  }

  @override
  Future<void> followCompany(String companyId) async {
    if (_currentUserId == null) return;

    await _client.from('company_follows').insert({
      'user_id': _currentUserId,
      'company_id': companyId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Increment follower count
    await _client.rpc('increment_company_follower_count', params: {'company_id': companyId});
  }

  @override
  Future<void> unfollowCompany(String companyId) async {
    if (_currentUserId == null) return;

    await _client
        .from('company_follows')
        .delete()
        .eq('user_id', _currentUserId!)
        .eq('company_id', companyId);

    // Decrement follower count
    await _client.rpc('decrement_company_follower_count', params: {'company_id': companyId});
  }
}
