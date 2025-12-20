import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/routes/route_names.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// A reusable prompt shown when visitors attempt restricted actions.
///
/// Usage:
/// ```dart
/// // Show as bottom sheet
/// final loggedIn = await LoginRequiredPrompt.show(
///   context,
///   action: 'التقديم على الوظيفة',
/// );
///
/// // Or use the static method for quick checks
/// LoginRequiredPrompt.checkAndPrompt(
///   context,
///   isAuthenticated: authState.isAuthenticated,
///   action: 'حفظ الوظيفة',
///   onAuthenticated: () => saveJob(),
/// );
/// ```
class LoginRequiredPrompt extends StatelessWidget {
  const LoginRequiredPrompt({
    super.key,
    required this.action,
    this.title,
    this.message,
    this.icon,
    this.onLogin,
    this.onRegister,
    this.onDismiss,
    this.returnPath,
  });

  /// The action the user is trying to perform (e.g., "التقديم على الوظيفة")
  final String action;

  /// Optional custom title
  final String? title;

  /// Optional custom message
  final String? message;

  /// Optional custom icon
  final IconData? icon;

  /// Callback when user taps login
  final VoidCallback? onLogin;

  /// Callback when user taps register
  final VoidCallback? onRegister;

  /// Callback when user dismisses
  final VoidCallback? onDismiss;

  /// Path to return to after login
  final String? returnPath;

  /// Show the prompt as a modal bottom sheet
  /// Returns true if user chose to login/register, false if dismissed
  static Future<bool> show(
    BuildContext context, {
    required String action,
    String? title,
    String? message,
    IconData? icon,
    String? returnPath,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginRequiredPrompt(
        action: action,
        title: title,
        message: message,
        icon: icon,
        returnPath: returnPath ?? GoRouterState.of(context).uri.toString(),
      ),
    );
    return result ?? false;
  }

  /// Show as a dialog instead of bottom sheet
  static Future<bool> showAsDialog(
    BuildContext context, {
    required String action,
    String? title,
    String? message,
    IconData? icon,
    String? returnPath,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        content: LoginRequiredPrompt(
          action: action,
          title: title,
          message: message,
          icon: icon,
          returnPath: returnPath,
        ),
      ),
    );
    return result ?? false;
  }

  /// Convenience method to check authentication and prompt if needed
  /// Returns true if user is authenticated or successfully logged in
  static Future<bool> checkAndPrompt(
    BuildContext context, {
    required bool isAuthenticated,
    required String action,
    VoidCallback? onAuthenticated,
  }) async {
    if (isAuthenticated) {
      onAuthenticated?.call();
      return true;
    }

    final result = await show(context, action: action);
    if (result && onAuthenticated != null) {
      // User will be redirected to login, callback will be handled after
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTitle = title ?? 'تسجيل الدخول مطلوب';
    final effectiveMessage = message ?? 'يجب تسجيل الدخول لـ$action';
    final effectiveIcon = icon ?? Iconsax.lock_1;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusExtraLarge),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppConstants.spacingLarge,
        right: AppConstants.spacingLarge,
        top: AppConstants.spacingLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              effectiveIcon,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),

          // Title
          Text(
            effectiveTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSmall),

          // Message
          Text(
            effectiveMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXLarge),

          // Login button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
                onLogin?.call();
                if (returnPath != null) {
                  context.push('${RouteNames.login}?returnTo=$returnPath');
                } else {
                  context.push(RouteNames.login);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Register button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context, true);
                onRegister?.call();
                if (returnPath != null) {
                  context.push('${RouteNames.register}?returnTo=$returnPath');
                } else {
                  context.push(RouteNames.register);
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              child: const Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              onDismiss?.call();
            },
            child: Text(
              'تصفح كزائر',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action-specific prompts with predefined messages
class LoginPrompts {
  LoginPrompts._();

  static Future<bool> forLike(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'الإعجاب',
        icon: Iconsax.heart,
      );

  static Future<bool> forComment(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'التعليق',
        icon: Iconsax.message,
      );

  static Future<bool> forShare(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'المشاركة',
        icon: Iconsax.share,
      );

  static Future<bool> forSave(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'الحفظ',
        icon: Iconsax.bookmark,
      );

  static Future<bool> forApplyJob(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'التقديم على الوظيفة',
        icon: Iconsax.briefcase,
      );

  static Future<bool> forEnrollCourse(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'التسجيل في الدورة',
        icon: Iconsax.book,
      );

  static Future<bool> forFollow(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'المتابعة',
        icon: Iconsax.user_add,
      );

  static Future<bool> forChat(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'المراسلة',
        icon: Iconsax.message,
      );

  static Future<bool> forCreatePost(BuildContext context) => LoginRequiredPrompt.show(
        context,
        action: 'إنشاء منشور',
        icon: Iconsax.edit,
      );
}
