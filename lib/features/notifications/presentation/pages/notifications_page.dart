import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_router.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobileNotificationsPage(),
      desktop: const _DesktopNotificationsPage(),
    );
  }
}

class _MobileNotificationsPage extends StatelessWidget {
  const _MobileNotificationsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'الإشعارات',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.tick_circle),
            onPressed: () {
              context.read<NotificationBloc>().add(const MarkAllNotificationsAsRead());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(state.message),
                  const SizedBox(height: AppConstants.spacingMedium),
                  ElevatedButton(
                    onPressed: () => context.read<NotificationBloc>().add(const LoadNotifications()),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const _EmptyNotifications();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    context.read<NotificationBloc>().add(const LoadMoreNotifications());
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.spacingMedium),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return _NotificationItem(notification: state.notifications[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DesktopNotificationsPage extends StatelessWidget {
  const _DesktopNotificationsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.arrow_right_1),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Text('الإشعارات', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      context.read<NotificationBloc>().add(const MarkAllNotificationsAsRead());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
                      );
                    },
                    icon: const Icon(Iconsax.tick_circle),
                    label: const Text('تحديد الكل كمقروء'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Expanded(
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is NotificationError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
                            const SizedBox(height: AppConstants.spacingMedium),
                            Text(state.message),
                            const SizedBox(height: AppConstants.spacingMedium),
                            ElevatedButton(
                              onPressed: () => context.read<NotificationBloc>().add(const LoadNotifications()),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is NotificationsLoaded) {
                      if (state.notifications.isEmpty) {
                        return const _EmptyNotifications();
                      }

                      return GlassCard(
                        intensity: GlassIntensity.light,
                        child: ListView.separated(
                          itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (index >= state.notifications.length) {
                              context.read<NotificationBloc>().add(const LoadMoreNotifications());
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppConstants.spacingMedium),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _NotificationItem(
                              notification: state.notifications[index],
                              isDesktop: true,
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.notification, size: 64, color: AppColors.textTertiaryLight),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'لا توجد إشعارات',
            style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'ستظهر الإشعارات هنا عند وصولها',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.notification,
    this.isDesktop = false,
  });

  final NotificationEntity notification;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: AppColors.error,
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<NotificationBloc>().add(DeleteNotification(notificationId: notification.id));
      },
      child: Container(
        margin: isDesktop ? null : const EdgeInsets.only(bottom: AppConstants.spacingSmall),
        decoration: isDesktop
            ? null
            : BoxDecoration(
                color: isUnread ? AppColors.primaryExtraLight : null,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
        child: Material(
          color: isDesktop && isUnread ? AppColors.primaryExtraLight : Colors.transparent,
          child: InkWell(
            onTap: () {
              // Mark as read if not already
              if (!notification.isRead) {
                context.read<NotificationBloc>().add(MarkNotificationAsRead(notificationId: notification.id));
              }
              // Navigate to target
              NotificationRouter.navigate(context, notification);
            },
            borderRadius: isDesktop ? null : BorderRadius.circular(AppConstants.borderRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NotificationIcon(type: notification.type),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (notification.message != null) ...[
                          const SizedBox(height: AppConstants.spacingExtraSmall),
                          Text(
                            notification.message!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: AppConstants.spacingSmall),
                        Text(
                          notification.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    switch (type) {
      case NotificationType.job:
        icon = Iconsax.briefcase;
        color = AppColors.success;
      case NotificationType.message:
        icon = Iconsax.message;
        color = AppColors.info;
      case NotificationType.course:
        icon = Iconsax.book;
        color = AppColors.warning;
      case NotificationType.company:
        icon = Iconsax.building;
        color = AppColors.primary;
      case NotificationType.like:
        icon = Iconsax.heart;
        color = AppColors.error;
      case NotificationType.comment:
        icon = Iconsax.message_text;
        color = AppColors.info;
      case NotificationType.follow:
        icon = Iconsax.user_add;
        color = AppColors.primary;
      case NotificationType.system:
        icon = Iconsax.notification;
        color = AppColors.textSecondaryLight;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
