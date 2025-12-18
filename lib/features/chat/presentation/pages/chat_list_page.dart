import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobileChatListPage(),
      desktop: const _DesktopChatListPage(),
    );
  }
}

class _MobileChatListPage extends StatelessWidget {
  const _MobileChatListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'المحادثات',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('بدء محادثة جديدة')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: GlassTextField(
              hintText: 'بحث في المحادثات...',
              prefixIcon: const Icon(Iconsax.search_normal),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) => _ChatItem(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopChatListPage extends StatelessWidget {
  const _DesktopChatListPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  child: Row(
                    children: [
                      Text('المحادثات', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GlassIconButton(
                        icon: Iconsax.edit,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('بدء محادثة جديدة')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
                  child: GlassTextField(
                    hintText: 'بحث...',
                    prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Expanded(
                  child: ListView.builder(
                    itemCount: 15,
                    itemBuilder: (context, index) => _ChatItem(index: index, isDesktop: true),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.message, size: 64, color: AppColors.textTertiaryLight),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text('اختر محادثة للبدء', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem({
    required this.index,
    this.isDesktop = false,
  });

  final int index;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasUnread = index % 3 == 0;
    final bool isOnline = index % 2 == 0;

    return InkWell(
      onTap: () => context.pushNamed(RouteNames.chatRoom, pathParameters: {'id': '$index'}),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: hasUnread ? AppColors.primaryExtraLight : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: theme.brightness == Brightness.dark
                  ? AppColors.dividerDark
                  : AppColors.dividerLight,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLighter,
                  child: Text(
                    _getInitials(index),
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getChatName(index),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _getTime(index),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hasUnread ? AppColors.primary : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingExtraSmall),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getLastMessage(index),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasUnread ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(int index) {
    final names = ['أم', 'سع', 'خا', 'فا', 'نو'];
    return names[index % names.length];
  }

  String _getChatName(int index) {
    final names = ['أحمد محمد', 'سعاد الأحمدي', 'خالد العتيبي', 'فاطمة السعيد', 'نورة المالكي'];
    return names[index % names.length];
  }

  String _getTime(int index) {
    final times = ['الآن', '5 د', '30 د', '1 س', 'أمس'];
    return times[index % times.length];
  }

  String _getLastMessage(int index) {
    final messages = [
      'شكراً جزيلاً لك!',
      'هل يمكنك إرسال الملفات؟',
      'موعدنا غداً إن شاء الله',
      'تم استلام الطلب',
      'مرحباً، كيف حالك؟',
    ];
    return messages[index % messages.length];
  }
}
