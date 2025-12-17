import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getFeed({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<PostEntity>>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<PostEntity>>> getCompanyPosts({
    required String companyId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, PostEntity>> getPostById(String postId);

  Future<Either<Failure, PostEntity>> createPost({
    required String content,
    List<String>? mediaUrls,
    String? companyId,
  });

  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
  });

  Future<Either<Failure, void>> deletePost(String postId);

  Future<Either<Failure, PostEntity>> toggleLike(String postId);

  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, CommentEntity>> addComment({
    required String postId,
    required String content,
    String? parentId,
  });

  Future<Either<Failure, CommentEntity>> updateComment({
    required String commentId,
    required String content,
  });

  Future<Either<Failure, void>> deleteComment(String commentId);

  Future<Either<Failure, CommentEntity>> toggleCommentLike(String commentId);

  Future<Either<Failure, void>> sharePost(String postId);

  Future<Either<Failure, List<PostEntity>>> searchPosts({
    required String query,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<PostEntity>>> getPostsByHashtag({
    required String hashtag,
    int page = 1,
    int limit = 20,
  });
}
