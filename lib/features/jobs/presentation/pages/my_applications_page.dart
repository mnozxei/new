import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/verified_badge.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'My Applications',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _ApplicationCard(index: index);
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.index});

  final int index;

  String get status {
    switch (index % 6) {
      case 0:
        return 'submitted';
      case 1:
        return 'under_review';
      case 2:
        return 'shortlisted';
      case 3:
        return 'offered';
      case 4:
        return 'accepted';
      default:
        return 'rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: const Center(
                  child: Text(
                    'C',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Software Engineer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Company Name',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        const CompanyVerifiedBadge(
                          isVerified: true,
                          size: VerifiedBadgeSize.small,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              _InfoTag(icon: Iconsax.location, label: 'Riyadh'),
              const SizedBox(width: AppConstants.spacingSmall),
              _InfoTag(icon: Iconsax.calendar, label: 'Applied 3 days ago'),
            ],
          ),
          if (status == 'offered') ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color get backgroundColor {
    switch (status) {
      case 'submitted':
        return AppColors.infoBackground;
      case 'under_review':
        return AppColors.warningBackground;
      case 'shortlisted':
        return AppColors.primaryLightest;
      case 'offered':
        return AppColors.successBackground;
      case 'accepted':
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
        return AppColors.primary;
      case 'offered':
        return AppColors.successDark;
      case 'accepted':
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
      case 'offered':
        return 'Offer Received';
      case 'accepted':
        return 'Accepted';
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

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiaryLight),
        const SizedBox(width: AppConstants.spacingExtraSmall),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}
