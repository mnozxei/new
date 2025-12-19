import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/routes/route_names.dart';
import '../widgets/login_required_dialog.dart';

/// Mixin for handling visitor-safe actions
/// Provides methods that check authentication before performing actions
mixin VisitorActionMixin<T extends StatefulWidget> on State<T> {
  /// Check if user is authenticated
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  /// Get current user ID (null if visitor)
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  /// Execute action if authenticated, otherwise show login dialog
  Future<void> requireAuth(
    String actionName,
    VoidCallback action,
  ) async {
    if (isAuthenticated) {
      action();
    } else {
      final result = await LoginRequiredDialog.showForAction(context, actionName);
      if (result == true && mounted) {
        // User chose to log in, they will be redirected
      }
    }
  }

  /// Navigate to search page
  void navigateToSearch() {
    context.push(RouteNames.search);
  }

  /// Navigate to notifications
  void navigateToNotifications() {
    if (isAuthenticated) {
      context.push(RouteNames.notifications);
    } else {
      LoginRequiredDialog.show(
        context,
        message: 'يجب تسجيل الدخول لعرض الإشعارات',
      );
    }
  }

  /// Share content using native share sheet
  void shareContent({
    required String title,
    required String url,
    String? text,
  }) {
    final shareText = text != null ? '$title\n\n$text\n\n$url' : '$title\n\n$url';
    Share.share(shareText, subject: title);
  }

  /// Show coming soon snackbar for features not yet implemented
  void showComingSoon([String? feature]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feature != null ? 'قريباً: $feature' : 'هذه الميزة قادمة قريباً'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show action confirmation
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show more options bottom sheet
  void showMoreOptions({
    required List<MoreOptionItem> options,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
                  leading: Icon(option.icon, color: option.isDestructive ? Colors.red : null),
                  title: Text(
                    option.label,
                    style: option.isDestructive ? const TextStyle(color: Colors.red) : null,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (option.requiresAuth && !isAuthenticated) {
                      LoginRequiredDialog.showForAction(context, option.actionName ?? 'action');
                    } else {
                      option.onTap();
                    }
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Option item for more options sheet
class MoreOptionItem {
  const MoreOptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.requiresAuth = false,
    this.actionName,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool requiresAuth;
  final String? actionName;
  final bool isDestructive;
}
