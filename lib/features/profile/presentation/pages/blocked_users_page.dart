import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/cached_avatar.dart';

/// Page for managing blocked users
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final _supabase = Supabase.instance.client;
  List<BlockedUser> _blockedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('user_blocks')
          .select('''
            id,
            blocked_user_id,
            created_at,
            blocked_user:profiles!user_blocks_blocked_user_id_fkey(
              id,
              full_name,
              avatar_url,
              headline
            )
          ''')
          .eq('blocker_user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _blockedUsers = (response as List).map((json) {
          final blockedUser = json['blocked_user'] as Map<String, dynamic>?;
          return BlockedUser(
            blockId: json['id'] as String,
            userId: json['blocked_user_id'] as String,
            fullName: blockedUser?['full_name'] as String? ?? 'مستخدم محذوف',
            avatarUrl: blockedUser?['avatar_url'] as String?,
            headline: blockedUser?['headline'] as String?,
            blockedAt: DateTime.parse(json['created_at'] as String),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل في تحميل المستخدمين المحظورين';
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(BlockedUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الحظر'),
        content: Text('هل تريد إلغاء حظر ${user.fullName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إلغاء الحظر'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _supabase
          .from('user_blocks')
          .delete()
          .eq('id', user.blockId);

      setState(() {
        _blockedUsers.removeWhere((u) => u.blockId == user.blockId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء حظر ${user.fullName}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في إلغاء الحظر'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'المستخدمون المحظورون',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(_error!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppConstants.spacingMedium),
            FilledButton.icon(
              onPressed: _loadBlockedUsers,
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.user_tick,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا يوجد مستخدمون محظورون',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'عند حظر مستخدم، سيظهر هنا',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return _BlockedUserTile(
            user: user,
            onUnblock: () => _unblockUser(user),
          );
        },
      ),
    );
  }
}

class _BlockedUserTile extends StatelessWidget {
  const _BlockedUserTile({
    required this.user,
    required this.onUnblock,
  });

  final BlockedUser user;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: ListTile(
        leading: CachedAvatar(
          imageUrl: user.avatarUrl,
          name: user.fullName,
          radius: 24,
        ),
        title: Text(
          user.fullName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: user.headline != null
            ? Text(
                user.headline!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              )
            : Text(
                'محظور منذ ${_formatDate(user.blockedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
        trailing: TextButton(
          onPressed: onUnblock,
          child: const Text('إلغاء الحظر'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30} شهر';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعة';
    } else {
      return 'الآن';
    }
  }
}

class BlockedUser {
  const BlockedUser({
    required this.blockId,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.headline,
    required this.blockedAt,
  });

  final String blockId;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? headline;
  final DateTime blockedAt;
}
