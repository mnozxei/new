import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chat_entity.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationEntity>> getConversations({int page = 1, int limit = 20});
  Future<ConversationEntity> getConversationById(String conversationId);
  Future<ConversationEntity> getOrCreateConversation({required String participantId});
  Future<ConversationEntity> createGroupConversation({required String title, required List<String> participantIds, String? imageUrl});
  Future<List<MessageEntity>> getMessages({required String conversationId, int page = 1, int limit = 50, DateTime? before});
  Future<MessageEntity> sendMessage({required String conversationId, required String content, MessageType type = MessageType.text, Map<String, dynamic>? metadata});
  Future<void> markAsRead(String conversationId);
  Future<void> markMessageAsRead(String messageId);
  Future<void> deleteMessage(String messageId);
  Future<void> deleteConversation(String conversationId);
  Future<ConversationEntity> updateGroupConversation({required String conversationId, String? title, String? imageUrl});
  Future<void> addParticipants({required String conversationId, required List<String> participantIds});
  Future<void> removeParticipant({required String conversationId, required String participantId});
  Future<void> leaveConversation(String conversationId);
  Future<void> muteConversation({required String conversationId, required Duration duration});
  Future<void> unmuteConversation(String conversationId);
  Stream<List<ConversationEntity>> watchConversations();
  Stream<List<MessageEntity>> watchMessages(String conversationId);
  Stream<int> watchUnreadCount();
  Future<void> sendTypingIndicator(String conversationId);
  Future<List<MessageEntity>> searchMessages({required String query, String? conversationId, int page = 1, int limit = 20});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<ConversationEntity>> getConversations({int page = 1, int limit = 20}) async {
    final offset = (page - 1) * limit;

    final response = await _supabase
        .from('conversation_participants')
        .select('''
          conversation:conversations(
            *,
            participants:conversation_participants(
              user:profiles(*)
            ),
            last_message:messages(*)
          )
        ''')
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false, referencedTable: 'conversations')
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => _mapConversationFromJson(json['conversation'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ConversationEntity> getConversationById(String conversationId) async {
    final response = await _supabase
        .from('conversations')
        .select('''
          *,
          participants:conversation_participants(
            user:profiles(*)
          ),
          last_message:messages(*)
        ''')
        .eq('id', conversationId)
        .single();

    return _mapConversationFromJson(response);
  }

  @override
  Future<ConversationEntity> getOrCreateConversation({required String participantId}) async {
    final existingConversation = await _supabase.rpc(
      'get_direct_conversation',
      params: {
        'user_id_1': _currentUserId,
        'user_id_2': participantId,
      },
    );

    if (existingConversation != null) {
      return getConversationById(existingConversation as String);
    }

    final conversationResponse = await _supabase
        .from('conversations')
        .insert({'is_group': false})
        .select()
        .single();

    final conversationId = conversationResponse['id'] as String;

    await _supabase.from('conversation_participants').insert([
      {'conversation_id': conversationId, 'user_id': _currentUserId},
      {'conversation_id': conversationId, 'user_id': participantId},
    ]);

    return getConversationById(conversationId);
  }

  @override
  Future<ConversationEntity> createGroupConversation({
    required String title,
    required List<String> participantIds,
    String? imageUrl,
  }) async {
    final conversationResponse = await _supabase
        .from('conversations')
        .insert({
          'is_group': true,
          'title': title,
          'image_url': imageUrl,
          'created_by': _currentUserId,
        })
        .select()
        .single();

    final conversationId = conversationResponse['id'] as String;

    final participants = [_currentUserId, ...participantIds]
        .map((userId) => {'conversation_id': conversationId, 'user_id': userId})
        .toList();

    await _supabase.from('conversation_participants').insert(participants);

    return getConversationById(conversationId);
  }

  @override
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    DateTime? before,
  }) async {
    var query = _supabase
        .from('messages')
        .select('''
          *,
          sender:profiles!sender_id(*)
        ''')
        .eq('conversation_id', conversationId);

    if (before != null) {
      query = query.lt('created_at', before.toIso8601String());
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => _mapMessageFromJson(json))
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': _currentUserId,
          'content': content,
          'type': type.value,
          'metadata': metadata ?? {},
        })
        .select('''
          *,
          sender:profiles!sender_id(*)
        ''')
        .single();

    await _supabase.from('conversations').update({
      'last_message_id': response['id'],
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);

    return _mapMessageFromJson(response);
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _supabase
        .from('messages')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('conversation_id', conversationId)
        .neq('sender_id', _currentUserId)
        .isFilter('read_at', null);

    await _supabase.from('conversation_participants').update({
      'last_read_at': DateTime.now().toIso8601String(),
    }).eq('conversation_id', conversationId).eq('user_id', _currentUserId);
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await _supabase
        .from('messages')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', messageId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _supabase.from('messages').update({
      'deleted_at': DateTime.now().toIso8601String(),
      'content': '',
    }).eq('id', messageId);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _supabase
        .from('conversation_participants')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('user_id', _currentUserId);
  }

  @override
  Future<ConversationEntity> updateGroupConversation({
    required String conversationId,
    String? title,
    String? imageUrl,
  }) async {
    final updateData = <String, dynamic>{};
    if (title != null) updateData['title'] = title;
    if (imageUrl != null) updateData['image_url'] = imageUrl;

    await _supabase
        .from('conversations')
        .update(updateData)
        .eq('id', conversationId);

    return getConversationById(conversationId);
  }

  @override
  Future<void> addParticipants({
    required String conversationId,
    required List<String> participantIds,
  }) async {
    final participants = participantIds
        .map((userId) => {'conversation_id': conversationId, 'user_id': userId})
        .toList();

    await _supabase.from('conversation_participants').insert(participants);
  }

  @override
  Future<void> removeParticipant({
    required String conversationId,
    required String participantId,
  }) async {
    await _supabase
        .from('conversation_participants')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('user_id', participantId);
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    await removeParticipant(
      conversationId: conversationId,
      participantId: _currentUserId,
    );
  }

  @override
  Future<void> muteConversation({
    required String conversationId,
    required Duration duration,
  }) async {
    final mutedUntil = DateTime.now().add(duration);
    await _supabase.from('conversation_participants').update({
      'muted_until': mutedUntil.toIso8601String(),
    }).eq('conversation_id', conversationId).eq('user_id', _currentUserId);
  }

  @override
  Future<void> unmuteConversation(String conversationId) async {
    await _supabase.from('conversation_participants').update({
      'muted_until': null,
    }).eq('conversation_id', conversationId).eq('user_id', _currentUserId);
  }

  @override
  Stream<List<ConversationEntity>> watchConversations() {
    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .asyncMap((_) => getConversations());
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((data) => data.map((json) => _mapMessageFromJson(json)).toList());
  }

  @override
  Stream<int> watchUnreadCount() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .neq('sender_id', _currentUserId)
        .map((messages) => messages.where((m) => m['read_at'] == null).length);
  }

  @override
  Future<void> sendTypingIndicator(String conversationId) async {
    await _supabase.channel('typing:$conversationId').sendBroadcastMessage(
      event: 'typing',
      payload: {'user_id': _currentUserId},
    );
  }

  @override
  Future<List<MessageEntity>> searchMessages({
    required String query,
    String? conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;

    var queryBuilder = _supabase
        .from('messages')
        .select('''
          *,
          sender:profiles!sender_id(*)
        ''')
        .ilike('content', '%$query%');

    if (conversationId != null) {
      queryBuilder = queryBuilder.eq('conversation_id', conversationId);
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapMessageFromJson(json)).toList();
  }

  ConversationEntity _mapConversationFromJson(Map<String, dynamic> json) {
    final participantsList = json['participants'] as List? ?? [];
    final participants = participantsList.map((p) {
      final user = p['user'] as Map<String, dynamic>?;
      return ParticipantInfo(
        userId: user?['id'] as String? ?? '',
        name: user?['full_name'] as String? ?? '',
        avatarUrl: user?['avatar_url'] as String?,
        isOnline: false,
      );
    }).toList();

    final otherParticipants = participants.where((p) => p.userId != _currentUserId).toList();

    MessageEntity? lastMessage;
    if (json['last_message'] != null) {
      final messages = json['last_message'] as List;
      if (messages.isNotEmpty) {
        lastMessage = _mapMessageFromJson(messages.first as Map<String, dynamic>);
      }
    }

    final isGroup = json['is_group'] as bool? ?? false;
    final title = isGroup
        ? json['title'] as String?
        : otherParticipants.isNotEmpty
            ? otherParticipants.first.name
            : null;

    return ConversationEntity(
      id: json['id'] as String,
      title: title,
      imageUrl: json['image_url'] as String?,
      isGroup: isGroup,
      participants: participants,
      lastMessage: lastMessage,
      unreadCount: 0,
      isMuted: false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  MessageEntity _mapMessageFromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      type: MessageType.fromString(json['type'] as String? ?? 'text'),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      senderName: json['sender']?['full_name'] as String?,
      senderAvatar: json['sender']?['avatar_url'] as String?,
      isRead: json['read_at'] != null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }
}
