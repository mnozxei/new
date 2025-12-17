import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatInitial()) {
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

  final ChatRepository _chatRepository;
  int _currentPage = 1;
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
    _currentPage = 1;

    final result = await _chatRepository.getConversations(page: _currentPage, limit: _pageSize);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (conversations) => emit(ConversationsLoaded(
        conversations: conversations,
        hasMore: conversations.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadMoreConversations(LoadMoreConversations event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ConversationsLoaded || !currentState.hasMore) return;

    _currentPage++;
    final result = await _chatRepository.getConversations(page: _currentPage, limit: _pageSize);

    result.fold(
      (failure) {
        _currentPage--;
        emit(ChatError(message: failure.message));
      },
      (conversations) => emit(ConversationsLoaded(
        conversations: [...currentState.conversations, ...conversations],
        hasMore: conversations.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadConversation(LoadConversation event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await _chatRepository.getConversationById(event.conversationId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (conversation) => emit(ConversationLoaded(conversation: conversation)),
    );
  }

  Future<void> _onStartConversation(StartConversation event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await _chatRepository.getOrCreateConversation(
      participantId: event.participantId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (conversation) => emit(ConversationStarted(conversation: conversation)),
    );
  }

  Future<void> _onCreateGroupConversation(CreateGroupConversation event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await _chatRepository.createGroupConversation(
      title: event.title,
      participantIds: event.participantIds,
      imageUrl: event.imageUrl,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (conversation) => emit(GroupConversationCreated(conversation: conversation)),
    );
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(const MessagesLoading());

    final result = await _chatRepository.getMessages(
      conversationId: event.conversationId,
      limit: 50,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(MessagesLoaded(
        conversationId: event.conversationId,
        messages: messages,
        hasMore: messages.length >= 50,
      )),
    );
  }

  Future<void> _onLoadMoreMessages(LoadMoreMessages event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! MessagesLoaded || !currentState.hasMore) return;

    final oldestMessage = currentState.messages.first;
    final result = await _chatRepository.getMessages(
      conversationId: event.conversationId,
      before: oldestMessage.createdAt,
      limit: 50,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(MessagesLoaded(
        conversationId: event.conversationId,
        messages: [...messages, ...currentState.messages],
        hasMore: messages.length >= 50,
      )),
    );
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.sendMessage(
      conversationId: event.conversationId,
      content: event.content,
      type: event.type,
      metadata: event.metadata,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (message) => emit(MessageSent(message: message)),
    );
  }

  Future<void> _onMarkConversationAsRead(MarkConversationAsRead event, Emitter<ChatState> emit) async {
    await _chatRepository.markAsRead(event.conversationId);
  }

  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.deleteMessage(event.messageId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(MessageDeleted(messageId: event.messageId)),
    );
  }

  Future<void> _onDeleteConversation(DeleteConversation event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.deleteConversation(event.conversationId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ConversationDeleted(conversationId: event.conversationId)),
    );
  }

  Future<void> _onUpdateGroupConversation(UpdateGroupConversation event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.updateGroupConversation(
      conversationId: event.conversationId,
      title: event.title,
      imageUrl: event.imageUrl,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (conversation) => emit(GroupConversationUpdated(conversation: conversation)),
    );
  }

  Future<void> _onAddGroupParticipants(AddGroupParticipants event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.addParticipants(
      conversationId: event.conversationId,
      participantIds: event.participantIds,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ParticipantsAdded(conversationId: event.conversationId)),
    );
  }

  Future<void> _onRemoveGroupParticipant(RemoveGroupParticipant event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.removeParticipant(
      conversationId: event.conversationId,
      participantId: event.participantId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ParticipantRemoved(
        conversationId: event.conversationId,
        participantId: event.participantId,
      )),
    );
  }

  Future<void> _onLeaveGroup(LeaveGroup event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.leaveConversation(event.conversationId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(LeftGroup(conversationId: event.conversationId)),
    );
  }

  Future<void> _onMuteConversation(MuteConversation event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.muteConversation(
      conversationId: event.conversationId,
      duration: event.duration,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ConversationMuted(conversationId: event.conversationId)),
    );
  }

  Future<void> _onUnmuteConversation(UnmuteConversation event, Emitter<ChatState> emit) async {
    final result = await _chatRepository.unmuteConversation(event.conversationId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ConversationUnmuted(conversationId: event.conversationId)),
    );
  }

  Future<void> _onSendTypingIndicator(SendTypingIndicator event, Emitter<ChatState> emit) async {
    await _chatRepository.sendTypingIndicator(event.conversationId);
  }

  Future<void> _onSearchMessages(SearchMessages event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await _chatRepository.searchMessages(
      query: event.query,
      conversationId: event.conversationId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(MessageSearchResults(
        query: event.query,
        messages: messages,
      )),
    );
  }

  void _onWatchConversations(WatchConversations event, Emitter<ChatState> emit) {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _chatRepository.watchConversations().listen(
      (conversations) => add(ConversationsUpdated(conversations: conversations)),
    );
  }

  void _onWatchMessages(WatchMessages event, Emitter<ChatState> emit) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository.watchMessages(event.conversationId).listen(
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
