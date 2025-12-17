import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required PostRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final PostRemoteDataSource _remoteDataSource;

  @override
  Future<List<PostEntity>> getFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getFeed(limit: limit, offset: offset);
  }

  @override
  Future<List<PostEntity>> getUserPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getUserPosts(
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<PostEntity>> getCompanyPosts({
    required String companyId,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getCompanyPosts(
      companyId: companyId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<PostEntity?> getPostById(String postId) async {
    return _remoteDataSource.getPostById(postId);
  }

  @override
  Future<PostEntity> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    String? companyId,
    String visibility = 'public',
  }) async {
    return _remoteDataSource.createPost(
      content: content,
      mediaUrls: mediaUrls,
      mediaTypes: mediaTypes,
      companyId: companyId,
      visibility: visibility,
    );
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
  }) async {
    return _remoteDataSource.updatePost(
      postId: postId,
      content: content,
      mediaUrls: mediaUrls,
      mediaTypes: mediaTypes,
    );
  }

  @override
  Future<void> deletePost(String postId) async {
    await _remoteDataSource.deletePost(postId);
  }

  @override
  Future<PostEntity> toggleLike(String postId) async {
    return _remoteDataSource.toggleLike(postId);
  }

  @override
  Future<List<CommentEntity>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getComments(
      postId: postId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    return _remoteDataSource.addComment(
      postId: postId,
      content: content,
      parentId: parentId,
    );
  }

  @override
  Future<CommentEntity> updateComment({
    required String commentId,
    required String content,
  }) async {
    return _remoteDataSource.updateComment(
      commentId: commentId,
      content: content,
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _remoteDataSource.deleteComment(commentId);
  }

  @override
  Future<CommentEntity> toggleCommentLike(String commentId) async {
    return _remoteDataSource.toggleCommentLike(commentId);
  }

  @override
  Future<void> sharePost(String postId) async {
    await _remoteDataSource.sharePost(postId);
  }

  @override
  Future<List<PostEntity>> searchPosts({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.searchPosts(
      query: query,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<PostEntity>> getPostsByHashtag({
    required String hashtag,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getPostsByHashtag(
      hashtag: hashtag,
      limit: limit,
      offset: offset,
    );
  }
}
