import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final conversations = await _remoteDataSource.getConversations(
        page: page,
        limit: limit,
      );
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversationById(
    String conversationId,
  ) async {
    try {
      final conversation = await _remoteDataSource.getConversationById(conversationId);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String participantId,
  }) async {
    try {
      final conversation = await _remoteDataSource.getOrCreateConversation(
        participantId: participantId,
      );
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> createGroupConversation({
    required String title,
    required List<String> participantIds,
    String? imageUrl,
  }) async {
    try {
      final conversation = await _remoteDataSource.createGroupConversation(
        title: title,
        participantIds: participantIds,
        imageUrl: imageUrl,
      );
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessages(
        conversationId: conversationId,
        page: page,
        limit: limit,
        before: before,
      );
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        metadata: metadata,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await _remoteDataSource.markAsRead(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(String messageId) async {
    try {
      await _remoteDataSource.markMessageAsRead(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await _remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String conversationId) async {
    try {
      await _remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> updateGroupConversation({
    required String conversationId,
    String? title,
    String? imageUrl,
  }) async {
    try {
      final conversation = await _remoteDataSource.updateGroupConversation(
        conversationId: conversationId,
        title: title,
        imageUrl: imageUrl,
      );
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addParticipants({
    required String conversationId,
    required List<String> participantIds,
  }) async {
    try {
      await _remoteDataSource.addParticipants(
        conversationId: conversationId,
        participantIds: participantIds,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeParticipant({
    required String conversationId,
    required String participantId,
  }) async {
    try {
      await _remoteDataSource.removeParticipant(
        conversationId: conversationId,
        participantId: participantId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveConversation(String conversationId) async {
    try {
      await _remoteDataSource.leaveConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> muteConversation({
    required String conversationId,
    required Duration duration,
  }) async {
    try {
      await _remoteDataSource.muteConversation(
        conversationId: conversationId,
        duration: duration,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unmuteConversation(String conversationId) async {
    try {
      await _remoteDataSource.unmuteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
  Stream<int> watchUnreadCount() {
    return _remoteDataSource.watchUnreadCount();
  }

  @override
  Future<Either<Failure, void>> sendTypingIndicator(String conversationId) async {
    try {
      await _remoteDataSource.sendTypingIndicator(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> searchMessages({
    required String query,
    String? conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final messages = await _remoteDataSource.searchMessages(
        query: query,
        conversationId: conversationId,
        page: page,
        limit: limit,
      );
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
