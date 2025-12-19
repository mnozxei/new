import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/services/impressions_service.dart';
import '../bloc/instructor_bloc.dart';

class CourseAnalyticsPage extends StatefulWidget {
  const CourseAnalyticsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<CourseAnalyticsPage> createState() => _CourseAnalyticsPageState();
}

class _CourseAnalyticsPageState extends State<CourseAnalyticsPage> {
  final ImpressionsService _impressionsService = ImpressionsService();
  ImpressionStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _impressionsService.getStats(
        entityType: ImpressionEntityType.course,
        entityId: widget.courseId,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileCourseAnalyticsPage(
        courseId: widget.courseId,
        stats: _stats,
        isLoading: _isLoading,
        onRefresh: _loadAnalytics,
      ),
      desktop: _DesktopCourseAnalyticsPage(
        courseId: widget.courseId,
        stats: _stats,
        isLoading: _isLoading,
        onRefresh: _loadAnalytics,
      ),
    );
  }
}

class _MobileCourseAnalyticsPage extends StatelessWidget {
  const _MobileCourseAnalyticsPage({
    required this.courseId,
    required this.stats,
    required this.isLoading,
    required this.onRefresh,
  });

  final String courseId;
  final ImpressionStats? stats;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'تحليلات الدورة',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: onRefresh,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(context),
                    const SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      'إحصائيات المشاهدات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    _buildViewsCard(context),
                    const SizedBox(height: AppConstants.spacingMedium),
                    _buildEnrollmentStats(context),
                    const SizedBox(height: AppConstants.spacingMedium),
                    _buildCompletionStats(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppConstants.spacingMedium,
      crossAxisSpacing: AppConstants.spacingMedium,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Iconsax.eye,
          title: 'المشاهدات',
          value: '${stats?.totalViews ?? 0}',
          color: AppColors.info,
        ),
        _StatCard(
          icon: Iconsax.people,
          title: 'المشاهدات الفريدة',
          value: '${stats?.uniqueViews ?? 0}',
          color: AppColors.success,
        ),
        _StatCard(
          icon: Iconsax.calendar,
          title: 'اليوم',
          value: '${stats?.todayViews ?? 0}',
          color: AppColors.warning,
        ),
        _StatCard(
          icon: Iconsax.chart_2,
          title: 'هذا الأسبوع',
          value: '${stats?.weekViews ?? 0}',
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildViewsCard(BuildContext context) {
    return GlassCard(
      intensity: GlassIntensity.light,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.chart, color: AppColors.info, size: 20),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                const Text('نظرة عامة على المشاهدات'),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            _ProgressItem(
              label: 'هذا الشهر',
              value: stats?.monthViews ?? 0,
              maxValue: (stats?.monthViews ?? 1) + 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            _ProgressItem(
              label: 'هذا الأسبوع',
              value: stats?.weekViews ?? 0,
              maxValue: (stats?.weekViews ?? 1) + 50,
              color: AppColors.success,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            _ProgressItem(
              label: 'اليوم',
              value: stats?.todayViews ?? 0,
              maxValue: (stats?.todayViews ?? 1) + 20,
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentStats(BuildContext context) {
    return GlassCard(
      intensity: GlassIntensity.light,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.user_add, color: AppColors.success, size: 20),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                const Text('إحصائيات التسجيل'),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(label: 'إجمالي التسجيلات', value: '0'),
                _StatItem(label: 'التسجيلات النشطة', value: '0'),
                _StatItem(label: 'المكتملة', value: '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStats(BuildContext context) {
    return GlassCard(
      intensity: GlassIntensity.light,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.medal_star, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                const Text('معدل الإكمال'),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(label: 'الشهادات الصادرة', value: '0'),
                _StatItem(label: 'معدل الإكمال', value: '0%'),
                _StatItem(label: 'متوسط التقييم', value: '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopCourseAnalyticsPage extends StatelessWidget {
  const _DesktopCourseAnalyticsPage({
    required this.courseId,
    required this.stats,
    required this.isLoading,
    required this.onRefresh,
  });

  final String courseId;
  final ImpressionStats? stats;
  final bool isLoading;
  final VoidCallback onRefresh;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تحليلات الدورة',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Iconsax.refresh),
                  label: const Text('تحديث'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDesktopStatsRow(context),
                            const SizedBox(height: AppConstants.spacingLarge),
                            _MobileCourseAnalyticsPage(
                              courseId: courseId,
                              stats: stats,
                              isLoading: false,
                              onRefresh: onRefresh,
                            )._buildViewsCard(context),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingLarge),
                    Expanded(
                      child: Column(
                        children: [
                          _MobileCourseAnalyticsPage(
                            courseId: courseId,
                            stats: stats,
                            isLoading: false,
                            onRefresh: onRefresh,
                          )._buildEnrollmentStats(context),
                          const SizedBox(height: AppConstants.spacingMedium),
                          _MobileCourseAnalyticsPage(
                            courseId: courseId,
                            stats: stats,
                            isLoading: false,
                            onRefresh: onRefresh,
                          )._buildCompletionStats(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Iconsax.eye,
            title: 'المشاهدات',
            value: '${stats?.totalViews ?? 0}',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _StatCard(
            icon: Iconsax.people,
            title: 'المشاهدات الفريدة',
            value: '${stats?.uniqueViews ?? 0}',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _StatCard(
            icon: Iconsax.calendar,
            title: 'اليوم',
            value: '${stats?.todayViews ?? 0}',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _StatCard(
            icon: Iconsax.chart_2,
            title: 'هذا الأسبوع',
            value: '${stats?.weekViews ?? 0}',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = maxValue > 0 ? value / maxValue : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text('$value', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
