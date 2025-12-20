import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> getNotifications({int limit = 20, int offset = 0, String? type});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAllNotifications();
  Future<NotificationSettings> getSettings();
  Future<NotificationSettings> updateSettings(NotificationSettings settings);
  Future<void> registerDeviceToken(String token);
  Future<void> unregisterDeviceToken(String token);
  Stream<List<NotificationEntity>> watchNotifications();
  Stream<int> watchUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<NotificationEntity>> getNotifications({
    int limit = 20,
    int offset = 0,
    String? type,
  }) async {
    var query = _supabase
        .from('notifications')
        .select()
        .eq('user_id', _currentUserId);

    if (type != null) {
      query = query.eq('type', type);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => _mapNotificationFromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', _currentUserId)
        .eq('is_read', false)
        .count(CountOption.exact);

    return response.count;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _supabase.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await _supabase.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('user_id', _currentUserId).eq('is_read', false);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _supabase.from('notifications').delete().eq('id', notificationId);
  }

  @override
  Future<void> clearAllNotifications() async {
    await _supabase.from('notifications').delete().eq('user_id', _currentUserId);
  }

  @override
  Future<NotificationSettings> getSettings() async {
    final response = await _supabase
        .from('notification_settings')
        .select()
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (response == null) {
      final defaultSettings = const NotificationSettings();
      await _supabase.from('notification_settings').insert({
        'user_id': _currentUserId,
        ...defaultSettings.toJson(),
      });
      return defaultSettings;
    }

    return NotificationSettings.fromJson(response);
  }

  @override
  Future<NotificationSettings> updateSettings(NotificationSettings settings) async {
    await _supabase
        .from('notification_settings')
        .upsert({
          'user_id': _currentUserId,
          ...settings.toJson(),
        });

    return settings;
  }

  @override
  Future<void> registerDeviceToken(String token) async {
    await _supabase.from('device_tokens').upsert({
      'user_id': _currentUserId,
      'token': token,
      'platform': _getPlatform(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    await _supabase
        .from('device_tokens')
        .delete()
        .eq('user_id', _currentUserId)
        .eq('token', token);
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => _mapNotificationFromJson(json)).toList());
  }

  @override
  Stream<int> watchUnreadCount() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _currentUserId)
        .map((notifications) => notifications.where((n) => n['is_read'] == false).length);
  }

  String _getPlatform() {
    return 'flutter';
  }

  NotificationEntity _mapNotificationFromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String?,
      data: Map<String, dynamic>.from((json['data'] ?? {}) as Map),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
