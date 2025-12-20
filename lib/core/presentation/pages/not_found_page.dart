import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/routes/route_names.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

/// 404 Not Found page shown when a route doesn't exist
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({
    super.key,
    this.path,
  });

  final String? path;

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
                    color: AppColors.warningBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.search_status,
                    size: 60,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingExtraLarge),

                // Error code
                Text(
                  '404',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),

                // Title
                Text(
                  'الصفحة غير موجودة',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingMedium),

                // Description
                Text(
                  'عذراً، الصفحة التي تبحث عنها غير موجودة أو تم نقلها.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (path != null) ...[
                  const SizedBox(height: AppConstants.spacingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMedium,
                      vertical: AppConstants.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      path!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.textTertiaryLight,
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
