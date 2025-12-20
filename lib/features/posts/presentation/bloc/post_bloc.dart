import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.repository}) : super(const PostInitial()) {
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
    on<ToggleBookmark>(_onToggleBookmark);
    on<LoadSavedPosts>(_onLoadSavedPosts);
    on<ReportPost>(_onReportPost);
  }

  final PostRepository repository;
  DateTime? _feedCursor;
  static const int _pageSize = 20;

  Future<void> _onLoadFeed(LoadFeed event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    _feedCursor = null;

    try {
      final posts = await repository.getFeed(limit: _pageSize);
      if (posts.isNotEmpty) {
        _feedCursor = posts.last.createdAt;
      }
      emit(FeedLoaded(
        posts: posts,
        hasMore: posts.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreFeed(LoadMoreFeed event, Emitter<PostState> emit) async {
    final currentState = state;
    if (currentState is! FeedLoaded || !currentState.hasMore) return;

    try {
      final posts = await repository.getFeed(limit: _pageSize, cursor: _feedCursor);
      if (posts.isNotEmpty) {
        _feedCursor = posts.last.createdAt;
      }
      emit(FeedLoaded(
        posts: [...currentState.posts, ...posts],
        hasMore: posts.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserPosts(LoadUserPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      final posts = await repository.getUserPosts(
        userId: event.userId,
        limit: _pageSize,
        offset: 0,
      );
      emit(UserPostsLoaded(
        userId: event.userId,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onLoadCompanyPosts(LoadCompanyPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      final posts = await repository.getCompanyPosts(
        companyId: event.companyId,
        limit: _pageSize,
        offset: 0,
      );
      emit(CompanyPostsLoaded(
        companyId: event.companyId,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onLoadPostDetails(LoadPostDetails event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      final post = await repository.getPostById(event.postId);
      if (post == null) {
        emit(const PostError(message: 'Post not found'));
        return;
      }
      emit(PostDetailsLoaded(post: post));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    emit(const PostCreating());

    try {
      final post = await repository.createPost(
        content: event.content,
        mediaUrls: event.mediaUrls,
        companyId: event.companyId,
      );
      emit(PostCreated(post: post));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      final post = await repository.updatePost(
        postId: event.postId,
        content: event.content,
        mediaUrls: event.mediaUrls,
      );
      emit(PostUpdated(post: post));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    try {
      await repository.deletePost(event.postId);
      emit(PostDeleted(postId: event.postId));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onTogglePostLike(TogglePostLike event, Emitter<PostState> emit) async {
    try {
      final post = await repository.toggleLike(event.postId);
      emit(PostLikeToggled(post: post));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onLoadComments(LoadComments event, Emitter<PostState> emit) async {
    try {
      final comments = await repository.getComments(
        postId: event.postId,
        limit: _pageSize,
        offset: event.offset,
      );
      emit(CommentsLoaded(
        postId: event.postId,
        comments: comments,
        hasMore: comments.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onAddComment(AddComment event, Emitter<PostState> emit) async {
    try {
      final comment = await repository.addComment(
        postId: event.postId,
        content: event.content,
        parentId: event.parentId,
      );
      emit(CommentAdded(comment: comment));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onUpdateComment(UpdateComment event, Emitter<PostState> emit) async {
    try {
      final comment = await repository.updateComment(
        commentId: event.commentId,
        content: event.content,
      );
      emit(CommentUpdated(comment: comment));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onDeleteComment(DeleteComment event, Emitter<PostState> emit) async {
    try {
      await repository.deleteComment(event.commentId);
      emit(CommentDeleted(commentId: event.commentId));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onToggleCommentLike(ToggleCommentLike event, Emitter<PostState> emit) async {
    try {
      final comment = await repository.toggleCommentLike(event.commentId);
      emit(CommentLikeToggled(comment: comment));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onSharePost(SharePost event, Emitter<PostState> emit) async {
    try {
      await repository.sharePost(event.postId);
      emit(PostShared(postId: event.postId));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onSearchPosts(SearchPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      final posts = await repository.searchPosts(
        query: event.query,
        limit: _pageSize,
        offset: 0,
      );
      emit(PostSearchResults(
        query: event.query,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onLoadPostsByHashtag(LoadPostsByHashtag event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      final posts = await repository.getPostsByHashtag(
        hashtag: event.hashtag,
        limit: _pageSize,
        offset: 0,
      );
      emit(HashtagPostsLoaded(
        hashtag: event.hashtag,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onToggleBookmark(ToggleBookmark event, Emitter<PostState> emit) async {
    try {
      final isSaved = await repository.toggleBookmark(event.postId);
      emit(BookmarkToggled(postId: event.postId, isSaved: isSaved));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onLoadSavedPosts(LoadSavedPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      final posts = await repository.getSavedPosts(
        limit: _pageSize,
        offset: event.offset,
      );
      emit(SavedPostsLoaded(
        posts: posts,
        hasMore: posts.length >= _pageSize,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onReportPost(ReportPost event, Emitter<PostState> emit) async {
    try {
      await repository.reportPost(
        postId: event.postId,
        reason: event.reason,
        details: event.details,
      );
      emit(PostReported(postId: event.postId));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }
}
