import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chat_entity.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationEntity>> getConversations({int limit = 20, int offset = 0});
  Future<ConversationEntity?> getConversationById(String conversationId);
  Future<ConversationEntity> getOrCreateConversation({required String participantId});
  Future<ConversationEntity> createGroupConversation({required String name, required List<String> participantIds, String? imageUrl});
  Future<List<MessageEntity>> getMessages({required String conversationId, int limit = 50, DateTime? before});
  Future<MessageEntity> sendMessage({required String conversationId, required String content, String messageType = 'text', Map<String, dynamic>? metadata});
  Future<void> markAsRead(String conversationId);
  Future<void> deleteMessage(String messageId);
  Future<void> deleteConversation(String conversationId);
  Future<ConversationEntity> updateGroupConversation({required String conversationId, String? name, String? imageUrl});
  Future<void> addParticipants({required String conversationId, required List<String> participantIds});
  Future<void> removeParticipant({required String conversationId, required String participantId});
  Future<void> leaveConversation(String conversationId);
  Future<void> muteConversation({required String conversationId, DateTime? mutedUntil});
  Future<void> unmuteConversation(String conversationId);
  Stream<List<ConversationEntity>> watchConversations();
  Stream<List<MessageEntity>> watchMessages(String conversationId);
  Future<void> sendTypingIndicator(String conversationId);
  Future<List<MessageEntity>> searchMessages({required String query, String? conversationId, int limit = 20, int offset = 0});
  Future<int> getUnreadCount();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<ConversationEntity>> getConversations({int limit = 20, int offset = 0}) async {
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
  Future<ConversationEntity?> getConversationById(String conversationId) async {
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
        .maybeSingle();

    if (response == null) return null;
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
      final conversation = await getConversationById(existingConversation as String);
      if (conversation != null) return conversation;
    }

    final now = DateTime.now();
    final conversationResponse = await _supabase
        .from('conversations')
        .insert({
          'type': 'direct',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select()
        .single();

    final conversationId = conversationResponse['id'] as String;

    await _supabase.from('conversation_participants').insert([
      {'conversation_id': conversationId, 'user_id': _currentUserId},
      {'conversation_id': conversationId, 'user_id': participantId},
    ]);

    final conversation = await getConversationById(conversationId);
    return conversation!;
  }

  @override
  Future<ConversationEntity> createGroupConversation({
    required String name,
    required List<String> participantIds,
    String? imageUrl,
  }) async {
    final now = DateTime.now();
    final conversationResponse = await _supabase
        .from('conversations')
        .insert({
          'type': 'group',
          'name': name,
          'avatar_url': imageUrl,
          'created_by': _currentUserId,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select()
        .single();

    final conversationId = conversationResponse['id'] as String;

    final participants = [_currentUserId, ...participantIds]
        .map((userId) => {'conversation_id': conversationId, 'user_id': userId})
        .toList();

    await _supabase.from('conversation_participants').insert(participants);

    final conversation = await getConversationById(conversationId);
    return conversation!;
  }

  @override
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
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
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final response = await _supabase
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': _currentUserId,
          'content': content,
          'message_type': messageType,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select('''
          *,
          sender:profiles!sender_id(*)
        ''')
        .single();

    await _supabase.from('conversations').update({
      'last_message_at': now.toIso8601String(),
      'last_message_preview': content.length > 100 ? '${content.substring(0, 100)}...' : content,
      'updated_at': now.toIso8601String(),
    }).eq('id', conversationId);

    return _mapMessageFromJson(response);
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    final now = DateTime.now().toIso8601String();
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', _currentUserId)
        .eq('is_read', false);

    await _supabase.from('conversation_participants').update({
      'last_read_at': now,
    }).eq('conversation_id', conversationId).eq('user_id', _currentUserId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final now = DateTime.now().toIso8601String();
    await _supabase.from('messages').update({
      'is_deleted': true,
      'content': null,
      'updated_at': now,
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
    String? name,
    String? imageUrl,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updateData['name'] = name;
    if (imageUrl != null) updateData['avatar_url'] = imageUrl;

    await _supabase
        .from('conversations')
        .update(updateData)
        .eq('id', conversationId);

    final conversation = await getConversationById(conversationId);
    return conversation!;
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
    DateTime? mutedUntil,
  }) async {
    final muted = mutedUntil ?? DateTime.now().add(const Duration(days: 365));
    await _supabase.from('conversation_participants').update({
      'muted_until': muted.toIso8601String(),
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
    int limit = 20,
    int offset = 0,
  }) async {
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

  @override
  Future<int> getUnreadCount() async {
    final response = await _supabase
        .from('messages')
        .select()
        .neq('sender_id', _currentUserId)
        .eq('is_read', false)
        .count(CountOption.exact);

    return response.count;
  }

  ConversationEntity _mapConversationFromJson(Map<String, dynamic> json) {
    final participantsList = json['participants'] as List? ?? [];
    final participants = participantsList.map((p) {
      final user = p['user'] as Map<String, dynamic>?;
      return ParticipantInfo(
        id: user?['id'] as String? ?? '',
        fullName: user?['full_name'] as String? ?? '',
        avatarUrl: user?['avatar_url'] as String?,
        isOnline: false,
      );
    }).toList();

    final otherParticipants = participants.where((p) => p.id != _currentUserId).toList();

    String? lastMessagePreview;
    DateTime? lastMessageAt;
    if (json['last_message'] != null) {
      final messages = json['last_message'] as List;
      if (messages.isNotEmpty) {
        final lastMsg = messages.first as Map<String, dynamic>;
        lastMessagePreview = lastMsg['content'] as String?;
        if (lastMsg['created_at'] != null) {
          lastMessageAt = DateTime.parse(lastMsg['created_at'] as String);
        }
      }
    }

    final type = json['type'] as String? ?? 'direct';
    final isGroup = type == 'group';
    final name = isGroup
        ? json['name'] as String?
        : otherParticipants.isNotEmpty
            ? otherParticipants.first.fullName
            : null;

    final now = DateTime.now();

    return ConversationEntity(
      id: json['id'] as String,
      type: type,
      name: name,
      avatarUrl: json['avatar_url'] as String?,
      createdBy: json['created_by'] as String?,
      lastMessageAt: lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? json['last_message_preview'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
      participants: otherParticipants,
      unreadCount: 0,
      isMuted: false,
    );
  }

  MessageEntity _mapMessageFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    MessageSenderInfo? sender;
    if (json['sender'] != null) {
      final senderData = json['sender'] as Map<String, dynamic>;
      sender = MessageSenderInfo(
        id: senderData['id'] as String? ?? '',
        fullName: senderData['full_name'] as String? ?? '',
        avatarUrl: senderData['avatar_url'] as String?,
      );
    }

    return MessageEntity(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String?,
      content: json['content'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      mediaName: json['media_name'] as String?,
      mediaSize: json['media_size'] as int?,
      isEdited: json['is_edited'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      replyToId: json['reply_to_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : now,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : now,
      sender: sender,
      isRead: json['is_read'] as bool? ?? false,
      readBy: List<String>.from(json['read_by'] ?? []),
    );
  }
}
