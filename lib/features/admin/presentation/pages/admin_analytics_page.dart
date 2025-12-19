import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  String _selectedPeriod = '7days';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'التحليلات والإحصائيات',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export_1),
            onPressed: () {
              // TODO: Export analytics
            },
            tooltip: 'تصدير التقرير',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PeriodChip(
                    label: 'آخر 7 أيام',
                    value: '7days',
                    selected: _selectedPeriod == '7days',
                    onTap: () => setState(() => _selectedPeriod = '7days'),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  _PeriodChip(
                    label: 'آخر 30 يوم',
                    value: '30days',
                    selected: _selectedPeriod == '30days',
                    onTap: () => setState(() => _selectedPeriod = '30days'),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  _PeriodChip(
                    label: 'آخر 90 يوم',
                    value: '90days',
                    selected: _selectedPeriod == '90days',
                    onTap: () => setState(() => _selectedPeriod = '90days'),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  _PeriodChip(
                    label: 'هذا العام',
                    value: 'year',
                    selected: _selectedPeriod == 'year',
                    onTap: () => setState(() => _selectedPeriod = 'year'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Key Metrics
            Text(
              'المؤشرات الرئيسية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            _MetricsGrid(),

            const SizedBox(height: AppConstants.spacingLarge),

            // Growth Chart Placeholder
            GlassPanel(
              title: 'نمو المستخدمين',
              trailing: IconButton(
                icon: const Icon(Iconsax.maximize_3, size: 18),
                onPressed: () {},
                tooltip: 'عرض كامل',
              ),
              intensity: GlassIntensity.light,
              child: Container(
                height: 200,
                child: _GrowthChart(),
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Revenue & Enrollments
            Row(
              children: [
                Expanded(
                  child: _RevenueCard(),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Top Courses
            Text(
              'أفضل الدورات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            _TopCoursesList(),

            const SizedBox(height: AppConstants.spacingLarge),

            // Platform Activity
            Text(
              'نشاط المنصة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            _ActivityStats(),

            const SizedBox(height: AppConstants.spacingLarge),

            // Geographic Distribution
            GlassPanel(
              title: 'التوزيع الجغرافي',
              intensity: GlassIntensity.light,
              child: _GeographicStats(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.primaryExtraLight,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppConstants.spacingMedium,
      mainAxisSpacing: AppConstants.spacingMedium,
      childAspectRatio: 1.5,
      children: const [
        _MetricCard(
          icon: Iconsax.user_add,
          label: 'مستخدم جديد',
          value: '1,234',
          change: '+23%',
          isPositive: true,
        ),
        _MetricCard(
          icon: Iconsax.book,
          label: 'تسجيل في الدورات',
          value: '567',
          change: '+15%',
          isPositive: true,
        ),
        _MetricCard(
          icon: Iconsax.money_recive,
          label: 'الإيرادات',
          value: '45,230 ر.س',
          change: '+8%',
          isPositive: true,
        ),
        _MetricCard(
          icon: Iconsax.briefcase,
          label: 'طلب توظيف',
          value: '234',
          change: '-5%',
          isPositive: false,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  final IconData icon;
  final String label;
  final String value;
  final String change;
  final bool isPositive;

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                      size: 10,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
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

class _GrowthChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder chart visualization
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final height = 0.3 + (index * 0.1);
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 120 * height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDayLabel(index),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  String _getDayLabel(int index) {
    final days = ['س', 'أ', 'ث', 'ر', 'خ', 'ج', 'ش'];
    return days[index];
  }
}

class _RevenueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'الإيرادات',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي الإيرادات',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '125,430 ر.س',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'معدل النمو',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.arrow_up_3,
                        size: 16,
                        color: AppColors.success,
                      ),
                      Text(
                        '+18.5%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          const Divider(),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _RevenueBreakdownItem(
                  label: 'الدورات',
                  value: '85,200 ر.س',
                  percentage: 68,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: _RevenueBreakdownItem(
                  label: 'الوظائف',
                  value: '40,230 ر.س',
                  percentage: 32,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueBreakdownItem extends StatelessWidget {
  const _RevenueBreakdownItem({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });

  final String label;
  final String value;
  final int percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _TopCoursesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final courses = [
      ('أساسيات البرمجة بـ Python', 234, 4.9, 15600),
      ('تطوير تطبيقات الموبايل', 189, 4.8, 12500),
      ('تصميم واجهات المستخدم UI/UX', 156, 4.7, 9800),
      ('إدارة المشاريع الاحترافية', 134, 4.6, 8900),
      ('التسويق الرقمي المتقدم', 112, 4.5, 7200),
    ];

    return GlassPanel(
      intensity: GlassIntensity.light,
      child: Column(
        children: courses.asMap().entries.map((entry) {
          final index = entry.key;
          final course = entry.value;
          final isLast = index == courses.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingSmall,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: index < 3
                            ? AppColors.warning
                            : AppColors.primaryExtraLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: index < 3 ? Colors.white : AppColors.primary,
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
                            course.$1,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.people,
                                size: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.$2}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Iconsax.star1,
                                size: 12,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.$3}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${course.$4} ر.س',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ActivityStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActivityStatCard(
            icon: Iconsax.login,
            label: 'تسجيل دخول',
            value: '3,456',
            subtitle: 'اليوم',
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _ActivityStatCard(
            icon: Iconsax.document,
            label: 'منشور جديد',
            value: '234',
            subtitle: 'هذا الأسبوع',
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _ActivityStatCard(
            icon: Iconsax.message,
            label: 'رسالة',
            value: '1,234',
            subtitle: 'اليوم',
          ),
        ),
      ],
    );
  }
}

class _ActivityStatCard extends StatelessWidget {
  const _ActivityStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
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
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeographicStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final regions = [
      ('السعودية', 65),
      ('الإمارات', 15),
      ('مصر', 10),
      ('الكويت', 5),
      ('أخرى', 5),
    ];

    return Column(
      children: regions.map((region) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingSmall,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  region.$1,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: region.$2 / 100,
                    backgroundColor: AppColors.primaryExtraLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              SizedBox(
                width: 40,
                child: Text(
                  '${region.$2}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
