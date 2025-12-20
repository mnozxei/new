import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  const PostEntity({
    required this.id,
    this.authorId,
    this.companyId,
    required this.content,
    this.mediaUrls = const [],
    this.mediaTypes = const [],
    this.visibility = 'public',
    this.isPinned = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.company,
    this.isLiked = false,
    this.isSaved = false,
    this.feedSource,
  });

  final String id;
  final String? authorId;
  final String? companyId;
  final String content;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final String visibility;
  final bool isPinned;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PostAuthorInfo? author;
  final PostCompanyInfo? company;
  final bool isLiked;
  final bool isSaved;
  final String? feedSource;

  bool get isUserPost => authorId != null;
  bool get isCompanyPost => companyId != null;
  bool get hasMedia => mediaUrls.isNotEmpty;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365} سنة';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30} شهر';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  PostEntity copyWith({
    String? id,
    String? authorId,
    String? companyId,
    String? content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    String? visibility,
    bool? isPinned,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    PostAuthorInfo? author,
    PostCompanyInfo? company,
    bool? isLiked,
    bool? isSaved,
    String? feedSource,
  }) {
    return PostEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      companyId: companyId ?? this.companyId,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      visibility: visibility ?? this.visibility,
      isPinned: isPinned ?? this.isPinned,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      company: company ?? this.company,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      feedSource: feedSource ?? this.feedSource,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        companyId,
        content,
        mediaUrls,
        mediaTypes,
        visibility,
        isPinned,
        likeCount,
        commentCount,
        shareCount,
        createdAt,
        updatedAt,
        author,
        company,
        isLiked,
        isSaved,
        feedSource,
      ];
}

class PostAuthorInfo extends Equatable {
  const PostAuthorInfo({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.headline,
    this.isVerified = false,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? headline;
  final bool isVerified;

  @override
  List<Object?> get props => [id, fullName, avatarUrl, headline, isVerified];
}

class PostCompanyInfo extends Equatable {
  const PostCompanyInfo({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final bool isVerified;

  @override
  List<Object?> get props => [id, name, logoUrl, isVerified];
}

class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    this.likeCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.replies = const [],
    this.isLiked = false,
  });

  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String content;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CommentUserInfo? user;
  final List<CommentEntity> replies;
  final bool isLiked;

  bool get isReply => parentId != null;
  bool get hasReplies => replies.isNotEmpty;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  CommentEntity copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentId,
    String? content,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    CommentUserInfo? user,
    List<CommentEntity>? replies,
    bool? isLiked,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        parentId,
        content,
        likeCount,
        createdAt,
        updatedAt,
        user,
        replies,
        isLiked,
      ];
}

class CommentUserInfo extends Equatable {
  const CommentUserInfo({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, fullName, avatarUrl];
}
