part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostCreating extends PostState {
  const PostCreating();
}

class PostError extends PostState {
  const PostError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class FeedLoaded extends PostState {
  const FeedLoaded({
    required this.posts,
    this.hasMore = false,
  });

  final List<PostEntity> posts;
  final bool hasMore;

  @override
  List<Object?> get props => [posts, hasMore];
}

class UserPostsLoaded extends PostState {
  const UserPostsLoaded({
    required this.userId,
    required this.posts,
    this.hasMore = false,
  });

  final String userId;
  final List<PostEntity> posts;
  final bool hasMore;

  @override
  List<Object?> get props => [userId, posts, hasMore];
}

class CompanyPostsLoaded extends PostState {
  const CompanyPostsLoaded({
    required this.companyId,
    required this.posts,
    this.hasMore = false,
  });

  final String companyId;
  final List<PostEntity> posts;
  final bool hasMore;

  @override
  List<Object?> get props => [companyId, posts, hasMore];
}

class PostDetailsLoaded extends PostState {
  const PostDetailsLoaded({required this.post});

  final PostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostCreated extends PostState {
  const PostCreated({required this.post});

  final PostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostUpdated extends PostState {
  const PostUpdated({required this.post});

  final PostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostDeleted extends PostState {
  const PostDeleted({required this.postId});

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class PostLikeToggled extends PostState {
  const PostLikeToggled({required this.post});

  final PostEntity post;

  @override
  List<Object?> get props => [post];
}

class CommentsLoaded extends PostState {
  const CommentsLoaded({
    required this.postId,
    required this.comments,
    this.hasMore = false,
  });

  final String postId;
  final List<CommentEntity> comments;
  final bool hasMore;

  @override
  List<Object?> get props => [postId, comments, hasMore];
}

class CommentAdded extends PostState {
  const CommentAdded({required this.comment});

  final CommentEntity comment;

  @override
  List<Object?> get props => [comment];
}

class CommentUpdated extends PostState {
  const CommentUpdated({required this.comment});

  final CommentEntity comment;

  @override
  List<Object?> get props => [comment];
}

class CommentDeleted extends PostState {
  const CommentDeleted({required this.commentId});

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

class CommentLikeToggled extends PostState {
  const CommentLikeToggled({required this.comment});

  final CommentEntity comment;

  @override
  List<Object?> get props => [comment];
}

class PostShared extends PostState {
  const PostShared({required this.postId});

  final String postId;

  @override
  List<Object?> get props => [postId];
}

class PostSearchResults extends PostState {
  const PostSearchResults({
    required this.query,
    required this.posts,
    this.hasMore = false,
  });

  final String query;
  final List<PostEntity> posts;
  final bool hasMore;

  @override
  List<Object?> get props => [query, posts, hasMore];
}

class HashtagPostsLoaded extends PostState {
  const HashtagPostsLoaded({
    required this.hashtag,
    required this.posts,
    this.hasMore = false,
  });

  final String hashtag;
  final List<PostEntity> posts;
  final bool hasMore;

  @override
  List<Object?> get props => [hashtag, posts, hasMore];
}
