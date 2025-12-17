import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class MyCompaniesPage extends StatelessWidget {
  const MyCompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobileMyCompaniesPage(),
      desktop: const _DesktopMyCompaniesPage(),
    );
  }
}

class _MobileMyCompaniesPage extends StatelessWidget {
  const _MobileMyCompaniesPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'شركاتي',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.createCompany),
        backgroundColor: AppColors.primary,
        icon: const Icon(Iconsax.add, color: AppColors.white),
        label: Text('إضافة شركة', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 3,
        itemBuilder: (context, index) => _CompanyCard(index: index),
      ),
    );
  }
}

class _DesktopMyCompaniesPage extends StatelessWidget {
  const _DesktopMyCompaniesPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.arrow_right_1),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Text('شركاتي', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                GlassButton(
                  onPressed: () => context.pushNamed(RouteNames.createCompany),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.add, size: 18),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text('إضافة شركة', style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: AppConstants.spacingMedium,
                  mainAxisSpacing: AppConstants.spacingMedium,
                ),
                itemCount: 3,
                itemBuilder: (context, index) => _CompanyCard(index: index, isDesktop: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.index,
    this.isDesktop = false,
  });

  final int index;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final company = _getCompany(index);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: isDesktop ? null : const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.pushNamed(RouteNames.companyDetails, pathParameters: {'id': '$index'}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Center(
                  child: Text(
                    company.initials,
                    style: const TextStyle(
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
                        Flexible(
                          child: Text(
                            company.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (company.isVerified) ...[
                          const SizedBox(width: AppConstants.spacingExtraSmall),
                          const VerifiedBadge(size: VerifiedBadgeSize.small, type: VerifiedBadgeType.company),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Text(
                      company.industry,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Iconsax.more, size: 20),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(value: 'verify', child: Text('التحقق')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
                onSelected: (value) {
                  if (value == 'verify') {
                    context.pushNamed(RouteNames.companyVerification, pathParameters: {'id': '$index'});
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          _StatusBadge(status: company.status),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              _StatItem(icon: Iconsax.briefcase, value: '${company.activeJobs}', label: 'وظيفة نشطة'),
              const SizedBox(width: AppConstants.spacingLarge),
              _StatItem(icon: Iconsax.people, value: '${company.employees}', label: 'موظف'),
              const SizedBox(width: AppConstants.spacingLarge),
              _StatItem(icon: Iconsax.user_tick, value: '${company.followers}', label: 'متابع'),
            ],
          ),
          if (!company.isVerified && company.status != 'pending') ...[
            const SizedBox(height: AppConstants.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pushNamed(RouteNames.companyVerification, pathParameters: {'id': '$index'}),
                icon: const Icon(Iconsax.shield_tick, size: 18),
                label: const Text('توثيق الشركة'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _CompanyData _getCompany(int index) {
    final companies = [
      _CompanyData(
        name: 'شركة التقنية المتقدمة',
        initials: 'ت م',
        industry: 'تقنية المعلومات',
        status: 'verified',
        isVerified: true,
        activeJobs: 5,
        employees: 50,
        followers: 1234,
      ),
      _CompanyData(
        name: 'مؤسسة الابتكار',
        initials: 'م أ',
        industry: 'استشارات',
        status: 'pending',
        isVerified: false,
        activeJobs: 2,
        employees: 15,
        followers: 456,
      ),
      _CompanyData(
        name: 'شركة البناء الحديث',
        initials: 'ب ح',
        industry: 'إنشاءات',
        status: 'unverified',
        isVerified: false,
        activeJobs: 8,
        employees: 200,
        followers: 890,
      ),
    ];
    return companies[index % companies.length];
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color;
    final String label;
    final IconData icon;

    switch (status) {
      case 'verified':
        color = AppColors.success;
        label = 'موثقة';
        icon = Iconsax.shield_tick;
      case 'pending':
        color = AppColors.warning;
        label = 'قيد المراجعة';
        icon = Iconsax.clock;
      default:
        color = AppColors.textTertiaryLight;
        label = 'غير موثقة';
        icon = Iconsax.shield_cross;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: AppConstants.spacingExtraSmall),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight, fontSize: 10)),
      ],
    );
  }
}

class _CompanyData {
  const _CompanyData({
    required this.name,
    required this.initials,
    required this.industry,
    required this.status,
    required this.isVerified,
    required this.activeJobs,
    required this.employees,
    required this.followers,
  });

  final String name;
  final String initials;
  final String industry;
  final String status;
  final bool isVerified;
  final int activeJobs;
  final int employees;
  final int followers;
}
