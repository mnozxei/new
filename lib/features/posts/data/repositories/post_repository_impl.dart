import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required PostRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final PostRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<PostEntity>>> getFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.getFeed(page: page, limit: limit);
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.getUserPosts(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getCompanyPosts({
    required String companyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.getCompanyPosts(
        companyId: companyId,
        page: page,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final post = await _remoteDataSource.getPostById(postId);
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String content,
    List<String>? mediaUrls,
    String? companyId,
  }) async {
    try {
      final post = await _remoteDataSource.createPost(
        content: content,
        mediaUrls: mediaUrls,
        companyId: companyId,
      );
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
  }) async {
    try {
      final post = await _remoteDataSource.updatePost(
        postId: postId,
        content: content,
        mediaUrls: mediaUrls,
      );
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await _remoteDataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> toggleLike(String postId) async {
    try {
      final post = await _remoteDataSource.toggleLike(postId);
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final comments = await _remoteDataSource.getComments(
        postId: postId,
        page: page,
        limit: limit,
      );
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final comment = await _remoteDataSource.addComment(
        postId: postId,
        content: content,
        parentId: parentId,
      );
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final comment = await _remoteDataSource.updateComment(
        commentId: commentId,
        content: content,
      );
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await _remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> toggleCommentLike(String commentId) async {
    try {
      final comment = await _remoteDataSource.toggleCommentLike(commentId);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sharePost(String postId) async {
    try {
      await _remoteDataSource.sharePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> searchPosts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.searchPosts(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPostsByHashtag({
    required String hashtag,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.getPostsByHashtag(
        hashtag: hashtag,
        page: page,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
