import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/routes/route_names.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'glass_container.dart';

/// 404 Not Found Page
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: GlassCard(
              intensity: GlassIntensity.light,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingExtraLarge),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.search_status,
                        size: 64,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      '404',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      'الصفحة غير موجودة',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      message ?? 'الصفحة التي تبحث عنها غير موجودة أو تم نقلها.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingExtraLarge),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(RouteNames.posts);
                              }
                            },
                            icon: const Icon(Iconsax.arrow_right_1),
                            label: const Text('رجوع'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(RouteNames.posts),
                            icon: const Icon(Iconsax.home),
                            label: const Text('الرئيسية'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 403 Unauthorized Page
class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key, this.message, this.requiredPermission});

  final String? message;
  final String? requiredPermission;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: GlassCard(
              intensity: GlassIntensity.light,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingExtraLarge),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.lock,
                        size: 64,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      '403',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      'غير مصرح',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      message ?? 'ليس لديك صلاحية للوصول إلى هذه الصفحة.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (requiredPermission != null) ...[
                      const SizedBox(height: AppConstants.spacingMedium),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiaryLight,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.shield_tick, size: 20, color: AppColors.textSecondaryLight),
                            const SizedBox(width: AppConstants.spacingSmall),
                            Expanded(
                              child: Text(
                                'مطلوب: $requiredPermission',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.spacingExtraLarge),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(RouteNames.posts);
                              }
                            },
                            icon: const Icon(Iconsax.arrow_right_1),
                            label: const Text('رجوع'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(RouteNames.login),
                            icon: const Icon(Iconsax.login),
                            label: const Text('تسجيل الدخول'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Network Error Page
class NetworkErrorPage extends StatelessWidget {
  const NetworkErrorPage({super.key, this.onRetry, this.message});

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: GlassCard(
              intensity: GlassIntensity.light,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingExtraLarge),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.wifi_square,
                        size: 64,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      'خطأ في الاتصال',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      message ?? 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingExtraLarge),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onRetry ?? () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RouteNames.posts);
                          }
                        },
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Generic Error Widget (for inline errors)
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon ?? Iconsax.warning_2, size: 20, color: AppColors.error),
            const SizedBox(width: AppConstants.spacingSmall),
            Flexible(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: AppConstants.spacingSmall),
              TextButton(
                onPressed: onRetry,
                child: const Text('إعادة'),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Iconsax.warning_2, size: 48, color: AppColors.error),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacingMedium),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
