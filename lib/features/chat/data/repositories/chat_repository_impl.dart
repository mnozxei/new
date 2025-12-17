import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<List<ConversationEntity>> getConversations({
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getConversations(limit: limit, offset: offset);
  }

  @override
  Future<ConversationEntity?> getConversationById(String conversationId) async {
    return _remoteDataSource.getConversationById(conversationId);
  }

  @override
  Future<ConversationEntity> getOrCreateConversation({
    required String participantId,
  }) async {
    return _remoteDataSource.getOrCreateConversation(participantId: participantId);
  }

  @override
  Future<ConversationEntity> createGroupConversation({
    required String name,
    required List<String> participantIds,
    String? imageUrl,
  }) async {
    return _remoteDataSource.createGroupConversation(
      name: name,
      participantIds: participantIds,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  }) async {
    return _remoteDataSource.getMessages(
      conversationId: conversationId,
      limit: limit,
      before: before,
    );
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    return _remoteDataSource.sendMessage(
      conversationId: conversationId,
      content: content,
      messageType: messageType,
      metadata: metadata,
    );
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _remoteDataSource.markAsRead(conversationId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _remoteDataSource.deleteMessage(messageId);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _remoteDataSource.deleteConversation(conversationId);
  }

  @override
  Future<ConversationEntity> updateGroupConversation({
    required String conversationId,
    String? name,
    String? imageUrl,
  }) async {
    return _remoteDataSource.updateGroupConversation(
      conversationId: conversationId,
      name: name,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> addParticipants({
    required String conversationId,
    required List<String> participantIds,
  }) async {
    await _remoteDataSource.addParticipants(
      conversationId: conversationId,
      participantIds: participantIds,
    );
  }

  @override
  Future<void> removeParticipant({
    required String conversationId,
    required String participantId,
  }) async {
    await _remoteDataSource.removeParticipant(
      conversationId: conversationId,
      participantId: participantId,
    );
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    await _remoteDataSource.leaveConversation(conversationId);
  }

  @override
  Future<void> muteConversation({
    required String conversationId,
    DateTime? mutedUntil,
  }) async {
    await _remoteDataSource.muteConversation(
      conversationId: conversationId,
      mutedUntil: mutedUntil,
    );
  }

  @override
  Future<void> unmuteConversation(String conversationId) async {
    await _remoteDataSource.unmuteConversation(conversationId);
  }

  @override
  Stream<List<ConversationEntity>> watchConversations() {
    return _remoteDataSource.watchConversations();
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return _remoteDataSource.watchMessages(conversationId);
  }

  @override
  Future<void> sendTypingIndicator(String conversationId) async {
    await _remoteDataSource.sendTypingIndicator(conversationId);
  }

  @override
  Future<List<MessageEntity>> searchMessages({
    required String query,
    String? conversationId,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.searchMessages(
      query: query,
      conversationId: conversationId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    return _remoteDataSource.getUnreadCount();
  }
}
