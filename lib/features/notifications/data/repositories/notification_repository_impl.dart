import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required NotificationRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<NotificationEntity>> getNotifications({
    int limit = 20,
    int offset = 0,
    String? type,
  }) async {
    return _remoteDataSource.getNotifications(
      limit: limit,
      offset: offset,
      type: type,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    return _remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> clearAllNotifications() async {
    await _remoteDataSource.clearAllNotifications();
  }

  @override
  Future<NotificationSettings> getSettings() async {
    return _remoteDataSource.getSettings();
  }

  @override
  Future<NotificationSettings> updateSettings(NotificationSettings settings) async {
    return _remoteDataSource.updateSettings(settings);
  }

  @override
  Future<void> registerDeviceToken(String token) async {
    await _remoteDataSource.registerDeviceToken(token);
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    await _remoteDataSource.unregisterDeviceToken(token);
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return _remoteDataSource.watchNotifications();
  }

  @override
  Stream<int> watchUnreadCount() {
    return _remoteDataSource.watchUnreadCount();
  }
}
