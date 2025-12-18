import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 15,
        itemBuilder: (context, index) => _NotificationItem(index: index),
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
                child: GlassCard(
                  intensity: GlassIntensity.light,
                  child: ListView.separated(
                    itemCount: 15,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) => _NotificationItem(index: index, isDesktop: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.index,
    this.isDesktop = false,
  });

  final int index;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notification = _getNotification(index);
    final bool isUnread = index < 3;

    return Container(
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم فتح: ${notification.title}')),
            );
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
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        notification.time,
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
    );
  }

  _NotificationData _getNotification(int index) {
    final notifications = [
      _NotificationData(
        type: _NotificationType.job,
        title: 'تم قبول طلبك',
        message: 'تهانينا! تم قبول طلبك لوظيفة مطور Flutter في شركة التقنية المتقدمة',
        time: 'منذ 5 دقائق',
      ),
      _NotificationData(
        type: _NotificationType.message,
        title: 'رسالة جديدة',
        message: 'لديك رسالة جديدة من أحمد محمد',
        time: 'منذ 15 دقيقة',
      ),
      _NotificationData(
        type: _NotificationType.course,
        title: 'دورة جديدة متاحة',
        message: 'تم إضافة دورة جديدة في تطوير تطبيقات الموبايل',
        time: 'منذ ساعة',
      ),
      _NotificationData(
        type: _NotificationType.company,
        title: 'تم التحقق من شركتك',
        message: 'تم التحقق من بيانات شركتك بنجاح',
        time: 'منذ ساعتين',
      ),
      _NotificationData(
        type: _NotificationType.like,
        title: 'إعجاب بمنشورك',
        message: 'أعجب 15 شخص بمنشورك الأخير',
        time: 'منذ 3 ساعات',
      ),
      _NotificationData(
        type: _NotificationType.comment,
        title: 'تعليق جديد',
        message: 'علق سعود على منشورك: "محتوى رائع!"',
        time: 'منذ 4 ساعات',
      ),
      _NotificationData(
        type: _NotificationType.follow,
        title: 'متابع جديد',
        message: 'بدأ خالد العتيبي بمتابعتك',
        time: 'أمس',
      ),
      _NotificationData(
        type: _NotificationType.system,
        title: 'تحديث التطبيق',
        message: 'تم إضافة ميزات جديدة للتطبيق',
        time: 'منذ يومين',
      ),
    ];
    return notifications[index % notifications.length];
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});

  final _NotificationType type;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    switch (type) {
      case _NotificationType.job:
        icon = Iconsax.briefcase;
        color = AppColors.success;
      case _NotificationType.message:
        icon = Iconsax.message;
        color = AppColors.info;
      case _NotificationType.course:
        icon = Iconsax.book;
        color = AppColors.warning;
      case _NotificationType.company:
        icon = Iconsax.building;
        color = AppColors.primary;
      case _NotificationType.like:
        icon = Iconsax.heart;
        color = AppColors.error;
      case _NotificationType.comment:
        icon = Iconsax.message_text;
        color = AppColors.info;
      case _NotificationType.follow:
        icon = Iconsax.user_add;
        color = AppColors.primary;
      case _NotificationType.system:
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

enum _NotificationType {
  job,
  message,
  course,
  company,
  like,
  comment,
  follow,
  system,
}

class _NotificationData {
  const _NotificationData({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
  });

  final _NotificationType type;
  final String title;
  final String message;
  final String time;
}
