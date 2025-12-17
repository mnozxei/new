import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required this.repository}) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<RegisterDeviceToken>(_onRegisterDeviceToken);
    on<UnregisterDeviceToken>(_onUnregisterDeviceToken);
    on<WatchNotifications>(_onWatchNotifications);
    on<WatchUnreadCount>(_onWatchUnreadCount);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<UnreadCountUpdated>(_onUnreadCountUpdated);
  }

  final NotificationRepository repository;
  int _currentOffset = 0;
  static const int _pageSize = 20;
  StreamSubscription<List<NotificationEntity>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());
    _currentOffset = 0;

    try {
      final notifications = await repository.getNotifications(
        limit: _pageSize,
        offset: _currentOffset,
        type: event.type,
      );
      emit(NotificationsLoaded(
        notifications: notifications,
        hasMore: notifications.length >= _pageSize,
      ));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreNotifications(LoadMoreNotifications event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded || !currentState.hasMore) return;

    _currentOffset += _pageSize;
    try {
      final notifications = await repository.getNotifications(
        limit: _pageSize,
        offset: _currentOffset,
        type: event.type,
      );
      emit(NotificationsLoaded(
        notifications: [...currentState.notifications, ...notifications],
        hasMore: notifications.length >= _pageSize,
      ));
    } catch (e) {
      _currentOffset -= _pageSize;
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onLoadUnreadCount(LoadUnreadCount event, Emitter<NotificationState> emit) async {
    try {
      final count = await repository.getUnreadCount();
      emit(UnreadCountLoaded(count: count));
    } catch (_) {
      // Silently fail
    }
  }

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAsRead(event.notificationId);
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return n.copyWith(isRead: true, readAt: DateTime.now());
          }
          return n;
        }).toList();

        emit(NotificationsLoaded(
          notifications: updatedNotifications,
          hasMore: currentState.hasMore,
        ));
      }
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(MarkAllNotificationsAsRead event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAllAsRead();
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedNotifications = currentState.notifications.map((n) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();

        emit(NotificationsLoaded(
          notifications: updatedNotifications,
          hasMore: currentState.hasMore,
        ));
      }
      emit(const AllNotificationsMarkedAsRead());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onDeleteNotification(DeleteNotification event, Emitter<NotificationState> emit) async {
    try {
      await repository.deleteNotification(event.notificationId);
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedNotifications = currentState.notifications
            .where((n) => n.id != event.notificationId)
            .toList();

        emit(NotificationsLoaded(
          notifications: updatedNotifications,
          hasMore: currentState.hasMore,
        ));
      }
      emit(NotificationDeleted(notificationId: event.notificationId));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onClearAllNotifications(ClearAllNotifications event, Emitter<NotificationState> emit) async {
    try {
      await repository.clearAllNotifications();
      emit(const NotificationsCleared());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onLoadNotificationSettings(LoadNotificationSettings event, Emitter<NotificationState> emit) async {
    try {
      final settings = await repository.getSettings();
      emit(NotificationSettingsLoaded(settings: settings));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onUpdateNotificationSettings(UpdateNotificationSettings event, Emitter<NotificationState> emit) async {
    try {
      final settings = await repository.updateSettings(event.settings);
      emit(NotificationSettingsUpdated(settings: settings));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onRegisterDeviceToken(RegisterDeviceToken event, Emitter<NotificationState> emit) async {
    await repository.registerDeviceToken(event.token);
  }

  Future<void> _onUnregisterDeviceToken(UnregisterDeviceToken event, Emitter<NotificationState> emit) async {
    await repository.unregisterDeviceToken(event.token);
  }

  void _onWatchNotifications(WatchNotifications event, Emitter<NotificationState> emit) {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = repository.watchNotifications().listen(
      (notifications) => add(NotificationsUpdated(notifications: notifications)),
    );
  }

  void _onWatchUnreadCount(WatchUnreadCount event, Emitter<NotificationState> emit) {
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = repository.watchUnreadCount().listen(
      (count) => add(UnreadCountUpdated(count: count)),
    );
  }

  void _onNotificationsUpdated(NotificationsUpdated event, Emitter<NotificationState> emit) {
    emit(NotificationsLoaded(
      notifications: event.notifications,
      hasMore: false,
    ));
  }

  void _onUnreadCountUpdated(UnreadCountUpdated event, Emitter<NotificationState> emit) {
    emit(UnreadCountLoaded(count: event.count));
  }
}
