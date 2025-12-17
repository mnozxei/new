import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
    NotificationType? type,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(String notificationId);

  Future<Either<Failure, void>> clearAllNotifications();

  Future<Either<Failure, NotificationSettings>> getSettings();

  Future<Either<Failure, NotificationSettings>> updateSettings(NotificationSettings settings);

  Future<Either<Failure, void>> registerDeviceToken(String token);

  Future<Either<Failure, void>> unregisterDeviceToken(String token);

  Stream<List<NotificationEntity>> watchNotifications();

  Stream<int> watchUnreadCount();
}
