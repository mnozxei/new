import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../bloc/chat_bloc.dart';

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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load messages when page opens
    context.read<ChatBloc>().add(LoadMessages(conversationId: widget.chatId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<ChatBloc>().add(SendMessage(
      conversationId: widget.chatId,
      content: message,
    ));

    _messageController.clear();
    _focusNode.requestFocus();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachmentOption(
                  icon: Iconsax.image,
                  label: 'صورة',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon('إرسال الصور');
                  },
                ),
                _AttachmentOption(
                  icon: Iconsax.document,
                  label: 'ملف',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon('إرسال الملفات');
                  },
                ),
                _AttachmentOption(
                  icon: Iconsax.location,
                  label: 'موقع',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon('مشاركة الموقع');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('قريباً: $feature'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Iconsax.user),
              title: const Text('عرض الملف الشخصي'),
              onTap: () {
                Navigator.pop(context);
                context.push('/user/${widget.chatId}');
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.search_normal),
              title: const Text('البحث في المحادثة'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('البحث في المحادثة');
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.notification_1),
              title: const Text('كتم الإشعارات'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم كتم الإشعارات')),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.trash, color: AppColors.error),
              title: Text('حذف المحادثة', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: const Text('هل أنت متأكد من حذف هذه المحادثة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(DeleteConversation(conversationId: widget.chatId));
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المحادثة')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileChatRoomPage(
        chatId: widget.chatId,
        messageController: _messageController,
        scrollController: _scrollController,
        focusNode: _focusNode,
        onSend: _sendMessage,
        onAttachment: _showAttachmentOptions,
        onVoice: () => _showComingSoon('الرسائل الصوتية'),
        onCall: () => _showComingSoon('المكالمات الصوتية'),
        onMore: _showMoreOptions,
      ),
      desktop: _DesktopChatRoomPage(
        chatId: widget.chatId,
        messageController: _messageController,
        scrollController: _scrollController,
        focusNode: _focusNode,
        onSend: _sendMessage,
        onAttachment: _showAttachmentOptions,
        onVoice: () => _showComingSoon('الرسائل الصوتية'),
        onCall: () => _showComingSoon('المكالمات الصوتية'),
        onVideo: () => _showComingSoon('مكالمات الفيديو'),
        onMore: _showMoreOptions,
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MobileChatRoomPage extends StatelessWidget {
  const _MobileChatRoomPage({
    required this.chatId,
    required this.messageController,
    required this.scrollController,
    required this.focusNode,
    required this.onSend,
    required this.onAttachment,
    required this.onVoice,
    required this.onCall,
    required this.onMore,
  });

  final String chatId;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  final VoidCallback onVoice;
  final VoidCallback onCall;
  final VoidCallback onMore;

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
          IconButton(icon: const Icon(Iconsax.call), onPressed: onCall),
          IconButton(icon: const Icon(Iconsax.more), onPressed: onMore),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _MessageList(scrollController: scrollController);
              },
            ),
          ),
          _MessageInput(
            controller: messageController,
            focusNode: focusNode,
            onSend: onSend,
            onAttachment: onAttachment,
            onVoice: onVoice,
          ),
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
    required this.focusNode,
    required this.onSend,
    required this.onAttachment,
    required this.onVoice,
    required this.onCall,
    required this.onVideo,
    required this.onMore,
  });

  final String chatId;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  final VoidCallback onVoice;
  final VoidCallback onCall;
  final VoidCallback onVideo;
  final VoidCallback onMore;

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
                    itemBuilder: (context, index) => _MiniChatItem(
                      index: index,
                      isSelected: index.toString() == chatId,
                      onTap: () {
                        context.pushReplacementNamed(
                          'chatRoom',
                          pathParameters: {'id': index.toString()},
                        );
                      },
                    ),
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
                      GlassIconButton(icon: Iconsax.call, onPressed: onCall),
                      const SizedBox(width: AppConstants.spacingSmall),
                      GlassIconButton(icon: Iconsax.video, onPressed: onVideo),
                      const SizedBox(width: AppConstants.spacingSmall),
                      GlassIconButton(icon: Iconsax.more, onPressed: onMore),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _MessageList(scrollController: scrollController);
                    },
                  ),
                ),
                _MessageInput(
                  controller: messageController,
                  focusNode: focusNode,
                  onSend: onSend,
                  onAttachment: onAttachment,
                  onVoice: onVoice,
                ),
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
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
  const _MessageInput({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onAttachment,
    required this.onVoice,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  final VoidCallback onVoice;

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
              onPressed: onAttachment,
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: GlassTextField(
                controller: controller,
                focusNode: focusNode,
                hintText: 'اكتب رسالة...',
                maxLines: 1,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            GlassIconButton(
              icon: Iconsax.microphone,
              onPressed: onVoice,
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Iconsax.send_1, color: AppColors.white),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
