import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Get notifications
  Future<List<NotificationEntity>> getNotifications({
    int limit = 20,
    int offset = 0,
    String? type,
  });

  /// Get unread count
  Future<int> getUnreadCount();

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Clear all notifications
  Future<void> clearAllNotifications();

  /// Get notification settings
  Future<NotificationSettings> getSettings();

  /// Update notification settings
  Future<NotificationSettings> updateSettings(NotificationSettings settings);

  /// Register device token for push notifications
  Future<void> registerDeviceToken(String token);

  /// Unregister device token
  Future<void> unregisterDeviceToken(String token);

  /// Watch notifications for real-time updates
  Stream<List<NotificationEntity>> watchNotifications();

  /// Watch unread count for real-time updates
  Stream<int> watchUnreadCount();
}
