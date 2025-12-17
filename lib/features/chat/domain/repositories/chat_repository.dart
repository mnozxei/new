import '../entities/chat_entity.dart';

abstract class ChatRepository {
  /// Get user's conversations
  Future<List<ConversationEntity>> getConversations({
    int limit = 20,
    int offset = 0,
  });

  /// Get conversation by ID
  Future<ConversationEntity?> getConversationById(String conversationId);

  /// Get or create a direct conversation with a user
  Future<ConversationEntity> getOrCreateConversation({
    required String participantId,
  });

  /// Create a group conversation
  Future<ConversationEntity> createGroupConversation({
    required String name,
    required List<String> participantIds,
    String? imageUrl,
  });

  /// Get messages in a conversation
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  });

  /// Send a message
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  });

  /// Mark conversation as read
  Future<void> markAsRead(String conversationId);

  /// Delete a message
  Future<void> deleteMessage(String messageId);

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId);

  /// Update group conversation
  Future<ConversationEntity> updateGroupConversation({
    required String conversationId,
    String? name,
    String? imageUrl,
  });

  /// Add participants to group
  Future<void> addParticipants({
    required String conversationId,
    required List<String> participantIds,
  });

  /// Remove participant from group
  Future<void> removeParticipant({
    required String conversationId,
    required String participantId,
  });

  /// Leave a conversation
  Future<void> leaveConversation(String conversationId);

  /// Mute a conversation
  Future<void> muteConversation({
    required String conversationId,
    DateTime? mutedUntil,
  });

  /// Unmute a conversation
  Future<void> unmuteConversation(String conversationId);

  /// Watch conversations for real-time updates
  Stream<List<ConversationEntity>> watchConversations();

  /// Watch messages for real-time updates
  Stream<List<MessageEntity>> watchMessages(String conversationId);

  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId);

  /// Search messages
  Future<List<MessageEntity>> searchMessages({
    required String query,
    String? conversationId,
    int limit = 20,
    int offset = 0,
  });

  /// Get unread count
  Future<int> getUnreadCount();
}
