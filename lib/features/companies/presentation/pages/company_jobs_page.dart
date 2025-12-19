import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class CompanyJobsPage extends StatefulWidget {
  const CompanyJobsPage({
    super.key,
    required this.companyId,
  });

  final String companyId;

  @override
  State<CompanyJobsPage> createState() => _CompanyJobsPageState();
}

class _CompanyJobsPageState extends State<CompanyJobsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'إدارة الوظائف',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle),
            onPressed: () => context.push(
              '${RouteNames.postJob}?companyId=${widget.companyId}',
            ),
            tooltip: 'نشر وظيفة جديدة',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نشطة'),
            Tab(text: 'مسودة'),
            Tab(text: 'مغلقة'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Row
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Iconsax.briefcase,
                    label: 'وظائف نشطة',
                    value: '8',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: _StatCard(
                    icon: Iconsax.document,
                    label: 'طلبات جديدة',
                    value: '45',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: _StatCard(
                    icon: Iconsax.eye,
                    label: 'المشاهدات',
                    value: '1.2K',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),

          // Jobs List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _JobsListView(status: 'active', companyId: widget.companyId),
                _JobsListView(status: 'draft', companyId: widget.companyId),
                _JobsListView(status: 'closed', companyId: widget.companyId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '${RouteNames.postJob}?companyId=${widget.companyId}',
        ),
        icon: const Icon(Iconsax.add),
        label: const Text('نشر وظيفة'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JobsListView extends StatelessWidget {
  const _JobsListView({
    required this.status,
    required this.companyId,
  });

  final String status;
  final String companyId;

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final jobs = List.generate(
      status == 'active' ? 8 : status == 'draft' ? 2 : 5,
      (index) => _JobData(
        id: 'job_$index',
        title: index % 2 == 0 ? 'مطور Flutter' : 'مصمم UI/UX',
        location: index % 3 == 0 ? 'عن بعد' : 'الرياض',
        type: index % 2 == 0 ? 'دوام كامل' : 'دوام جزئي',
        applicationsCount: (index + 1) * 5,
        viewsCount: (index + 1) * 50,
        postedAt: DateTime.now().subtract(Duration(days: index * 3)),
        status: status,
      ),
    );

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.briefcase,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا توجد وظائف',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _JobCard(job: jobs[index], companyId: companyId);
      },
    );
  }
}

class _JobData {
  const _JobData({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.applicationsCount,
    required this.viewsCount,
    required this.postedAt,
    required this.status,
  });

  final String id;
  final String title;
  final String location;
  final String type;
  final int applicationsCount;
  final int viewsCount;
  final DateTime postedAt;
  final String status;
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.companyId,
  });

  final _JobData job;
  final String companyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Row(
                      children: [
                        _InfoBadge(
                          icon: Iconsax.location,
                          label: job.location,
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        _InfoBadge(
                          icon: Iconsax.clock,
                          label: job.type,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: job.status),
            ],
          ),

          const Divider(height: AppConstants.spacingLarge),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.document,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job.applicationsCount} طلب',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.eye,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job.viewsCount} مشاهدة',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(job.postedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Actions
          Row(
            children: [
              if (job.status == 'active') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('${RouteNames.jobs}/${job.id}/applications');
                    },
                    icon: const Icon(Iconsax.document, size: 18),
                    label: const Text('الطلبات'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
              ],
              if (job.status == 'draft') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Edit draft
                    },
                    icon: const Icon(Iconsax.edit, size: 18),
                    label: const Text('تعديل'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // TODO: Publish draft
                    },
                    icon: const Icon(Iconsax.send_1, size: 18),
                    label: const Text('نشر'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.push('${RouteNames.jobs}/${job.id}/manage');
                    },
                    icon: const Icon(Iconsax.setting_2, size: 18),
                    label: const Text('إدارة'),
                  ),
                ),
              ],
              const SizedBox(width: AppConstants.spacingSmall),
              PopupMenuButton<String>(
                icon: const Icon(Iconsax.more),
                onSelected: (value) => _handleAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Iconsax.eye, size: 18),
                        SizedBox(width: 8),
                        Text('عرض'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Iconsax.edit, size: 18),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Iconsax.copy, size: 18),
                        SizedBox(width: 8),
                        Text('تكرار'),
                      ],
                    ),
                  ),
                  if (job.status == 'active')
                    const PopupMenuItem(
                      value: 'close',
                      child: Row(
                        children: [
                          Icon(Iconsax.close_circle, size: 18, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('إغلاق', style: TextStyle(color: AppColors.warning)),
                        ],
                      ),
                    ),
                  if (job.status == 'closed')
                    const PopupMenuItem(
                      value: 'reopen',
                      child: Row(
                        children: [
                          Icon(Iconsax.refresh, size: 18, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('إعادة فتح', style: TextStyle(color: AppColors.success)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Iconsax.trash, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        context.push('${RouteNames.jobs}/${job.id}');
        break;
      case 'edit':
        // TODO: Navigate to edit
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ الوظيفة')),
        );
        break;
      case 'close':
        _showConfirmDialog(
          context,
          title: 'إغلاق الوظيفة',
          message: 'هل أنت متأكد من إغلاق هذه الوظيفة؟',
          onConfirm: () {
            // TODO: Close job
          },
        );
        break;
      case 'reopen':
        // TODO: Reopen job
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة فتح الوظيفة')),
        );
        break;
      case 'delete':
        _showConfirmDialog(
          context,
          title: 'حذف الوظيفة',
          message: 'هل أنت متأكد من حذف هذه الوظيفة؟',
          isDestructive: true,
          onConfirm: () {
            // TODO: Delete job
          },
        );
        break;
    }
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = AppColors.success;
        label = 'نشطة';
        break;
      case 'draft':
        color = AppColors.warning;
        label = 'مسودة';
        break;
      case 'closed':
        color = AppColors.textSecondaryLight;
        label = 'مغلقة';
        break;
      default:
        color = AppColors.textSecondaryLight;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
