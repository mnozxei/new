import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobileJobsPage(),
      desktop: const _DesktopJobsPage(),
    );
  }
}

class _MobileJobsPage extends StatelessWidget {
  const _MobileJobsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'Jobs',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () => context.push(RouteNames.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: GlassSearchField(
              hint: 'Search jobs...',
              onChanged: (query) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
              ),
              itemCount: 10,
              itemBuilder: (context, index) => _JobCard(
                index: index,
                onTap: () => context.push('${RouteNames.jobs}/job-$index'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopJobsPage extends StatelessWidget {
  const _DesktopJobsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'Jobs',
        actions: [
          GlassButton(
            onPressed: () => context.push(RouteNames.postJob),
            icon: Iconsax.add,
            label: 'Post Job',
            intensity: GlassIntensity.light,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () => context.push(RouteNames.notifications),
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: _FiltersPanel(),
          ),
          Container(
            width: 1,
            color: AppColors.dividerLight,
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassSearchField(
                          hint: 'Search jobs...',
                          onChanged: (query) {},
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      _SortDropdown(),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppConstants.spacingMedium,
                      mainAxisSpacing: AppConstants.spacingMedium,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) => _JobCard(
                      index: index,
                      onTap: () => context.push('${RouteNames.jobs}/job-$index'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          _FilterSection(
            title: 'Job Type',
            options: ['Full-time', 'Part-time', 'Contract', 'Remote', 'Internship'],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          _FilterSection(
            title: 'Experience Level',
            options: ['Entry Level', 'Mid Level', 'Senior', 'Director', 'Executive'],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          _FilterSection(
            title: 'Salary Range',
            options: ['0-50K', '50K-100K', '100K-150K', '150K+'],
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text('Clear All'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
  });

  final String title;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Wrap(
          spacing: AppConstants.spacingSmall,
          runSpacing: AppConstants.spacingSmall,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: false,
              onSelected: (selected) {},
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall,
      ),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Most Recent',
          items: ['Most Recent', 'Most Relevant', 'Highest Salary', 'Nearest']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {},
          isDense: true,
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.index,
    required this.onTap,
  });

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: onTap,
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
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
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
                    Text(
                      'Software Engineer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.bookmark),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              _JobTag(icon: Iconsax.location, label: 'Riyadh'),
              const SizedBox(width: AppConstants.spacingSmall),
              _JobTag(icon: Iconsax.briefcase, label: 'Full-time'),
              const SizedBox(width: AppConstants.spacingSmall),
              _JobTag(icon: Iconsax.money, label: '15K-25K SAR'),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'We are looking for a skilled software engineer to join our team and help build innovative solutions...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2 hours ago',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
              Text(
                '${5 - index} vacancies left',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobTag extends StatelessWidget {
  const _JobTag({
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
