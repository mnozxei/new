import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(const NotificationInitial()) {
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

  final NotificationRepository _notificationRepository;
  int _currentPage = 1;
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
    _currentPage = 1;

    final result = await _notificationRepository.getNotifications(
      page: _currentPage,
      limit: _pageSize,
      type: event.type,
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) => emit(NotificationsLoaded(
        notifications: notifications,
        hasMore: notifications.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadMoreNotifications(LoadMoreNotifications event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded || !currentState.hasMore) return;

    _currentPage++;
    final result = await _notificationRepository.getNotifications(
      page: _currentPage,
      limit: _pageSize,
      type: event.type,
    );

    result.fold(
      (failure) {
        _currentPage--;
        emit(NotificationError(message: failure.message));
      },
      (notifications) => emit(NotificationsLoaded(
        notifications: [...currentState.notifications, ...notifications],
        hasMore: notifications.length >= _pageSize,
      )),
    );
  }

  Future<void> _onLoadUnreadCount(LoadUnreadCount event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepository.getUnreadCount();

    result.fold(
      (failure) => null,
      (count) => emit(UnreadCountLoaded(count: count)),
    );
  }

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepository.markAsRead(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
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
      },
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(MarkAllNotificationsAsRead event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepository.markAllAsRead();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
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
      },
    );
  }

  Future<void> _onDeleteNotification(DeleteNotification event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepository.deleteNotification(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) {
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
      },
    );
  }

  Future<void> _onClearAllNotifications(ClearAllNotifications event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepository.clearAllNotifications();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (_) => emit(const NotificationsCleared()),
    );
  }

  Future<void> _onLoadNotificationSettings(LoadNotificationSettings event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepository.getSettings();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (settings) => emit(NotificationSettingsLoaded(settings: settings)),
    );
  }

  Future<void> _onUpdateNotificationSettings(UpdateNotificationSettings event, Emitter<NotificationState> emit) async {
    final result = await _notificationRepository.updateSettings(event.settings);

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (settings) => emit(NotificationSettingsUpdated(settings: settings)),
    );
  }

  Future<void> _onRegisterDeviceToken(RegisterDeviceToken event, Emitter<NotificationState> emit) async {
    await _notificationRepository.registerDeviceToken(event.token);
  }

  Future<void> _onUnregisterDeviceToken(UnregisterDeviceToken event, Emitter<NotificationState> emit) async {
    await _notificationRepository.unregisterDeviceToken(event.token);
  }

  void _onWatchNotifications(WatchNotifications event, Emitter<NotificationState> emit) {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _notificationRepository.watchNotifications().listen(
      (notifications) => add(NotificationsUpdated(notifications: notifications)),
    );
  }

  void _onWatchUnreadCount(WatchUnreadCount event, Emitter<NotificationState> emit) {
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = _notificationRepository.watchUnreadCount().listen(
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
