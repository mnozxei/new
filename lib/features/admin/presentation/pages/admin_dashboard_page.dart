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

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobileAdminDashboardPage(),
      desktop: const _DesktopAdminDashboardPage(),
    );
  }
}

class _MobileAdminDashboardPage extends StatelessWidget {
  const _MobileAdminDashboardPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'لوحة الإدارة',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatsGrid(),
            const SizedBox(height: AppConstants.spacingLarge),
            _PendingVerificationsSection(),
            const SizedBox(height: AppConstants.spacingLarge),
            _RecentActivitySection(),
            const SizedBox(height: AppConstants.spacingLarge),
            _QuickActionsSection(),
          ],
        ),
      ),
    );
  }
}

class _DesktopAdminDashboardPage extends StatelessWidget {
  const _DesktopAdminDashboardPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
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
                Text('لوحة الإدارة', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                GlassButton(
                  onPressed: () {},
                  intensity: GlassIntensity.light,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.setting_2, size: 18),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text('الإعدادات', style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            _StatsGrid(),
            const SizedBox(height: AppConstants.spacingLarge),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _PendingVerificationsSection(),
                      const SizedBox(height: AppConstants.spacingLarge),
                      _RecentActivitySection(),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingLarge),
                Expanded(
                  child: Column(
                    children: [
                      _QuickActionsSection(),
                      const SizedBox(height: AppConstants.spacingLarge),
                      _SystemStatusSection(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        final int crossAxisCount = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppConstants.spacingMedium,
          mainAxisSpacing: AppConstants.spacingMedium,
          childAspectRatio: isWide ? 1.5 : 1.3,
          children: const [
            _StatCard(
              icon: Iconsax.people,
              value: '12,456',
              label: 'المستخدمين',
              trend: '+12%',
              trendUp: true,
            ),
            _StatCard(
              icon: Iconsax.building,
              value: '234',
              label: 'الشركات',
              trend: '+8%',
              trendUp: true,
            ),
            _StatCard(
              icon: Iconsax.briefcase,
              value: '567',
              label: 'الوظائف',
              trend: '+15%',
              trendUp: true,
            ),
            _StatCard(
              icon: Iconsax.book,
              value: '89',
              label: 'الدورات',
              trend: '+5%',
              trendUp: true,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
  });

  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendUp ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                      size: 12,
                      color: trendUp ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: trendUp ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _PendingVerificationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'طلبات التوثيق المعلقة',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('عرض الكل'),
      ),
      intensity: GlassIntensity.light,
      child: Column(
        children: List.generate(
          3,
          (index) => _VerificationRequestItem(index: index),
        ),
      ),
    );
  }
}

class _VerificationRequestItem extends StatelessWidget {
  const _VerificationRequestItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companies = ['شركة التقنية الحديثة', 'مؤسسة الابتكار', 'شركة البناء المتقدم'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(companies[index % companies.length], style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('منذ ${index + 1} يوم', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Iconsax.tick_circle, color: AppColors.success),
                onPressed: () {},
                tooltip: 'قبول',
              ),
              IconButton(
                icon: const Icon(Iconsax.close_circle, color: AppColors.error),
                onPressed: () {},
                tooltip: 'رفض',
              ),
              IconButton(
                icon: const Icon(Iconsax.eye, color: AppColors.primary),
                onPressed: () {},
                tooltip: 'عرض',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'النشاط الأخير',
      intensity: GlassIntensity.light,
      child: Column(
        children: List.generate(
          5,
          (index) => _ActivityItem(index: index),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activities = [
      _Activity(icon: Iconsax.user_add, text: 'مستخدم جديد سجل في المنصة', time: 'منذ 5 دقائق', color: AppColors.success),
      _Activity(icon: Iconsax.building, text: 'شركة جديدة قدمت طلب توثيق', time: 'منذ 15 دقيقة', color: AppColors.warning),
      _Activity(icon: Iconsax.briefcase, text: 'وظيفة جديدة تم نشرها', time: 'منذ 30 دقيقة', color: AppColors.info),
      _Activity(icon: Iconsax.shield_tick, text: 'تم توثيق شركة التقنية', time: 'منذ ساعة', color: AppColors.success),
      _Activity(icon: Iconsax.message, text: 'بلاغ جديد بحاجة للمراجعة', time: 'منذ ساعتين', color: AppColors.error),
    ];
    final activity = activities[index % activities.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, size: 18, color: activity.color),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.text, style: theme.textTheme.bodyMedium),
                Text(activity.time, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Activity {
  const _Activity({
    required this.icon,
    required this.text,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String text;
  final String time;
  final Color color;
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'إجراءات سريعة',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          _QuickActionItem(icon: Iconsax.user_add, label: 'إدارة المستخدمين', onTap: () => context.push(RouteNames.adminUsers)),
          _QuickActionItem(icon: Iconsax.building_4, label: 'توثيق الشركات', onTap: () => context.push(RouteNames.adminCompanyVerifications)),
          _QuickActionItem(icon: Iconsax.message_question, label: 'البلاغات', badge: '5', onTap: () => context.push(RouteNames.adminReports)),
          _QuickActionItem(icon: Iconsax.chart_2, label: 'التحليلات', onTap: () => context.push(RouteNames.adminAuditLog)),
          _QuickActionItem(icon: Iconsax.verify, label: 'توثيق المدربين', onTap: () => context.push(RouteNames.adminInstructorVerifications)),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingSmall,
          horizontal: AppConstants.spacingExtraSmall,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.white)),
              ),
            const SizedBox(width: AppConstants.spacingSmall),
            const Icon(Iconsax.arrow_left_2, size: 16, color: AppColors.textTertiaryLight),
          ],
        ),
      ),
    );
  }
}

class _SystemStatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'حالة النظام',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          _StatusItem(label: 'الخادم', status: 'يعمل', isOnline: true),
          _StatusItem(label: 'قاعدة البيانات', status: 'يعمل', isOnline: true),
          _StatusItem(label: 'التخزين', status: 'يعمل', isOnline: true),
          _StatusItem(label: 'الإشعارات', status: 'يعمل', isOnline: true),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              const Icon(Iconsax.cpu, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('استخدام المعالج', style: theme.textTheme.bodySmall),
                        Text('45%', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: 0.45,
                      backgroundColor: AppColors.primaryExtraLight,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              const Icon(Iconsax.ram, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('استخدام الذاكرة', style: theme.textTheme.bodySmall),
                        Text('62%', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: 0.62,
                      backgroundColor: AppColors.primaryExtraLight,
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.label,
    required this.status,
    required this.isOnline,
  });

  final String label;
  final String status;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingExtraSmall),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          Text(status, style: theme.textTheme.bodySmall?.copyWith(color: isOnline ? AppColors.success : AppColors.error)),
        ],
      ),
    );
  }
}
