import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/routes/route_names.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

/// Network error page shown when connection fails
class NetworkErrorPage extends StatelessWidget {
  const NetworkErrorPage({
    super.key,
    this.onRetry,
    this.errorMessage,
  });

  final VoidCallback? onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.infoBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.wifi_square,
                    size: 60,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXLarge),

                // Title
                Text(
                  'لا يوجد اتصال',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingMedium),

                // Description
                Text(
                  'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.info_circle,
                          size: 16,
                          color: AppColors.textTertiaryLight,
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        Flexible(
                          child: Text(
                            errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryLight,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingXLarge),

                // Retry button
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: onRetry ?? () {
                      // Default: try to reload the current page
                      context.go(GoRouterState.of(context).uri.toString());
                    },
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingMedium),

                // Home button
                TextButton.icon(
                  onPressed: () => context.go(RouteNames.posts),
                  icon: const Icon(Iconsax.home, size: 18),
                  label: const Text('العودة للرئيسية'),
                ),

                const SizedBox(height: AppConstants.spacingXLarge),

                // Tips
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.lamp_on,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppConstants.spacingSmall),
                          Text(
                            'نصائح',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      _buildTip(context, 'تأكد من اتصالك بشبكة Wi-Fi أو البيانات'),
                      _buildTip(context, 'حاول إعادة تشغيل التطبيق'),
                      _buildTip(context, 'تحقق من إعدادات الشبكة'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textSecondaryLight)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that can be used inline to show network error with retry
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    super.key,
    required this.onRetry,
    this.message,
    this.compact = false,
  });

  final VoidCallback onRetry;
  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.wifi_square,
              size: 32,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              message ?? 'فشل الاتصال',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh, size: 16),
              label: const Text('إعادة المحاولة'),
            ),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.wifi_square,
                size: 40,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'لا يوجد اتصال',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              message ?? 'تعذر الاتصال بالخادم',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
