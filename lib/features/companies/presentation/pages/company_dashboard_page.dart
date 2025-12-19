import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/company_member_entity.dart';
import '../bloc/company_bloc.dart';

class CompanyDashboardPage extends StatefulWidget {
  const CompanyDashboardPage({
    super.key,
    required this.companyId,
  });

  final String companyId;

  @override
  State<CompanyDashboardPage> createState() => _CompanyDashboardPageState();
}

class _CompanyDashboardPageState extends State<CompanyDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyBloc>().add(LoadCompanyDetails(companyId: widget.companyId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'لوحة الشركة',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {
              // Navigate to company settings
            },
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: BlocBuilder<CompanyBloc, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompanyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 64,
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(state.message),
                  const SizedBox(height: AppConstants.spacingMedium),
                  FilledButton(
                    onPressed: () {
                      context
                          .read<CompanyBloc>()
                          .add(LoadCompanyDetails(companyId: widget.companyId));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is CompanyDetailsLoaded) {
            return _DashboardContent(company: state.company);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.company});

  final CompanyEntity company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Header
          GlassCard(
            intensity: GlassIntensity.light,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: company.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium),
                          child: Image.network(
                            company.logoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            company.initials.toUpperCase(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (company.isVerified) ...[
                            const SizedBox(width: AppConstants.spacingSmall),
                            const Icon(
                              Iconsax.verify5,
                              color: AppColors.info,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      _StatusBadge(status: company.status),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Iconsax.people,
                  value: '${company.employeeCount}',
                  label: 'الموظفين',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _StatCard(
                  icon: Iconsax.briefcase,
                  value: '${company.jobCount}',
                  label: 'الوظائف',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _StatCard(
                  icon: Iconsax.heart,
                  value: '${company.followerCount}',
                  label: 'المتابعين',
                  color: AppColors.error,
                ),
              ),
            ],
          ),

          if (!company.isVerified && !company.isPending) ...[
            const SizedBox(height: AppConstants.spacingMedium),

            // Verification CTA
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withValues(alpha: 0.1),
                    AppColors.warning.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.shield_tick,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'وثّق شركتك',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'للحصول على مميزات إضافية ونشر الوظائف',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      context.push(
                        '${RouteNames.companies}/${company.id}/${RouteNames.companyVerification}',
                      );
                    },
                    child: const Text('ابدأ'),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppConstants.spacingMedium),

          // Quick Actions
          GlassPanel(
            title: 'إجراءات سريعة',
            intensity: GlassIntensity.light,
            child: Column(
              children: [
                _ActionItem(
                  icon: Iconsax.briefcase,
                  title: 'نشر وظيفة',
                  subtitle: 'أضف فرصة عمل جديدة',
                  enabled: company.canPostJobs,
                  onTap: () {
                    context.push(
                      '${RouteNames.postJob}?companyId=${company.id}',
                    );
                  },
                ),
                _ActionItem(
                  icon: Iconsax.people,
                  title: 'إدارة الفريق',
                  subtitle: 'دعوة أعضاء ومدربين',
                  onTap: () {
                    // Navigate to team management
                  },
                ),
                _ActionItem(
                  icon: Iconsax.book,
                  title: 'دورات الشركة',
                  subtitle: 'إدارة الدورات التدريبية',
                  onTap: () {
                    // Navigate to company courses
                  },
                ),
                _ActionItem(
                  icon: Iconsax.chart_21,
                  title: 'التحليلات',
                  subtitle: 'إحصائيات وتقارير مفصلة',
                  showDivider: false,
                  onTap: () {
                    // Navigate to analytics
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Recent Jobs
          GlassPanel(
            title: 'الوظائف النشطة',
            trailing: TextButton(
              onPressed: () {
                // View all jobs
              },
              child: const Text('عرض الكل'),
            ),
            intensity: GlassIntensity.light,
            child: company.jobCount == 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingLarge,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.briefcase,
                          size: 48,
                          color: AppColors.textTertiaryLight,
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Text(
                          'لا توجد وظائف بعد',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        if (company.canPostJobs) ...[
                          const SizedBox(height: AppConstants.spacingMedium),
                          FilledButton.icon(
                            onPressed: () {
                              context.push(
                                '${RouteNames.postJob}?companyId=${company.id}',
                              );
                            },
                            icon: const Icon(Iconsax.add, size: 18),
                            label: const Text('نشر وظيفة'),
                          ),
                        ],
                      ],
                    ),
                  )
                : Column(
                    children: List.generate(
                      3,
                      (index) => _JobItem(index: index),
                    ),
                  ),
          ),

          const SizedBox(height: AppConstants.spacingLarge),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CompanyStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case CompanyStatus.verified:
        color = AppColors.success;
        label = 'موثق';
        break;
      case CompanyStatus.pending:
        color = AppColors.warning;
        label = 'قيد المراجعة';
        break;
      case CompanyStatus.rejected:
        color = AppColors.error;
        label = 'مرفوض';
        break;
      case CompanyStatus.unverified:
        color = AppColors.textSecondaryLight;
        label = 'غير موثق';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMedium,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Iconsax.arrow_left_2,
                    size: 18,
                    color: AppColors.textTertiaryLight,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _JobItem extends StatelessWidget {
  const _JobItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobs = [
      'مطور تطبيقات Flutter',
      'مصمم UI/UX',
      'مدير تسويق رقمي',
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Icon(
              Iconsax.briefcase,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobs[index % jobs.length],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${(index + 1) * 5} متقدم',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Text(
                      'منذ ${index + 1} أيام',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Text(
              'نشط',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
