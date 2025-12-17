part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeed extends PostEvent {
  const LoadFeed();
}

class LoadMoreFeed extends PostEvent {
  const LoadMoreFeed();
}

class LoadUserPosts extends PostEvent {
  const LoadUserPosts({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class LoadCompanyPosts extends PostEvent {
  const LoadCompanyPosts({required this.companyId});

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

class LoadPostDetails extends PostEvent {
  const LoadPostDetails({required this.postId});

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class CreatePost extends PostEvent {
  const CreatePost({
    required this.content,
    this.mediaUrls,
    this.companyId,
  });

  final String content;
  final List<String>? mediaUrls;
  final String? companyId;

  @override
  List<Object?> get props => [content, mediaUrls, companyId];
}

class UpdatePost extends PostEvent {
  const UpdatePost({
    required this.postId,
    required this.content,
    this.mediaUrls,
  });

  final String postId;
  final String content;
  final List<String>? mediaUrls;

  @override
  List<Object?> get props => [postId, content, mediaUrls];
}

class DeletePost extends PostEvent {
  const DeletePost({required this.postId});

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class TogglePostLike extends PostEvent {
  const TogglePostLike({required this.postId});

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class LoadComments extends PostEvent {
  const LoadComments({
    required this.postId,
    this.offset = 0,
  });

  final String postId;
  final int offset;

  @override
  List<Object?> get props => [postId, offset];
}

class AddComment extends PostEvent {
  const AddComment({
    required this.postId,
    required this.content,
    this.parentId,
  });

  final String postId;
  final String content;
  final String? parentId;

  @override
  List<Object?> get props => [postId, content, parentId];
}

class UpdateComment extends PostEvent {
  const UpdateComment({
    required this.commentId,
    required this.content,
  });

  final String commentId;
  final String content;

  @override
  List<Object?> get props => [commentId, content];
}

class DeleteComment extends PostEvent {
  const DeleteComment({required this.commentId});

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

class ToggleCommentLike extends PostEvent {
  const ToggleCommentLike({required this.commentId});

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

class SharePost extends PostEvent {
  const SharePost({required this.postId});

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class SearchPosts extends PostEvent {
  const SearchPosts({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class LoadPostsByHashtag extends PostEvent {
  const LoadPostsByHashtag({required this.hashtag});

  final String hashtag;

  @override
  List<Object?> get props => [hashtag];
}
