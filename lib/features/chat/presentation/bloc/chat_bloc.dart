import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required this.repository}) : super(const ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMoreConversations>(_onLoadMoreConversations);
    on<LoadConversation>(_onLoadConversation);
    on<StartConversation>(_onStartConversation);
    on<CreateGroupConversation>(_onCreateGroupConversation);
    on<LoadMessages>(_onLoadMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkConversationAsRead>(_onMarkConversationAsRead);
    on<DeleteMessage>(_onDeleteMessage);
    on<DeleteConversation>(_onDeleteConversation);
    on<UpdateGroupConversation>(_onUpdateGroupConversation);
    on<AddGroupParticipants>(_onAddGroupParticipants);
    on<RemoveGroupParticipant>(_onRemoveGroupParticipant);
    on<LeaveGroup>(_onLeaveGroup);
    on<MuteConversation>(_onMuteConversation);
    on<UnmuteConversation>(_onUnmuteConversation);
    on<SendTypingIndicator>(_onSendTypingIndicator);
    on<SearchMessages>(_onSearchMessages);
    on<WatchConversations>(_onWatchConversations);
    on<WatchMessages>(_onWatchMessages);
    on<ConversationsUpdated>(_onConversationsUpdated);
    on<MessagesUpdated>(_onMessagesUpdated);
  }

  final ChatRepository repository;
  int _currentOffset = 0;
  static const int _pageSize = 20;
  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadConversations(LoadConversations event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    _currentOffset = 0;

    try {
      final conversations = await repository.getConversations(limit: _pageSize, offset: _currentOffset);
      emit(ConversationsLoaded(
        conversations: conversations,
        hasMore: conversations.length >= _pageSize,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreConversations(LoadMoreConversations event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ConversationsLoaded || !currentState.hasMore) return;

    _currentOffset += _pageSize;
    try {
      final conversations = await repository.getConversations(limit: _pageSize, offset: _currentOffset);
      emit(ConversationsLoaded(
        conversations: [...currentState.conversations, ...conversations],
        hasMore: conversations.length >= _pageSize,
      ));
    } catch (e) {
      _currentOffset -= _pageSize;
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadConversation(LoadConversation event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    try {
      final conversation = await repository.getConversationById(event.conversationId);
      if (conversation == null) {
        emit(const ChatError(message: 'Conversation not found'));
        return;
      }
      emit(ConversationLoaded(conversation: conversation));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onStartConversation(StartConversation event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    try {
      final conversation = await repository.getOrCreateConversation(
        participantId: event.participantId,
      );
      emit(ConversationStarted(conversation: conversation));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onCreateGroupConversation(CreateGroupConversation event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    try {
      final conversation = await repository.createGroupConversation(
        name: event.name,
        participantIds: event.participantIds,
        imageUrl: event.imageUrl,
      );
      emit(GroupConversationCreated(conversation: conversation));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(const MessagesLoading());

    try {
      final messages = await repository.getMessages(
        conversationId: event.conversationId,
        limit: 50,
      );
      emit(MessagesLoaded(
        conversationId: event.conversationId,
        messages: messages,
        hasMore: messages.length >= 50,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreMessages(LoadMoreMessages event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! MessagesLoaded || !currentState.hasMore) return;

    final oldestMessage = currentState.messages.first;
    try {
      final messages = await repository.getMessages(
        conversationId: event.conversationId,
        before: oldestMessage.createdAt,
        limit: 50,
      );
      emit(MessagesLoaded(
        conversationId: event.conversationId,
        messages: [...messages, ...currentState.messages],
        hasMore: messages.length >= 50,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      final message = await repository.sendMessage(
        conversationId: event.conversationId,
        content: event.content,
        messageType: event.messageType,
        metadata: event.metadata,
      );
      emit(MessageSent(message: message));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onMarkConversationAsRead(MarkConversationAsRead event, Emitter<ChatState> emit) async {
    await repository.markAsRead(event.conversationId);
  }

  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    try {
      await repository.deleteMessage(event.messageId);
      emit(MessageDeleted(messageId: event.messageId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onDeleteConversation(DeleteConversation event, Emitter<ChatState> emit) async {
    try {
      await repository.deleteConversation(event.conversationId);
      emit(ConversationDeleted(conversationId: event.conversationId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onUpdateGroupConversation(UpdateGroupConversation event, Emitter<ChatState> emit) async {
    try {
      final conversation = await repository.updateGroupConversation(
        conversationId: event.conversationId,
        name: event.name,
        imageUrl: event.imageUrl,
      );
      emit(GroupConversationUpdated(conversation: conversation));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onAddGroupParticipants(AddGroupParticipants event, Emitter<ChatState> emit) async {
    try {
      await repository.addParticipants(
        conversationId: event.conversationId,
        participantIds: event.participantIds,
      );
      emit(ParticipantsAdded(conversationId: event.conversationId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onRemoveGroupParticipant(RemoveGroupParticipant event, Emitter<ChatState> emit) async {
    try {
      await repository.removeParticipant(
        conversationId: event.conversationId,
        participantId: event.participantId,
      );
      emit(ParticipantRemoved(
        conversationId: event.conversationId,
        participantId: event.participantId,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLeaveGroup(LeaveGroup event, Emitter<ChatState> emit) async {
    try {
      await repository.leaveConversation(event.conversationId);
      emit(LeftGroup(conversationId: event.conversationId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onMuteConversation(MuteConversation event, Emitter<ChatState> emit) async {
    try {
      await repository.muteConversation(
        conversationId: event.conversationId,
        mutedUntil: event.mutedUntil,
      );
      emit(ConversationMuted(conversationId: event.conversationId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onUnmuteConversation(UnmuteConversation event, Emitter<ChatState> emit) async {
    try {
      await repository.unmuteConversation(event.conversationId);
      emit(ConversationUnmuted(conversationId: event.conversationId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendTypingIndicator(SendTypingIndicator event, Emitter<ChatState> emit) async {
    await repository.sendTypingIndicator(event.conversationId);
  }

  Future<void> _onSearchMessages(SearchMessages event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    try {
      final messages = await repository.searchMessages(
        query: event.query,
        conversationId: event.conversationId,
      );
      emit(MessageSearchResults(
        query: event.query,
        messages: messages,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void _onWatchConversations(WatchConversations event, Emitter<ChatState> emit) {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = repository.watchConversations().listen(
      (conversations) => add(ConversationsUpdated(conversations: conversations)),
    );
  }

  void _onWatchMessages(WatchMessages event, Emitter<ChatState> emit) {
    _messagesSubscription?.cancel();
    _messagesSubscription = repository.watchMessages(event.conversationId).listen(
      (messages) => add(MessagesUpdated(
        conversationId: event.conversationId,
        messages: messages,
      )),
    );
  }

  void _onConversationsUpdated(ConversationsUpdated event, Emitter<ChatState> emit) {
    emit(ConversationsLoaded(
      conversations: event.conversations,
      hasMore: false,
    ));
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    emit(MessagesLoaded(
      conversationId: event.conversationId,
      messages: event.messages,
      hasMore: false,
    ));
  }
}
