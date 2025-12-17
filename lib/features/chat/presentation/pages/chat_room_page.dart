import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    required this.chatId,
    super.key,
  });

  final String chatId;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileChatRoomPage(
        chatId: widget.chatId,
        messageController: _messageController,
        scrollController: _scrollController,
      ),
      desktop: _DesktopChatRoomPage(
        chatId: widget.chatId,
        messageController: _messageController,
        scrollController: _scrollController,
      ),
    );
  }
}

class _MobileChatRoomPage extends StatelessWidget {
  const _MobileChatRoomPage({
    required this.chatId,
    required this.messageController,
    required this.scrollController,
  });

  final String chatId;
  final TextEditingController messageController;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        titleWidget: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLighter,
                  child: const Text('أم', style: TextStyle(color: AppColors.white, fontSize: 12)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('أحمد محمد', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('متصل الآن', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Iconsax.call), onPressed: () {}),
          IconButton(icon: const Icon(Iconsax.more), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _MessageList(scrollController: scrollController),
          ),
          _MessageInput(controller: messageController),
        ],
      ),
    );
  }
}

class _DesktopChatRoomPage extends StatelessWidget {
  const _DesktopChatRoomPage({
    required this.chatId,
    required this.messageController,
    required this.scrollController,
  });

  final String chatId;
  final TextEditingController messageController;
  final ScrollController scrollController;

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
                      IconButton(
                        icon: const Icon(Iconsax.arrow_right_1),
                        onPressed: () => context.pop(),
                      ),
                      Text('المحادثات', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                    itemCount: 10,
                    itemBuilder: (context, index) => _MiniChatItem(index: index, isSelected: index.toString() == chatId),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryLighter,
                            child: const Text('أم', style: TextStyle(color: AppColors.white)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('أحمد محمد', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('متصل الآن', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success)),
                        ],
                      ),
                      const Spacer(),
                      GlassIconButton(icon: Iconsax.call, onPressed: () {}),
                      const SizedBox(width: AppConstants.spacingSmall),
                      GlassIconButton(icon: Iconsax.video, onPressed: () {}),
                      const SizedBox(width: AppConstants.spacingSmall),
                      GlassIconButton(icon: Iconsax.more, onPressed: () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: _MessageList(scrollController: scrollController),
                ),
                _MessageInput(controller: messageController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChatItem extends StatelessWidget {
  const _MiniChatItem({
    required this.index,
    required this.isSelected,
  });

  final int index;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryExtraLight : Colors.transparent,
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
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLighter,
            child: Text('${index + 1}', style: const TextStyle(color: AppColors.white, fontSize: 12)),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('محادثة ${index + 1}', style: theme.textTheme.titleSmall),
                Text('آخر رسالة...', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: 20,
      itemBuilder: (context, index) => _MessageBubble(
        index: index,
        isMe: index % 3 != 0,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.index,
    required this.isMe,
  });

  final int index;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
                vertical: AppConstants.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.primaryExtraLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppConstants.borderRadiusLarge),
                  topRight: const Radius.circular(AppConstants.borderRadiusLarge),
                  bottomLeft: Radius.circular(isMe ? 0 : AppConstants.borderRadiusLarge),
                  bottomRight: Radius.circular(isMe ? AppConstants.borderRadiusLarge : 0),
                ),
              ),
              child: Text(
                _getMessage(index),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isMe ? AppColors.white : AppColors.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingExtraSmall),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTime(index),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: AppConstants.spacingExtraSmall),
                  Icon(
                    index % 2 == 0 ? Iconsax.tick_circle : Iconsax.tick_square,
                    size: 12,
                    color: index % 2 == 0 ? AppColors.primary : AppColors.textTertiaryLight,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage(int index) {
    final messages = [
      'مرحباً، كيف يمكنني مساعدتك؟',
      'أهلاً وسهلاً! أريد الاستفسار عن الوظيفة المعلنة',
      'بالتأكيد، ما هي استفساراتك؟',
      'هل الوظيفة متاحة للعمل عن بعد؟',
      'نعم، نوفر خيار العمل عن بعد بشكل جزئي',
      'رائع! متى يمكنني بدء المقابلة؟',
      'يمكننا تحديد موعد الأسبوع القادم',
      'شكراً جزيلاً لك على المعلومات',
    ];
    return messages[index % messages.length];
  }

  String _getTime(int index) {
    final times = ['10:30 ص', '10:32 ص', '10:35 ص', '10:40 ص', '11:00 ص'];
    return times[index % times.length];
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GlassIconButton(
              icon: Iconsax.attach_circle,
              onPressed: () {},
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: GlassTextField(
                controller: controller,
                hintText: 'اكتب رسالة...',
                maxLines: 1,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            GlassIconButton(
              icon: Iconsax.microphone,
              onPressed: () {},
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Iconsax.send_1, color: AppColors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
