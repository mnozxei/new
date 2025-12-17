part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationError extends NotificationState {
  const NotificationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class NotificationsLoaded extends NotificationState {
  const NotificationsLoaded({
    required this.notifications,
    this.hasMore = false,
  });

  final List<NotificationEntity> notifications;
  final bool hasMore;

  @override
  List<Object?> get props => [notifications, hasMore];
}

class UnreadCountLoaded extends NotificationState {
  const UnreadCountLoaded({required this.count});

  final int count;

  @override
  List<Object?> get props => [count];
}

class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();
}

class NotificationDeleted extends NotificationState {
  const NotificationDeleted({required this.notificationId});

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class NotificationsCleared extends NotificationState {
  const NotificationsCleared();
}

class NotificationSettingsLoaded extends NotificationState {
  const NotificationSettingsLoaded({required this.settings});

  final NotificationSettings settings;

  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsUpdated extends NotificationState {
  const NotificationSettingsUpdated({required this.settings});

  final NotificationSettings settings;

  @override
  List<Object?> get props => [settings];
}
