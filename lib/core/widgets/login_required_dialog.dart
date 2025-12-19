import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/routes/route_names.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'glass_container.dart';

/// Reusable dialog shown when an action requires authentication
class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({
    super.key,
    this.title = 'تسجيل الدخول مطلوب',
    this.message = 'يجب تسجيل الدخول للقيام بهذا الإجراء',
    this.actionLabel,
  });

  final String title;
  final String message;
  final String? actionLabel;

  /// Show the login required dialog
  static Future<bool?> show(
    BuildContext context, {
    String title = 'تسجيل الدخول مطلوب',
    String? message,
    String? actionLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => LoginRequiredDialog(
        title: title,
        message: message ?? 'يجب تسجيل الدخول للقيام بهذا الإجراء',
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show dialog for specific action
  static Future<bool?> showForAction(
    BuildContext context,
    String action,
  ) {
    final messages = {
      'like': 'يجب تسجيل الدخول للإعجاب بهذا المحتوى',
      'comment': 'يجب تسجيل الدخول للتعليق',
      'share': 'يجب تسجيل الدخول للمشاركة',
      'save': 'يجب تسجيل الدخول لحفظ هذا المحتوى',
      'apply': 'يجب تسجيل الدخول للتقدم على هذه الوظيفة',
      'enroll': 'يجب تسجيل الدخول للتسجيل في هذه الدورة',
      'chat': 'يجب تسجيل الدخول لبدء محادثة',
      'follow': 'يجب تسجيل الدخول لمتابعة هذا المستخدم',
      'create': 'يجب تسجيل الدخول لإنشاء محتوى جديد',
    };

    return show(
      context,
      message: messages[action] ?? 'يجب تسجيل الدخول للقيام بهذا الإجراء',
      actionLabel: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        intensity: GlassIntensity.medium,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.lock,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        context.push(RouteNames.login);
                      },
                      child: const Text('تسجيل الدخول'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  context.push(RouteNames.register);
                },
                child: const Text('إنشاء حساب جديد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
