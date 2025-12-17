part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class MessagesLoading extends ChatState {
  const MessagesLoading();
}

class ChatError extends ChatState {
  const ChatError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ConversationsLoaded extends ChatState {
  const ConversationsLoaded({
    required this.conversations,
    this.hasMore = false,
  });

  final List<ConversationEntity> conversations;
  final bool hasMore;

  @override
  List<Object?> get props => [conversations, hasMore];
}

class ConversationLoaded extends ChatState {
  const ConversationLoaded({required this.conversation});

  final ConversationEntity conversation;

  @override
  List<Object?> get props => [conversation];
}

class ConversationStarted extends ChatState {
  const ConversationStarted({required this.conversation});

  final ConversationEntity conversation;

  @override
  List<Object?> get props => [conversation];
}

class GroupConversationCreated extends ChatState {
  const GroupConversationCreated({required this.conversation});

  final ConversationEntity conversation;

  @override
  List<Object?> get props => [conversation];
}

class MessagesLoaded extends ChatState {
  const MessagesLoaded({
    required this.conversationId,
    required this.messages,
    this.hasMore = false,
  });

  final String conversationId;
  final List<MessageEntity> messages;
  final bool hasMore;

  @override
  List<Object?> get props => [conversationId, messages, hasMore];
}

class MessageSent extends ChatState {
  const MessageSent({required this.message});

  final MessageEntity message;

  @override
  List<Object?> get props => [message];
}

class MessageDeleted extends ChatState {
  const MessageDeleted({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class ConversationDeleted extends ChatState {
  const ConversationDeleted({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class GroupConversationUpdated extends ChatState {
  const GroupConversationUpdated({required this.conversation});

  final ConversationEntity conversation;

  @override
  List<Object?> get props => [conversation];
}

class ParticipantsAdded extends ChatState {
  const ParticipantsAdded({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class ParticipantRemoved extends ChatState {
  const ParticipantRemoved({
    required this.conversationId,
    required this.participantId,
  });

  final String conversationId;
  final String participantId;

  @override
  List<Object?> get props => [conversationId, participantId];
}

class LeftGroup extends ChatState {
  const LeftGroup({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class ConversationMuted extends ChatState {
  const ConversationMuted({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class ConversationUnmuted extends ChatState {
  const ConversationUnmuted({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class MessageSearchResults extends ChatState {
  const MessageSearchResults({
    required this.query,
    required this.messages,
  });

  final String query;
  final List<MessageEntity> messages;

  @override
  List<Object?> get props => [query, messages];
}
