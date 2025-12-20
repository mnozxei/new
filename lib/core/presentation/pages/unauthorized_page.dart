import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/routes/route_names.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

/// 403 Unauthorized page shown when user lacks permission
class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({
    super.key,
    this.requiredRole,
    this.requiredPermission,
  });

  final String? requiredRole;
  final String? requiredPermission;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingExtraLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.lock,
                    size: 60,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingExtraLarge),

                // Error code
                Text(
                  '403',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),

                // Title
                Text(
                  'غير مصرح',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingMedium),

                // Description
                Text(
                  'عذراً، ليس لديك صلاحية للوصول إلى هذه الصفحة.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (requiredRole != null || requiredPermission != null) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: Column(
                      children: [
                        if (requiredRole != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.user,
                                size: 16,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: AppConstants.spacingSmall),
                              Text(
                                'الدور المطلوب: $requiredRole',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        if (requiredPermission != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.key,
                                size: 16,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: AppConstants.spacingSmall),
                              Text(
                                'الصلاحية المطلوبة: $requiredPermission',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingExtraLarge),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Iconsax.arrow_right_1),
                      label: const Text('العودة'),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    ElevatedButton.icon(
                      onPressed: () => context.go(RouteNames.posts),
                      icon: const Icon(Iconsax.home),
                      label: const Text('الرئيسية'),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingLarge),

                // Help text
                TextButton.icon(
                  onPressed: () {
                    // Could navigate to support or show contact info
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('للمساعدة، تواصل معنا على support@tamadhub.com'),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.message_question, size: 18),
                  label: const Text('هل تحتاج مساعدة؟'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
