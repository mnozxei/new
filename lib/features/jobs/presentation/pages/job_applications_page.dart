import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class JobApplicationsPage extends StatelessWidget {
  const JobApplicationsPage({
    required this.jobId,
    super.key,
  });

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Applications',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 10,
        itemBuilder: (context, index) {
          return GlassCard(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
            intensity: GlassIntensity.light,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryLighter,
                      child: Text(
                        'U',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Applicant Name ${index + 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Software Engineer',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ApplicationStatusChip(
                      status: index % 4 == 0
                          ? 'submitted'
                          : index % 4 == 1
                              ? 'under_review'
                              : index % 4 == 2
                                  ? 'shortlisted'
                                  : 'rejected',
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('View Profile'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Review'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationStatusChip extends StatelessWidget {
  const _ApplicationStatusChip({required this.status});

  final String status;

  Color get backgroundColor {
    switch (status) {
      case 'submitted':
        return AppColors.infoBackground;
      case 'under_review':
        return AppColors.warningBackground;
      case 'shortlisted':
        return AppColors.successBackground;
      case 'rejected':
        return AppColors.errorBackground;
      default:
        return AppColors.primaryLightest;
    }
  }

  Color get textColor {
    switch (status) {
      case 'submitted':
        return AppColors.infoDark;
      case 'under_review':
        return AppColors.warningDark;
      case 'shortlisted':
        return AppColors.successDark;
      case 'rejected':
        return AppColors.errorDark;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String get label {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
