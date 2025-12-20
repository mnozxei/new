import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/injection/injection.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../jobs/domain/entities/job_entity.dart';
import '../../../jobs/presentation/bloc/job_bloc.dart';

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
  List<JobEntity> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()..add(LoadCompanyJobs(companyId: widget.companyId)),
      child: BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
          if (state is CompanyJobsLoaded) {
            setState(() {
              _jobs = state.jobs;
              _isLoading = false;
            });
          }
          if (state is JobPublished || state is JobClosed || state is JobArchived) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم التحديث بنجاح'), backgroundColor: AppColors.success),
            );
            context.read<JobBloc>().add(LoadCompanyJobs(companyId: widget.companyId));
          }
        },
        builder: (context, state) {
          final isLoading = state is JobLoading || _isLoading;
          final activeJobs = _jobs.where((j) => j.status == JobStatus.published).toList();
          final draftJobs = _jobs.where((j) => j.status == JobStatus.draft).toList();
          final closedJobs = _jobs.where((j) => j.status == JobStatus.closed).toList();
          final archivedJobs = _jobs.where((j) => j.status == JobStatus.archived).toList();

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
                  onPressed: () => context.push('${RouteNames.postJob}?companyId=${widget.companyId}'),
                  tooltip: 'نشر وظيفة جديدة',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(text: 'نشطة (${activeJobs.length})'),
                  Tab(text: 'مسودة (${draftJobs.length})'),
                  Tab(text: 'مغلقة (${closedJobs.length})'),
                  Tab(text: 'مؤرشفة (${archivedJobs.length})'),
                ],
              ),
            ),
            body: Column(
              children: [
                _buildStatsRow(context),
                Expanded(
                  child: isLoading && _jobs.isEmpty
                      ? _buildLoadingSkeleton()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _JobsListView(jobs: activeJobs, companyId: widget.companyId, emptyMessage: 'لا توجد وظائف نشطة'),
                            _JobsListView(jobs: draftJobs, companyId: widget.companyId, emptyMessage: 'لا توجد مسودات'),
                            _JobsListView(jobs: closedJobs, companyId: widget.companyId, emptyMessage: 'لا توجد وظائف مغلقة'),
                            _JobsListView(jobs: archivedJobs, companyId: widget.companyId, emptyMessage: 'لا توجد وظائف مؤرشفة'),
                          ],
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.push('${RouteNames.postJob}?companyId=${widget.companyId}'),
              icon: const Icon(Iconsax.add),
              label: const Text('نشر وظيفة'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final activeCount = _jobs.where((j) => j.status == JobStatus.published).length;
    final totalApplications = _jobs.fold<int>(0, (sum, job) => sum + (job.applicationCount ?? 0));
    final totalViews = _jobs.fold<int>(0, (sum, job) => sum + (job.viewCount ?? 0));

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Row(
        children: [
          Expanded(child: _StatCard(icon: Iconsax.briefcase, label: 'وظائف نشطة', value: '$activeCount', color: AppColors.success)),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(child: _StatCard(icon: Iconsax.document, label: 'طلبات', value: '$totalApplications', color: AppColors.primary)),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(child: _StatCard(icon: Iconsax.eye, label: 'المشاهدات', value: _formatNumber(totalViews), color: AppColors.info)),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          height: 150,
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '$number';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _JobsListView extends StatelessWidget {
  const _JobsListView({required this.jobs, required this.companyId, required this.emptyMessage});
  final List<JobEntity> jobs;
  final String companyId;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Iconsax.briefcase, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(emptyMessage, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondaryLight)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<JobBloc>().add(LoadCompanyJobs(companyId: companyId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: jobs.length,
        itemBuilder: (context, index) => _JobCard(job: jobs[index], companyId: companyId),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.companyId});
  final JobEntity job;
  final String companyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spacingExtraSmall),
            Row(children: [
              _InfoBadge(icon: Iconsax.location, label: job.locationType?.label ?? job.location ?? 'غير محدد'),
              const SizedBox(width: AppConstants.spacingSmall),
              _InfoBadge(icon: Iconsax.clock, label: job.jobType?.label ?? 'غير محدد'),
            ]),
          ])),
          _StatusBadge(status: job.status ?? JobStatus.draft),
        ]),
        const Divider(height: AppConstants.spacingLarge),
        Row(children: [
          Expanded(child: Row(children: [
            const Icon(Iconsax.document, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('${job.applicationCount ?? 0} طلب', style: theme.textTheme.bodySmall),
          ])),
          Expanded(child: Row(children: [
            const Icon(Iconsax.eye, size: 16, color: AppColors.info),
            const SizedBox(width: 4),
            Text('${job.viewCount ?? 0} مشاهدة', style: theme.textTheme.bodySmall),
          ])),
          Text(_formatDate(job.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
        ]),
        const SizedBox(height: AppConstants.spacingMedium),
        Row(children: [
          if (job.status == JobStatus.published) ...[
            Expanded(child: OutlinedButton.icon(
              onPressed: () => context.push('${RouteNames.jobs}/${job.id}/applications'),
              icon: const Icon(Iconsax.document, size: 18),
              label: const Text('الطلبات'),
            )),
            const SizedBox(width: AppConstants.spacingSmall),
          ],
          if (job.status == JobStatus.draft) ...[
            Expanded(child: OutlinedButton.icon(
              onPressed: () => context.push('${RouteNames.jobs}/${job.id}/manage'),
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('تعديل'),
            )),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(child: FilledButton.icon(
              onPressed: () => _publishJob(context, job),
              icon: const Icon(Iconsax.send_1, size: 18),
              label: const Text('نشر'),
            )),
          ] else ...[
            Expanded(child: FilledButton.icon(
              onPressed: () => context.push('${RouteNames.jobs}/${job.id}/manage'),
              icon: const Icon(Iconsax.setting_2, size: 18),
              label: const Text('إدارة'),
            )),
          ],
          const SizedBox(width: AppConstants.spacingSmall),
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more),
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Row(children: [Icon(Iconsax.eye, size: 18), SizedBox(width: 8), Text('عرض')])),
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Iconsax.edit, size: 18), SizedBox(width: 8), Text('تعديل')])),
              if (job.status == JobStatus.published)
                const PopupMenuItem(value: 'close', child: Row(children: [Icon(Iconsax.close_circle, size: 18, color: AppColors.warning), SizedBox(width: 8), Text('إغلاق', style: TextStyle(color: AppColors.warning))])),
              if (job.status == JobStatus.closed)
                const PopupMenuItem(value: 'reopen', child: Row(children: [Icon(Iconsax.refresh, size: 18, color: AppColors.success), SizedBox(width: 8), Text('إعادة نشر', style: TextStyle(color: AppColors.success))])),
              const PopupMenuItem(value: 'archive', child: Row(children: [Icon(Iconsax.archive, size: 18, color: AppColors.info), SizedBox(width: 8), Text('أرشفة', style: TextStyle(color: AppColors.info))])),
            ],
          ),
        ]),
      ]),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'view': context.push('${RouteNames.jobs}/${job.id}'); break;
      case 'edit': context.push('${RouteNames.jobs}/${job.id}/manage'); break;
      case 'close':
        _showConfirmDialog(context, title: 'إغلاق الوظيفة', message: 'هل أنت متأكد من إغلاق هذه الوظيفة؟',
          onConfirm: () => context.read<JobBloc>().add(CloseJob(jobId: job.id)));
        break;
      case 'reopen': context.read<JobBloc>().add(PublishJob(jobId: job.id)); break;
      case 'archive':
        _showConfirmDialog(context, title: 'أرشفة الوظيفة', message: 'هل أنت متأكد من أرشفة هذه الوظيفة؟',
          onConfirm: () => context.read<JobBloc>().add(ArchiveJob(jobId: job.id)));
        break;
    }
  }

  void _publishJob(BuildContext context, JobEntity job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نشر الوظيفة'),
        content: const Text('هل أنت متأكد من نشر هذه الوظيفة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(onPressed: () { Navigator.pop(ctx); context.read<JobBloc>().add(PublishJob(jobId: job.id)); }, child: const Text('نشر')),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, {required String title, required String message, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(onPressed: () { Navigator.pop(ctx); onConfirm(); }, child: const Text('تأكيد')),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textSecondaryLight),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
    ]);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case JobStatus.draft: color = AppColors.warning; label = 'مسودة'; break;
      case JobStatus.published: color = AppColors.success; label = 'نشطة'; break;
      case JobStatus.closed: color = AppColors.textSecondaryLight; label = 'مغلقة'; break;
      case JobStatus.archived: color = AppColors.info; label = 'مؤرشفة'; break;
      case JobStatus.hidden: color = AppColors.error; label = 'مخفية'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSmall, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
