part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications({this.type});

  final NotificationType? type;

  @override
  List<Object?> get props => [type];
}

class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications({this.type});

  final NotificationType? type;

  @override
  List<Object?> get props => [type];
}

class LoadUnreadCount extends NotificationEvent {
  const LoadUnreadCount();
}

class MarkNotificationAsRead extends NotificationEvent {
  const MarkNotificationAsRead({required this.notificationId});

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends NotificationEvent {
  const DeleteNotification({required this.notificationId});

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}

class LoadNotificationSettings extends NotificationEvent {
  const LoadNotificationSettings();
}

class UpdateNotificationSettings extends NotificationEvent {
  const UpdateNotificationSettings({required this.settings});

  final NotificationSettings settings;

  @override
  List<Object?> get props => [settings];
}

class RegisterDeviceToken extends NotificationEvent {
  const RegisterDeviceToken({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

class UnregisterDeviceToken extends NotificationEvent {
  const UnregisterDeviceToken({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

class WatchNotifications extends NotificationEvent {
  const WatchNotifications();
}

class WatchUnreadCount extends NotificationEvent {
  const WatchUnreadCount();
}

class NotificationsUpdated extends NotificationEvent {
  const NotificationsUpdated({required this.notifications});

  final List<NotificationEntity> notifications;

  @override
  List<Object?> get props => [notifications];
}

class UnreadCountUpdated extends NotificationEvent {
  const UnreadCountUpdated({required this.count});

  final int count;

  @override
  List<Object?> get props => [count];
}
