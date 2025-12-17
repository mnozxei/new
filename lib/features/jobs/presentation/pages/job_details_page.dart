import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({
    required this.jobId,
    super.key,
  });

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileJobDetails(jobId: jobId),
      desktop: _DesktopJobDetails(jobId: jobId),
    );
  }
}

class _MobileJobDetails extends StatelessWidget {
  const _MobileJobDetails({required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.bookmark),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _JobHeader(),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _JobInfoSection(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _JobDescriptionSection(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _JobRequirementsSection(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _CompanySection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _ApplyBottomSheet(),
    );
  }
}

class _DesktopJobDetails extends StatelessWidget {
  const _DesktopJobDetails({required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        title: 'Job Details',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.bookmark),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _JobHeader(),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _JobDescriptionSection(),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _JobRequirementsSection(),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingLarge),
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      _ApplyCard(),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _JobInfoSection(),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _CompanySection(),
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

class _JobHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: const Center(
                  child: Text(
                    'C',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Company Name',
                          style: theme.textTheme.titleSmall?.copyWith(
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
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Text(
                      'Senior Software Engineer',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Wrap(
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingSmall,
            children: [
              _Tag(icon: Iconsax.location, label: 'Riyadh, Saudi Arabia'),
              _Tag(icon: Iconsax.briefcase, label: 'Full-time'),
              _Tag(icon: Iconsax.money, label: '20K-35K SAR'),
              _Tag(icon: Iconsax.chart, label: 'Senior Level'),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      title: 'Job Information',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          _InfoRow(label: 'Posted', value: '2 days ago'),
          _InfoRow(label: 'Applications', value: '45 applicants'),
          _InfoRow(label: 'Vacancies', value: '3 positions'),
          _InfoRow(label: 'Status', value: 'Open', isHighlighted: true),
          _InfoRow(label: 'Deadline', value: 'January 15, 2026'),
        ],
      ),
    );
  }
}

class _JobDescriptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'Job Description',
      intensity: GlassIntensity.light,
      child: Text(
        '''We are looking for a talented Senior Software Engineer to join our growing team. In this role, you will be responsible for designing, developing, and maintaining high-quality software solutions.

You will work closely with cross-functional teams to deliver innovative products that meet our customers' needs. The ideal candidate has a strong background in software development, excellent problem-solving skills, and a passion for learning new technologies.

This is an exciting opportunity to make a significant impact in a fast-paced, dynamic environment.''',
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
      ),
    );
  }
}

class _JobRequirementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'Requirements',
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementItem('5+ years of experience in software development'),
          _RequirementItem('Strong proficiency in Flutter and Dart'),
          _RequirementItem('Experience with RESTful APIs and microservices'),
          _RequirementItem('Excellent communication skills in Arabic and English'),
          _RequirementItem("Bachelor's degree in Computer Science or related field"),
          _RequirementItem('Experience with agile development methodologies'),
        ],
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'About Company',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
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
                    Row(
                      children: [
                        Text(
                          'Company Name',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        const CompanyVerifiedBadge(
                          isVerified: true,
                          size: VerifiedBadgeSize.small,
                        ),
                      ],
                    ),
                    Text(
                      'Technology Company',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'A leading technology company specializing in innovative software solutions for businesses worldwide.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          OutlinedButton(
            onPressed: () {},
            child: const Text('View Company Profile'),
          ),
        ],
      ),
    );
  }
}

class _ApplyBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Apply Now'),
          ),
        ),
      ),
    );
  }
}

class _ApplyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      intensity: GlassIntensity.medium,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Apply Now'),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.bookmark),
              label: const Text('Save Job'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isHighlighted ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
