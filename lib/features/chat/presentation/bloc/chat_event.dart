part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ChatEvent {
  const LoadConversations();
}

class LoadMoreConversations extends ChatEvent {
  const LoadMoreConversations();
}

class LoadConversation extends ChatEvent {
  const LoadConversation({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class StartConversation extends ChatEvent {
  const StartConversation({required this.participantId});

  final String participantId;

  @override
  List<Object?> get props => [participantId];
}

class CreateGroupConversation extends ChatEvent {
  const CreateGroupConversation({
    required this.name,
    required this.participantIds,
    this.imageUrl,
  });

  final String name;
  final List<String> participantIds;
  final String? imageUrl;

  @override
  List<Object?> get props => [name, participantIds, imageUrl];
}

class LoadMessages extends ChatEvent {
  const LoadMessages({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class LoadMoreMessages extends ChatEvent {
  const LoadMoreMessages({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class SendMessage extends ChatEvent {
  const SendMessage({
    required this.conversationId,
    required this.content,
    this.messageType = 'text',
    this.metadata,
  });

  final String conversationId;
  final String content;
  final String messageType;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [conversationId, content, messageType, metadata];
}

class MarkConversationAsRead extends ChatEvent {
  const MarkConversationAsRead({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class DeleteMessage extends ChatEvent {
  const DeleteMessage({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class DeleteConversation extends ChatEvent {
  const DeleteConversation({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class UpdateGroupConversation extends ChatEvent {
  const UpdateGroupConversation({
    required this.conversationId,
    this.name,
    this.imageUrl,
  });

  final String conversationId;
  final String? name;
  final String? imageUrl;

  @override
  List<Object?> get props => [conversationId, name, imageUrl];
}

class AddGroupParticipants extends ChatEvent {
  const AddGroupParticipants({
    required this.conversationId,
    required this.participantIds,
  });

  final String conversationId;
  final List<String> participantIds;

  @override
  List<Object?> get props => [conversationId, participantIds];
}

class RemoveGroupParticipant extends ChatEvent {
  const RemoveGroupParticipant({
    required this.conversationId,
    required this.participantId,
  });

  final String conversationId;
  final String participantId;

  @override
  List<Object?> get props => [conversationId, participantId];
}

class LeaveGroup extends ChatEvent {
  const LeaveGroup({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class MuteConversation extends ChatEvent {
  const MuteConversation({
    required this.conversationId,
    this.mutedUntil,
  });

  final String conversationId;
  final DateTime? mutedUntil;

  @override
  List<Object?> get props => [conversationId, mutedUntil];
}

class UnmuteConversation extends ChatEvent {
  const UnmuteConversation({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class SendTypingIndicator extends ChatEvent {
  const SendTypingIndicator({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class SearchMessages extends ChatEvent {
  const SearchMessages({
    required this.query,
    this.conversationId,
  });

  final String query;
  final String? conversationId;

  @override
  List<Object?> get props => [query, conversationId];
}

class WatchConversations extends ChatEvent {
  const WatchConversations();
}

class WatchMessages extends ChatEvent {
  const WatchMessages({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class ConversationsUpdated extends ChatEvent {
  const ConversationsUpdated({required this.conversations});

  final List<ConversationEntity> conversations;

  @override
  List<Object?> get props => [conversations];
}

class MessagesUpdated extends ChatEvent {
  const MessagesUpdated({
    required this.conversationId,
    required this.messages,
  });

  final String conversationId;
  final List<MessageEntity> messages;

  @override
  List<Object?> get props => [conversationId, messages];
}
