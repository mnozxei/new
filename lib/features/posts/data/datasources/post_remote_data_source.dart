import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/post_entity.dart';

abstract class PostRemoteDataSource {
  Future<List<PostEntity>> getFeed({int limit = 20, int offset = 0});
  Future<List<PostEntity>> getUserPosts({required String userId, int limit = 20, int offset = 0});
  Future<List<PostEntity>> getCompanyPosts({required String companyId, int limit = 20, int offset = 0});
  Future<PostEntity?> getPostById(String postId);
  Future<PostEntity> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    String? companyId,
    String visibility = 'public',
  });
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
  });
  Future<void> deletePost(String postId);
  Future<PostEntity> toggleLike(String postId);
  Future<List<CommentEntity>> getComments({required String postId, int limit = 20, int offset = 0});
  Future<CommentEntity> addComment({required String postId, required String content, String? parentId});
  Future<CommentEntity> updateComment({required String commentId, required String content});
  Future<void> deleteComment(String commentId);
  Future<CommentEntity> toggleCommentLike(String commentId);
  Future<void> sharePost(String postId);
  Future<List<PostEntity>> searchPosts({required String query, int limit = 20, int offset = 0});
  Future<List<PostEntity>> getPostsByHashtag({required String hashtag, int limit = 20, int offset = 0});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<PostEntity>> getFeed({int limit = 20, int offset = 0}) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          author:profiles!author_id(*),
          company:companies!company_id(*),
          likes:post_likes(user_id),
          comments:post_comments(count)
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

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
    final existingLike = await _supabase
        .from('post_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (existingLike != null) {
      await _supabase
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', _currentUserId);
    } else {
      await _supabase.from('post_likes').insert({
        'post_id': postId,
        'user_id': _currentUserId,
      });
    }

    final post = await getPostById(postId);
    if (post == null) {
      throw Exception('Post not found');
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
    final response = await _supabase
        .from('post_comments')
        .insert({
          'post_id': postId,
          'user_id': _currentUserId,
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
    final existingLike = await _supabase
        .from('comment_likes')
        .select()
        .eq('comment_id', commentId)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (existingLike != null) {
      await _supabase
          .from('comment_likes')
          .delete()
          .eq('comment_id', commentId)
          .eq('user_id', _currentUserId);
    } else {
      await _supabase.from('comment_likes').insert({
        'comment_id': commentId,
        'user_id': _currentUserId,
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
        .contains('hashtags', [hashtag])
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapPostFromJson(json)).toList();
  }

  List<String> _extractHashtags(String content) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(content).map((m) => m.group(1)!).toList();
  }

  PostEntity _mapPostFromJson(Map<String, dynamic> json) {
    final likes = json['likes'] as List? ?? [];
    final likedByCurrentUser = likes.any((l) => l['user_id'] == _currentUserId);
    final commentsData = json['comments'] as List? ?? [];
    final commentsCount = commentsData.isNotEmpty ? (commentsData[0]['count'] ?? 0) as int : 0;

    return PostEntity(
      id: json['id'] as String,
      authorId: json['author_id'] as String?,
      companyId: json['company_id'] as String?,
      content: json['content'] as String,
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      mediaTypes: json['media_types'] != null ? List<String>.from(json['media_types']) : null,
      visibility: json['visibility'] as String? ?? 'public',
      likeCount: likes.length,
      commentCount: commentsCount,
      shareCount: json['share_count'] as int? ?? 0,
      isLiked: likedByCurrentUser,
      authorName: json['author']?['full_name'] as String?,
      authorAvatar: json['author']?['avatar_url'] as String?,
      companyName: json['company']?['name'] as String?,
      companyLogo: json['company']?['logo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  CommentEntity _mapCommentFromJson(Map<String, dynamic> json) {
    final likes = json['likes'] as List? ?? [];
    final likedByCurrentUser = likes.any((l) => l['user_id'] == _currentUserId);

    return CommentEntity(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String,
      likeCount: likes.length,
      isLiked: likedByCurrentUser,
      authorName: json['author']?['full_name'] as String?,
      authorAvatar: json['author']?['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
