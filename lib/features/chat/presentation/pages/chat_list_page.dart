import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/chat_bloc.dart';
import 'new_conversation_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const LoadConversations());
  }

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

  void _showNewConversationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewConversationPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'المحادثات',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () => _showNewConversationSheet(context),
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
              onChanged: (value) {
                // Search functionality
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
                        const SizedBox(height: AppConstants.spacingMedium),
                        Text(state.message),
                        const SizedBox(height: AppConstants.spacingMedium),
                        ElevatedButton(
                          onPressed: () => context.read<ChatBloc>().add(const LoadConversations()),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ConversationsLoaded) {
                  if (state.conversations.isEmpty) {
                    return _EmptyConversations(onNewConversation: () => _showNewConversationSheet(context));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ChatBloc>().add(const LoadConversations());
                    },
                    child: ListView.builder(
                      itemCount: state.conversations.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.conversations.length) {
                          context.read<ChatBloc>().add(const LoadMoreConversations());
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppConstants.spacingMedium),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _ChatItem(conversation: state.conversations[index]);
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
    );
  }
}

class _DesktopChatListPage extends StatelessWidget {
  const _DesktopChatListPage();

  void _showNewConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 500,
          child: const NewConversationPage(),
        ),
      ),
    );
  }

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
                        onPressed: () => _showNewConversationDialog(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
                  child: GlassTextField(
                    hintText: 'بحث...',
                    prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                    onChanged: (value) {
                      // Search functionality
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ChatError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
                              const SizedBox(height: AppConstants.spacingMedium),
                              Text(state.message, textAlign: TextAlign.center),
                              const SizedBox(height: AppConstants.spacingMedium),
                              ElevatedButton(
                                onPressed: () => context.read<ChatBloc>().add(const LoadConversations()),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is ConversationsLoaded) {
                        if (state.conversations.isEmpty) {
                          return _EmptyConversations(onNewConversation: () => _showNewConversationDialog(context));
                        }

                        return ListView.builder(
                          itemCount: state.conversations.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.conversations.length) {
                              context.read<ChatBloc>().add(const LoadMoreConversations());
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppConstants.spacingMedium),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _ChatItem(
                              conversation: state.conversations[index],
                              isDesktop: true,
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
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

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations({required this.onNewConversation});

  final VoidCallback onNewConversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.message, size: 64, color: AppColors.textTertiaryLight),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'لا توجد محادثات',
            style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'ابدأ محادثة جديدة مع أحد المستخدمين',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          ElevatedButton.icon(
            onPressed: onNewConversation,
            icon: const Icon(Iconsax.add),
            label: const Text('بدء محادثة'),
          ),
        ],
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem({
    required this.conversation,
    this.isDesktop = false,
  });

  final ConversationEntity conversation;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: () => context.pushNamed(RouteNames.chatRoom, pathParameters: {'chatId': conversation.id}),
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
                  backgroundImage: conversation.avatarUrl != null
                      ? NetworkImage(conversation.avatarUrl!)
                      : null,
                  child: conversation.avatarUrl == null
                      ? Text(
                          _getInitials(conversation.name ?? ''),
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                if (conversation.isOnline)
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
                          conversation.name ?? 'محادثة',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
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
                          conversation.lastMessagePreview ?? 'ابدأ المحادثة...',
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
                            '${conversation.unreadCount}',
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

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'أمس';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
      return '${dateTime.day}/${dateTime.month}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} س';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} د';
    } else {
      return 'الآن';
    }
  }
}
