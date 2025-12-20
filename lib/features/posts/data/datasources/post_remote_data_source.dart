import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/policies/post_content_policy.dart';

abstract class PostRemoteDataSource {
  /// Get personalized feed using the enterprise algorithm
  Future<List<PostEntity>> getFeed({int limit = 20, DateTime? cursor});

  /// Get posts by a specific user
  Future<List<PostEntity>> getUserPosts({required String userId, int limit = 20, int offset = 0});

  /// Get posts by a specific company
  Future<List<PostEntity>> getCompanyPosts({required String companyId, int limit = 20, int offset = 0});

  /// Get a single post by ID
  Future<PostEntity?> getPostById(String postId);

  /// Create a new post (validates no-links policy)
  Future<PostEntity> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    String? companyId,
    String visibility = 'public',
  });

  /// Update an existing post (validates no-links policy)
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
  });

  /// Delete a post
  Future<void> deletePost(String postId);

  /// Toggle like on a post
  Future<PostEntity> toggleLike(String postId);

  /// Get comments for a post
  Future<List<CommentEntity>> getComments({required String postId, int limit = 20, int offset = 0});

  /// Add a comment to a post
  Future<CommentEntity> addComment({required String postId, required String content, String? parentId});

  /// Update a comment
  Future<CommentEntity> updateComment({required String commentId, required String content});

  /// Delete a comment
  Future<void> deleteComment(String commentId);

  /// Toggle like on a comment
  Future<CommentEntity> toggleCommentLike(String commentId);

  /// Share a post (increment share count)
  Future<void> sharePost(String postId);

  /// Search posts by query
  Future<List<PostEntity>> searchPosts({required String query, int limit = 20, int offset = 0});

  /// Get posts by hashtag
  Future<List<PostEntity>> getPostsByHashtag({required String hashtag, int limit = 20, int offset = 0});

  /// Toggle bookmark on a post
  Future<bool> toggleBookmark(String postId);

  /// Get saved/bookmarked posts
  Future<List<PostEntity>> getSavedPosts({int limit = 20, int offset = 0});

  /// Report a post
  Future<void> reportPost({required String postId, required String reason, String? details});

  /// Record post impression
  Future<void> recordImpression(String postId, {String interactionType = 'view'});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<PostEntity>> getFeed({int limit = 20, DateTime? cursor}) async {
    try {
      // Use the personalized feed RPC
      final response = await _supabase.rpc(
        'get_personalized_feed',
        params: {
          'p_user_id': _currentUserId,
          'p_limit': limit,
          'p_cursor': cursor?.toIso8601String(),
          'p_debug': false,
        },
      );

      return (response as List).map((json) => _mapFeedPostFromJson(json)).toList();
    } catch (e) {
      // Fallback to simple query if RPC fails
      return _getFeedFallback(limit: limit, cursor: cursor);
    }
  }

  Future<List<PostEntity>> _getFeedFallback({int limit = 20, DateTime? cursor}) async {
    var query = _supabase
        .from('posts')
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .eq('visibility', 'public');

    if (cursor != null) {
      query = query.lt('created_at', cursor.toIso8601String());
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => _mapPostFromJson(json)).toList();
  }

  @override
  Future<List<PostEntity>> getUserPosts({required String userId, int limit = 20, int offset = 0}) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .eq('author_id', userId)
        .isFilter('company_id', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapPostFromJson(json)).toList();
  }

  @override
  Future<List<PostEntity>> getCompanyPosts({required String companyId, int limit = 20, int offset = 0}) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .eq('company_id', companyId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapPostFromJson(json)).toList();
  }

  @override
  Future<PostEntity?> getPostById(String postId) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .eq('id', postId)
        .maybeSingle();

    if (response == null) return null;

    // Record impression when viewing post details
    if (_currentUserId != null) {
      recordImpression(postId, interactionType: 'click');
    }

    return _mapPostFromJson(response);
  }

  @override
  Future<PostEntity> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    String? companyId,
    String visibility = 'public',
  }) async {
    // Validate no-links policy
    final validationError = PostContentPolicy.validate(content);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final hashtags = _extractHashtags(content);

    final response = await _supabase
        .from('posts')
        .insert({
          'author_id': _currentUserId,
          'company_id': companyId,
          'content': content,
          'media_urls': mediaUrls ?? [],
          if (mediaTypes != null) 'media_types': mediaTypes,
          'hashtags': hashtags,
          'visibility': visibility,
        })
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .single();

    return _mapPostFromJson(response);
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
  }) async {
    // Validate no-links policy
    final validationError = PostContentPolicy.validate(content);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final hashtags = _extractHashtags(content);

    final updateData = <String, dynamic>{
      'content': content,
      'hashtags': hashtags,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (mediaUrls != null) {
      updateData['media_urls'] = mediaUrls;
    }
    if (mediaTypes != null) {
      updateData['media_types'] = mediaTypes;
    }

    final response = await _supabase
        .from('posts')
        .update(updateData)
        .eq('id', postId)
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .single();

    return _mapPostFromJson(response);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _supabase.from('posts').delete().eq('id', postId);
  }

  @override
  Future<PostEntity> toggleLike(String postId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    final existingLike = await _supabase
        .from('post_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingLike != null) {
      await _supabase
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } else {
      await _supabase.from('post_likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
    }

    final post = await getPostById(postId);
    if (post == null) {
      throw Exception('المنشور غير موجود');
    }
    return post;
  }

  @override
  Future<List<CommentEntity>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('post_comments')
        .select('''
          *,
          author:profiles!user_id(*),
          likes:comment_likes(user_id)
        ''')
        .eq('post_id', postId)
        .isFilter('parent_id', null)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapCommentFromJson(json)).toList();
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    final response = await _supabase
        .from('post_comments')
        .insert({
          'post_id': postId,
          'user_id': userId,
          'content': content,
          'parent_id': parentId,
        })
        .select('''
          *,
          author:profiles!user_id(*),
          likes:comment_likes(user_id)
        ''')
        .single();

    return _mapCommentFromJson(response);
  }

  @override
  Future<CommentEntity> updateComment({
    required String commentId,
    required String content,
  }) async {
    final response = await _supabase
        .from('post_comments')
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', commentId)
        .select('''
          *,
          author:profiles!user_id(*),
          likes:comment_likes(user_id)
        ''')
        .single();

    return _mapCommentFromJson(response);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _supabase.from('post_comments').delete().eq('id', commentId);
  }

  @override
  Future<CommentEntity> toggleCommentLike(String commentId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    final existingLike = await _supabase
        .from('comment_likes')
        .select()
        .eq('comment_id', commentId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingLike != null) {
      await _supabase
          .from('comment_likes')
          .delete()
          .eq('comment_id', commentId)
          .eq('user_id', userId);
    } else {
      await _supabase.from('comment_likes').insert({
        'comment_id': commentId,
        'user_id': userId,
      });
    }

    final response = await _supabase
        .from('post_comments')
        .select('''
          *,
          author:profiles!user_id(*),
          likes:comment_likes(user_id)
        ''')
        .eq('id', commentId)
        .single();

    return _mapCommentFromJson(response);
  }

  @override
  Future<void> sharePost(String postId) async {
    await _supabase.rpc('increment_post_shares', params: {'p_post_id': postId});
  }

  @override
  Future<List<PostEntity>> searchPosts({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .eq('visibility', 'public')
        .ilike('content', '%$query%')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapPostFromJson(json)).toList();
  }

  @override
  Future<List<PostEntity>> getPostsByHashtag({
    required String hashtag,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .eq('visibility', 'public')
        .contains('hashtags', [hashtag])
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapPostFromJson(json)).toList();
  }

  @override
  Future<bool> toggleBookmark(String postId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    final result = await _supabase.rpc(
      'toggle_post_bookmark',
      params: {'p_user_id': userId, 'p_post_id': postId},
    );

    return result as bool;
  }

  @override
  Future<List<PostEntity>> getSavedPosts({int limit = 20, int offset = 0}) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    final response = await _supabase.rpc(
      'get_saved_posts',
      params: {'p_user_id': userId, 'p_limit': limit, 'p_offset': offset},
    );

    return (response as List).map((json) => _mapSavedPostFromJson(json)).toList();
  }

  @override
  Future<void> reportPost({required String postId, required String reason, String? details}) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    await _supabase.rpc(
      'report_post',
      params: {
        'p_post_id': postId,
        'p_reporter_id': userId,
        'p_reason': reason,
        'p_details': details,
      },
    );
  }

  @override
  Future<void> recordImpression(String postId, {String interactionType = 'view'}) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _supabase.rpc(
        'record_post_impression',
        params: {
          'p_user_id': userId,
          'p_post_id': postId,
          'p_interaction_type': interactionType,
        },
      );
    } catch (_) {
      // Silently fail for impressions
    }
  }

  List<String> _extractHashtags(String content) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(content).map((m) => m.group(1)!).toList();
  }

  PostEntity _mapFeedPostFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    PostAuthorInfo? author;
    if (json['author_id'] != null) {
      author = PostAuthorInfo(
        id: json['author_id'] as String? ?? '',
        fullName: json['author_name'] as String? ?? '',
        avatarUrl: json['author_avatar'] as String?,
        headline: null,
        isVerified: json['author_verified'] as bool? ?? false,
      );
    }

    PostCompanyInfo? company;
    if (json['company_id'] != null) {
      company = PostCompanyInfo(
        id: json['company_id'] as String? ?? '',
        name: json['company_name'] as String? ?? '',
        logoUrl: json['company_logo'] as String?,
        isVerified: json['company_verified'] as bool? ?? false,
      );
    }

    return PostEntity(
      id: json['post_id'] as String,
      authorId: json['author_id'] as String?,
      companyId: json['company_id'] as String?,
      content: json['content'] as String,
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      mediaTypes: List<String>.from(json['media_types'] ?? []),
      visibility: 'public',
      isPinned: false,
      likeCount: json['likes_count'] as int? ?? 0,
      commentCount: json['comments_count'] as int? ?? 0,
      shareCount: json['shares_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      author: author,
      company: company,
      feedSource: json['feed_source'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: now,
    );
  }

  PostEntity _mapPostFromJson(Map<String, dynamic> json) {
    final likes = json['likes'] as List? ?? [];
    final likedByCurrentUser = _currentUserId != null && likes.any((l) => l['user_id'] == _currentUserId);
    final commentsData = json['comments'] as List? ?? [];
    final commentsCount = commentsData.isNotEmpty ? (commentsData[0]['count'] ?? 0) as int : 0;
    final now = DateTime.now();

    PostAuthorInfo? author;
    if (json['author'] != null) {
      final a = json['author'] as Map<String, dynamic>;
      author = PostAuthorInfo(
        id: a['id'] as String? ?? '',
        fullName: a['full_name'] as String? ?? '',
        avatarUrl: a['avatar_url'] as String?,
        headline: a['headline'] as String?,
        isVerified: a['is_verified'] as bool? ?? false,
      );
    }

    PostCompanyInfo? company;
    if (json['company'] != null) {
      final c = json['company'] as Map<String, dynamic>;
      company = PostCompanyInfo(
        id: c['id'] as String? ?? '',
        name: c['name'] as String? ?? '',
        logoUrl: c['logo_url'] as String?,
        isVerified: c['status'] == 'verified',
      );
    }

    return PostEntity(
      id: json['id'] as String,
      authorId: json['author_id'] as String?,
      companyId: json['company_id'] as String?,
      content: json['content'] as String,
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      mediaTypes: List<String>.from(json['media_types'] ?? []),
      visibility: json['visibility'] as String? ?? 'public',
      isPinned: json['is_pinned'] as bool? ?? false,
      likeCount: json['like_count'] as int? ?? likes.length,
      commentCount: json['comment_count'] as int? ?? commentsCount,
      shareCount: json['share_count'] as int? ?? 0,
      isLiked: likedByCurrentUser,
      author: author,
      company: company,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
    );
  }

  PostEntity _mapSavedPostFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    PostAuthorInfo? author;
    if (json['author_id'] != null) {
      author = PostAuthorInfo(
        id: json['author_id'] as String? ?? '',
        fullName: json['author_name'] as String? ?? '',
        avatarUrl: json['author_avatar'] as String?,
        headline: null,
        isVerified: false,
      );
    }

    PostCompanyInfo? company;
    if (json['company_id'] != null) {
      company = PostCompanyInfo(
        id: json['company_id'] as String? ?? '',
        name: json['company_name'] as String? ?? '',
        logoUrl: json['company_logo'] as String?,
        isVerified: false,
      );
    }

    return PostEntity(
      id: json['post_id'] as String,
      authorId: json['author_id'] as String?,
      companyId: json['company_id'] as String?,
      content: json['content'] as String,
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      mediaTypes: const [],
      visibility: 'public',
      isPinned: false,
      likeCount: json['likes_count'] as int? ?? 0,
      commentCount: json['comments_count'] as int? ?? 0,
      shareCount: 0,
      isLiked: false,
      isSaved: true,
      author: author,
      company: company,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: now,
    );
  }

  CommentEntity _mapCommentFromJson(Map<String, dynamic> json) {
    final likes = json['likes'] as List? ?? [];
    final likedByCurrentUser = _currentUserId != null && likes.any((l) => l['user_id'] == _currentUserId);
    final now = DateTime.now();

    CommentUserInfo? user;
    if (json['author'] != null) {
      final a = json['author'] as Map<String, dynamic>;
      user = CommentUserInfo(
        id: a['id'] as String? ?? '',
        fullName: a['full_name'] as String? ?? '',
        avatarUrl: a['avatar_url'] as String?,
      );
    }

    return CommentEntity(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String,
      likeCount: likes.length,
      isLiked: likedByCurrentUser,
      user: user,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
    );
  }
}
