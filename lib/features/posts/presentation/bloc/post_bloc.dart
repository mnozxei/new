import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(const PostInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<LoadMoreFeed>(_onLoadMoreFeed);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<LoadCompanyPosts>(_onLoadCompanyPosts);
    on<LoadPostDetails>(_onLoadPostDetails);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<TogglePostLike>(_onTogglePostLike);
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<ToggleCommentLike>(_onToggleCommentLike);
    on<SharePost>(_onSharePost);
    on<SearchPosts>(_onSearchPosts);
    on<LoadPostsByHashtag>(_onLoadPostsByHashtag);
  }

  final PostRepository _postRepository;
  int _currentPage = 1;
  static const int _pageSize = 20;

  Future<void> _onLoadFeed(LoadFeed event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    _currentPage = 1;

    final result = await _postRepository.getFeed(page: _currentPage, limit: _pageSize);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (posts) => emit(FeedLoaded(
        posts: posts,
        hasMore: posts.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadMoreFeed(LoadMoreFeed event, Emitter<PostState> emit) async {
    final currentState = state;
    if (currentState is! FeedLoaded || !currentState.hasMore) return;

    _currentPage++;
    final result = await _postRepository.getFeed(page: _currentPage, limit: _pageSize);

    result.fold(
      (failure) {
        _currentPage--;
        emit(PostError(message: failure.message));
      },
      (posts) => emit(FeedLoaded(
        posts: [...currentState.posts, ...posts],
        hasMore: posts.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadUserPosts(LoadUserPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    final result = await _postRepository.getUserPosts(
      userId: event.userId,
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (posts) => emit(UserPostsLoaded(
        userId: event.userId,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadCompanyPosts(LoadCompanyPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    final result = await _postRepository.getCompanyPosts(
      companyId: event.companyId,
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (posts) => emit(CompanyPostsLoaded(
        companyId: event.companyId,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadPostDetails(LoadPostDetails event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    final result = await _postRepository.getPostById(event.postId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (post) => emit(PostDetailsLoaded(post: post)),
    );
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    emit(const PostCreating());

    final result = await _postRepository.createPost(
      content: event.content,
      mediaUrls: event.mediaUrls,
      companyId: event.companyId,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (post) => emit(PostCreated(post: post)),
    );
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    final result = await _postRepository.updatePost(
      postId: event.postId,
      content: event.content,
      mediaUrls: event.mediaUrls,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (post) => emit(PostUpdated(post: post)),
    );
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    final result = await _postRepository.deletePost(event.postId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (_) => emit(PostDeleted(postId: event.postId)),
    );
  }

  Future<void> _onTogglePostLike(TogglePostLike event, Emitter<PostState> emit) async {
    final result = await _postRepository.toggleLike(event.postId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (post) => emit(PostLikeToggled(post: post)),
    );
  }

  Future<void> _onLoadComments(LoadComments event, Emitter<PostState> emit) async {
    final result = await _postRepository.getComments(
      postId: event.postId,
      page: event.page,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (comments) => emit(CommentsLoaded(
        postId: event.postId,
        comments: comments,
        hasMore: comments.length >= _pageSize,
      )),
    );
  }

  Future<void> _onAddComment(AddComment event, Emitter<PostState> emit) async {
    final result = await _postRepository.addComment(
      postId: event.postId,
      content: event.content,
      parentId: event.parentId,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (comment) => emit(CommentAdded(comment: comment)),
    );
  }

  Future<void> _onUpdateComment(UpdateComment event, Emitter<PostState> emit) async {
    final result = await _postRepository.updateComment(
      commentId: event.commentId,
      content: event.content,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (comment) => emit(CommentUpdated(comment: comment)),
    );
  }

  Future<void> _onDeleteComment(DeleteComment event, Emitter<PostState> emit) async {
    final result = await _postRepository.deleteComment(event.commentId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (_) => emit(CommentDeleted(commentId: event.commentId)),
    );
  }

  Future<void> _onToggleCommentLike(ToggleCommentLike event, Emitter<PostState> emit) async {
    final result = await _postRepository.toggleCommentLike(event.commentId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (comment) => emit(CommentLikeToggled(comment: comment)),
    );
  }

  Future<void> _onSharePost(SharePost event, Emitter<PostState> emit) async {
    final result = await _postRepository.sharePost(event.postId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (_) => emit(PostShared(postId: event.postId)),
    );
  }

  Future<void> _onSearchPosts(SearchPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    final result = await _postRepository.searchPosts(
      query: event.query,
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (posts) => emit(PostSearchResults(
        query: event.query,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadPostsByHashtag(LoadPostsByHashtag event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    final result = await _postRepository.getPostsByHashtag(
      hashtag: event.hashtag,
      page: 1,
      limit: _pageSize,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (posts) => emit(HashtagPostsLoaded(
        hashtag: event.hashtag,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      )),
    );
  }
}
