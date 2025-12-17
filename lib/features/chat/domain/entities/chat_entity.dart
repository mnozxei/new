import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  const ConversationEntity({
    required this.id,
    this.type = 'direct',
    this.name,
    this.avatarUrl,
    this.createdBy,
    this.lastMessageAt,
    this.lastMessagePreview,
    required this.createdAt,
    required this.updatedAt,
    this.participants = const [],
    this.unreadCount = 0,
    this.isMuted = false,
  });

  final String id;
  final String type;
  final String? name;
  final String? avatarUrl;
  final String? createdBy;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ParticipantInfo> participants;
  final int unreadCount;
  final bool isMuted;

  bool get isDirect => type == 'direct';
  bool get isGroup => type == 'group';
  bool get hasUnread => unreadCount > 0;

  String get displayName {
    if (isGroup && name != null) {
      return name!;
    }
    // For direct conversations, show the other participant's name
    if (participants.isNotEmpty) {
      return participants.first.fullName;
    }
    return 'محادثة';
  }

  String? get displayAvatar {
    if (isGroup && avatarUrl != null) {
      return avatarUrl;
    }
    if (participants.isNotEmpty) {
      return participants.first.avatarUrl;
    }
    return null;
  }

  bool get isOnline {
    if (participants.isNotEmpty) {
      return participants.first.isOnline;
    }
    return false;
  }

  String get lastMessageTime {
    if (lastMessageAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'أمس';
      if (diff.inDays < 7) return '${diff.inDays} أيام';
      return '${lastMessageAt!.day}/${lastMessageAt!.month}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} س';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} د';
    } else {
      return 'الآن';
    }
  }

  ConversationEntity copyWith({
    String? id,
    String? type,
    String? name,
    String? avatarUrl,
    String? createdBy,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ParticipantInfo>? participants,
    int? unreadCount,
    bool? isMuted,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participants: participants ?? this.participants,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        avatarUrl,
        createdBy,
        lastMessageAt,
        lastMessagePreview,
        createdAt,
        updatedAt,
        participants,
        unreadCount,
        isMuted,
      ];
}

class ParticipantInfo extends Equatable {
  const ParticipantInfo({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.role = 'member',
    this.isOnline = false,
    this.lastSeen,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final bool isOnline;
  final DateTime? lastSeen;

  bool get isAdmin => role == 'admin';

  String get lastSeenText {
    if (isOnline) return 'متصل الآن';
    if (lastSeen == null) return '';

    final now = DateTime.now();
    final diff = now.difference(lastSeen!);

    if (diff.inMinutes < 5) return 'متصل منذ قليل';
    if (diff.inMinutes < 60) return 'آخر ظهور منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'آخر ظهور منذ ${diff.inHours} ساعة';
    return 'آخر ظهور منذ ${diff.inDays} يوم';
  }

  @override
  List<Object?> get props => [id, fullName, avatarUrl, role, isOnline, lastSeen];
}

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    this.senderId,
    this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.mediaName,
    this.mediaSize,
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.replyTo,
    this.isRead = false,
    this.readBy = const [],
  });

  final String id;
  final String conversationId;
  final String? senderId;
  final String? content;
  final String messageType;
  final String? mediaUrl;
  final String? mediaName;
  final int? mediaSize;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageSenderInfo? sender;
  final MessageEntity? replyTo;
  final bool isRead;
  final List<String> readBy;

  bool get isTextMessage => messageType == 'text';
  bool get isImageMessage => messageType == 'image';
  bool get isFileMessage => messageType == 'file';
  bool get isSystemMessage => messageType == 'system';
  bool get isReply => replyToId != null;
  bool get hasMedia => mediaUrl != null;

  String get displayContent {
    if (isDeleted) return 'تم حذف هذه الرسالة';
    return content ?? '';
  }

  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get formattedFileSize {
    if (mediaSize == null) return '';
    if (mediaSize! < 1024) return '$mediaSize بايت';
    if (mediaSize! < 1024 * 1024) {
      return '${(mediaSize! / 1024).toStringAsFixed(1)} ك.ب';
    }
    return '${(mediaSize! / (1024 * 1024)).toStringAsFixed(1)} م.ب';
  }

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? messageType,
    String? mediaUrl,
    String? mediaName,
    int? mediaSize,
    bool? isEdited,
    bool? isDeleted,
    String? replyToId,
    DateTime? createdAt,
    DateTime? updatedAt,
    MessageSenderInfo? sender,
    MessageEntity? replyTo,
    bool? isRead,
    List<String>? readBy,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaName: mediaName ?? this.mediaName,
      mediaSize: mediaSize ?? this.mediaSize,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId ?? this.replyToId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      replyTo: replyTo ?? this.replyTo,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        content,
        messageType,
        mediaUrl,
        mediaName,
        mediaSize,
        isEdited,
        isDeleted,
        replyToId,
        createdAt,
        updatedAt,
        sender,
        replyTo,
        isRead,
        readBy,
      ];
}

class MessageSenderInfo extends Equatable {
  const MessageSenderInfo({
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
