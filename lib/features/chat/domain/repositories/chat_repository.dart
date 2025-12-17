import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, ConversationEntity>> getConversationById(String conversationId);

  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String participantId,
  });

  Future<Either<Failure, ConversationEntity>> createGroupConversation({
    required String title,
    required List<String> participantIds,
    String? imageUrl,
  });

  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    DateTime? before,
  });

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, void>> markAsRead(String conversationId);

  Future<Either<Failure, void>> markMessageAsRead(String messageId);

  Future<Either<Failure, void>> deleteMessage(String messageId);

  Future<Either<Failure, void>> deleteConversation(String conversationId);

  Future<Either<Failure, ConversationEntity>> updateGroupConversation({
    required String conversationId,
    String? title,
    String? imageUrl,
  });

  Future<Either<Failure, void>> addParticipants({
    required String conversationId,
    required List<String> participantIds,
  });

  Future<Either<Failure, void>> removeParticipant({
    required String conversationId,
    required String participantId,
  });

  Future<Either<Failure, void>> leaveConversation(String conversationId);

  Future<Either<Failure, void>> muteConversation({
    required String conversationId,
    required Duration duration,
  });

  Future<Either<Failure, void>> unmuteConversation(String conversationId);

  Stream<List<ConversationEntity>> watchConversations();

  Stream<List<MessageEntity>> watchMessages(String conversationId);

  Stream<int> watchUnreadCount();

  Future<Either<Failure, void>> sendTypingIndicator(String conversationId);

  Future<Either<Failure, List<MessageEntity>>> searchMessages({
    required String query,
    String? conversationId,
    int page = 1,
    int limit = 20,
  });
}
