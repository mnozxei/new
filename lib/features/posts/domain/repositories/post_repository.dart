import '../entities/post_entity.dart';

abstract class PostRepository {
  /// Get feed posts
  Future<List<PostEntity>> getFeed({
    int limit = 20,
    int offset = 0,
  });

  /// Get posts by user
  Future<List<PostEntity>> getUserPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  /// Get posts by company
  Future<List<PostEntity>> getCompanyPosts({
    required String companyId,
    int limit = 20,
    int offset = 0,
  });

  /// Get post by ID
  Future<PostEntity?> getPostById(String postId);

  /// Create a post
  Future<PostEntity> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    String? companyId,
    String visibility = 'public',
  });

  /// Update a post
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
  Future<List<CommentEntity>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  });

  /// Add a comment
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
    String? parentId,
  });

  /// Update a comment
  Future<CommentEntity> updateComment({
    required String commentId,
    required String content,
  });

  /// Delete a comment
  Future<void> deleteComment(String commentId);

  /// Toggle like on a comment
  Future<CommentEntity> toggleCommentLike(String commentId);

  /// Share a post
  Future<void> sharePost(String postId);

  /// Search posts
  Future<List<PostEntity>> searchPosts({
    required String query,
    int limit = 20,
    int offset = 0,
  });

  /// Get posts by hashtag
  Future<List<PostEntity>> getPostsByHashtag({
    required String hashtag,
    int limit = 20,
    int offset = 0,
  });
}
