import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';

class ManageJobPage extends StatelessWidget {
  const ManageJobPage({
    required this.jobId,
    super.key,
  });

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Manage Job',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassPanel(
                  title: 'Job Status',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status', style: theme.textTheme.titleSmall),
                          _StatusChip(status: 'open'),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Vacancies Filled', style: theme.textTheme.bodyMedium),
                          Text('2 / 5', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Applications', style: theme.textTheme.bodyMedium),
                          Text('45', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassPanel(
                  title: 'Quick Actions',
                  intensity: GlassIntensity.light,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Iconsax.people),
                        label: const Text('View Applications'),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Iconsax.pause),
                        label: const Text('Pause Job Listing'),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Iconsax.close_circle),
                        label: const Text('Close & Reject Remaining'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassPanel(
                  title: 'Edit Job Details',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: [
                      GlassTextField(
                        label: 'Job Title',
                        hint: 'Senior Software Engineer',
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      GlassTextField(
                        label: 'Description',
                        hint: 'Job description...',
                        maxLines: 5,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: GlassTextField(
                              label: 'Min Salary',
                              hint: '15000',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingMedium),
                          Expanded(
                            child: GlassTextField(
                              label: 'Max Salary',
                              hint: '25000',
                              keyboardType: TextInputType.number,
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
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: status == 'open' ? AppColors.successBackground : AppColors.errorBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        status == 'open' ? 'Open' : 'Closed',
        style: TextStyle(
          color: status == 'open' ? AppColors.successDark : AppColors.errorDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
