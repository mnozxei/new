import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/injection/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/job_bloc.dart';

class JobApplicationsPage extends StatefulWidget {
  const JobApplicationsPage({
    required this.jobId,
    super.key,
  });

  final String jobId;

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ApplicationStatus? _selectedStatus;
  List<JobApplicationEntity> _applications = [];
  JobEntity? _job;
  bool _isLoading = true;

  final List<ApplicationStatus> _statuses = [
    ApplicationStatus.pending,
    ApplicationStatus.reviewing,
    ApplicationStatus.shortlisted,
    ApplicationStatus.interview,
    ApplicationStatus.offered,
    ApplicationStatus.accepted,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()
        ..add(LoadJobDetails(jobId: widget.jobId))
        ..add(LoadJobApplications(jobId: widget.jobId)),
      child: BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is JobDetailsLoaded) {
            setState(() => _job = state.job);
          }
          if (state is JobApplicationsLoaded) {
            setState(() {
              _applications = state.applications;
              _isLoading = false;
            });
          }
          if (state is ApplicationStatusUpdated || state is InterviewScheduled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الحالة بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<JobBloc>().add(LoadJobApplications(jobId: widget.jobId));
          }
        },
        builder: (context, state) {
          final isLoading = state is JobLoading || _isLoading;

          return Scaffold(
            appBar: GlassAppBar(
              title: _job?.title ?? 'الطلبات',
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_right_1),
                onPressed: () => context.pop(),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'القائمة', icon: Icon(Iconsax.menu, size: 18)),
                  Tab(text: 'Pipeline', icon: Icon(Iconsax.hierarchy_square, size: 18)),
                ],
              ),
            ),
            body: Column(
              children: [
                _buildStatsBar(context),
                _buildFilterChips(context),
                Expanded(
                  child: isLoading && _applications.isEmpty
                      ? _buildLoadingSkeleton()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildListView(context),
                            _buildPipelineView(context),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    final theme = Theme.of(context);

    final pending = _applications.where((a) => a.status == ApplicationStatus.pending).length;
    final reviewing = _applications.where((a) => a.status == ApplicationStatus.reviewing).length;
    final shortlisted = _applications.where((a) => a.status == ApplicationStatus.shortlisted).length;
    final interviewed = _applications.where((a) =>
        a.status == ApplicationStatus.interview ||
        a.status == ApplicationStatus.offered ||
        a.status == ApplicationStatus.accepted).length;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Row(
        children: [
          _StatBadge(label: 'جديد', count: pending, color: AppColors.info),
          const SizedBox(width: AppConstants.spacingSmall),
          _StatBadge(label: 'قيد المراجعة', count: reviewing, color: AppColors.warning),
          const SizedBox(width: AppConstants.spacingSmall),
          _StatBadge(label: 'مختارون', count: shortlisted, color: AppColors.success),
          const SizedBox(width: AppConstants.spacingSmall),
          _StatBadge(label: 'مقابلات', count: interviewed, color: AppColors.primary),
          const Spacer(),
          Text('الإجمالي: ${_applications.length}', style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
      child: Row(
        children: [
          FilterChip(
            label: const Text('الكل'),
            selected: _selectedStatus == null,
            onSelected: (_) => setState(() => _selectedStatus = null),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          ..._statuses.map((status) => Padding(
            padding: const EdgeInsets.only(left: AppConstants.spacingSmall),
            child: FilterChip(
              label: Text(_getStatusLabel(status)),
              selected: _selectedStatus == status,
              onSelected: (_) => setState(() => _selectedStatus = status),
              backgroundColor: _getStatusColor(status).withValues(alpha: 0.1),
              selectedColor: _getStatusColor(status).withValues(alpha: 0.3),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    final applications = _selectedStatus == null
        ? _applications
        : _applications.where((a) => a.status == _selectedStatus).toList();

    if (applications.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return _ApplicationCard(
          application: applications[index],
          onStatusChange: (newStatus) => _changeStatus(context, applications[index], newStatus),
          onScheduleInterview: () => _scheduleInterview(context, applications[index]),
        );
      },
    );
  }

  Widget _buildPipelineView(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PipelineColumn(
            title: 'جديد',
            status: ApplicationStatus.pending,
            applications: _applications.where((a) => a.status == ApplicationStatus.pending).toList(),
            color: AppColors.info,
            onStatusChange: (app, status) => _changeStatus(context, app, status),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          _PipelineColumn(
            title: 'قيد المراجعة',
            status: ApplicationStatus.reviewing,
            applications: _applications.where((a) => a.status == ApplicationStatus.reviewing).toList(),
            color: AppColors.warning,
            onStatusChange: (app, status) => _changeStatus(context, app, status),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          _PipelineColumn(
            title: 'المختارون',
            status: ApplicationStatus.shortlisted,
            applications: _applications.where((a) => a.status == ApplicationStatus.shortlisted).toList(),
            color: AppColors.success,
            onStatusChange: (app, status) => _changeStatus(context, app, status),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          _PipelineColumn(
            title: 'المقابلات',
            status: ApplicationStatus.interview,
            applications: _applications.where((a) => a.status == ApplicationStatus.interview).toList(),
            color: AppColors.primary,
            onStatusChange: (app, status) => _changeStatus(context, app, status),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          _PipelineColumn(
            title: 'العروض',
            status: ApplicationStatus.offered,
            applications: _applications.where((a) => a.status == ApplicationStatus.offered).toList(),
            color: AppColors.primaryDark,
            onStatusChange: (app, status) => _changeStatus(context, app, status),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          _PipelineColumn(
            title: 'تم القبول',
            status: ApplicationStatus.accepted,
            applications: _applications.where((a) => a.status == ApplicationStatus.accepted).toList(),
            color: AppColors.successDark,
            onStatusChange: (app, status) => _changeStatus(context, app, status),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          _PipelineColumn(
            title: 'مرفوضون',
            status: ApplicationStatus.rejected,
            applications: _applications.where((a) => a.status == ApplicationStatus.rejected).toList(),
            color: AppColors.error,
            onStatusChange: (app, status) => _changeStatus(context, app, status),
          ),
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
          height: 120,
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            _selectedStatus != null ? 'لا توجد طلبات بهذه الحالة' : 'لا توجد طلبات بعد',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _changeStatus(BuildContext context, JobApplicationEntity application, ApplicationStatus newStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير الحالة'),
        content: Text('هل تريد تغيير حالة الطلب إلى "${_getStatusLabel(newStatus)}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<JobBloc>().add(UpdateApplicationStatus(
                applicationId: application.id,
                status: newStatus,
              ));
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _scheduleInterview(BuildContext context, JobApplicationEntity application) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('جدولة مقابلة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.calendar),
                title: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) setDialogState(() => selectedDate = date);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.clock),
                title: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime);
                  if (time != null) setDialogState(() => selectedTime = time);
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                final interviewDate = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  selectedTime.hour, selectedTime.minute,
                );
                context.read<JobBloc>().add(ScheduleInterview(
                  applicationId: application.id,
                  interviewDate: interviewDate,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                ));
              },
              child: const Text('جدولة'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending: return 'جديد';
      case ApplicationStatus.reviewing: return 'قيد المراجعة';
      case ApplicationStatus.shortlisted: return 'مختار';
      case ApplicationStatus.interview: return 'مقابلة';
      case ApplicationStatus.offered: return 'عرض';
      case ApplicationStatus.accepted: return 'مقبول';
      case ApplicationStatus.rejected: return 'مرفوض';
      case ApplicationStatus.withdrawn: return 'منسحب';
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending: return AppColors.info;
      case ApplicationStatus.reviewing: return AppColors.warning;
      case ApplicationStatus.shortlisted: return AppColors.success;
      case ApplicationStatus.interview: return AppColors.primary;
      case ApplicationStatus.offered: return AppColors.primaryDark;
      case ApplicationStatus.accepted: return AppColors.successDark;
      case ApplicationStatus.rejected: return AppColors.error;
      case ApplicationStatus.withdrawn: return AppColors.textSecondaryLight;
    }
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSmall, vertical: AppConstants.spacingExtraSmall),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application, required this.onStatusChange, required this.onScheduleInterview});
  final JobApplicationEntity application;
  final Function(ApplicationStatus) onStatusChange;
  final VoidCallback onScheduleInterview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      intensity: GlassIntensity.light,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLighter,
            backgroundImage: application.applicant?.avatarUrl != null ? NetworkImage(application.applicant!.avatarUrl!) : null,
            child: application.applicant?.avatarUrl == null
                ? Text((application.applicant?.fullName ?? 'U')[0].toUpperCase(), style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(application.applicant?.fullName ?? 'مستخدم', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (application.applicant?.email != null)
              Text(application.applicant!.email!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
          ])),
          _StatusChip(status: application.status),
        ]),
        const SizedBox(height: AppConstants.spacingMedium),
        Row(children: [
          if (application.expectedSalary != null) ...[
            Icon(Iconsax.money, size: 14, color: AppColors.textSecondaryLight),
            const SizedBox(width: 4),
            Text('${application.expectedSalary} ر.س', style: theme.textTheme.bodySmall),
            const SizedBox(width: AppConstants.spacingMedium),
          ],
          Icon(Iconsax.calendar, size: 14, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(_formatDate(application.createdAt), style: theme.textTheme.bodySmall),
        ]),
        if (application.interviewDate != null) ...[
          const SizedBox(height: AppConstants.spacingSmall),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Iconsax.video, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('مقابلة: ${_formatDateTime(application.interviewDate!)}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
        const Divider(height: AppConstants.spacingLarge),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Iconsax.document, size: 16), label: const Text('السيرة'))),
          const SizedBox(width: AppConstants.spacingSmall),
          if (application.status == ApplicationStatus.shortlisted)
            Expanded(child: FilledButton.icon(onPressed: onScheduleInterview, icon: const Icon(Iconsax.video, size: 16), label: const Text('مقابلة')))
          else
            Expanded(
              child: PopupMenuButton<ApplicationStatus>(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Iconsax.arrow_down, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('تغيير الحالة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ]),
                ),
                onSelected: onStatusChange,
                itemBuilder: (context) => [
                  if (application.status != ApplicationStatus.reviewing) const PopupMenuItem(value: ApplicationStatus.reviewing, child: Text('قيد المراجعة')),
                  if (application.status != ApplicationStatus.shortlisted) const PopupMenuItem(value: ApplicationStatus.shortlisted, child: Text('اختيار للمقابلة')),
                  if (application.status != ApplicationStatus.offered) const PopupMenuItem(value: ApplicationStatus.offered, child: Text('تقديم عرض')),
                  if (application.status != ApplicationStatus.accepted) const PopupMenuItem(value: ApplicationStatus.accepted, child: Text('قبول')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: ApplicationStatus.rejected, child: Text('رفض', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ),
        ]),
      ]),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) => '${date.day}/${date.month} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSmall, vertical: AppConstants.spacingExtraSmall),
      decoration: BoxDecoration(color: _getColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
      child: Text(_getLabel(), style: TextStyle(color: _getColor(), fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Color _getColor() {
    switch (status) {
      case ApplicationStatus.pending: return AppColors.info;
      case ApplicationStatus.reviewing: return AppColors.warning;
      case ApplicationStatus.shortlisted: return AppColors.success;
      case ApplicationStatus.interview: return AppColors.primary;
      case ApplicationStatus.offered: return AppColors.primaryDark;
      case ApplicationStatus.accepted: return AppColors.successDark;
      case ApplicationStatus.rejected: return AppColors.error;
      case ApplicationStatus.withdrawn: return AppColors.textSecondaryLight;
    }
  }

  String _getLabel() {
    switch (status) {
      case ApplicationStatus.pending: return 'جديد';
      case ApplicationStatus.reviewing: return 'قيد المراجعة';
      case ApplicationStatus.shortlisted: return 'مختار';
      case ApplicationStatus.interview: return 'مقابلة';
      case ApplicationStatus.offered: return 'عرض';
      case ApplicationStatus.accepted: return 'مقبول';
      case ApplicationStatus.rejected: return 'مرفوض';
      case ApplicationStatus.withdrawn: return 'منسحب';
    }
  }
}

class _PipelineColumn extends StatelessWidget {
  const _PipelineColumn({required this.title, required this.status, required this.applications, required this.color, required this.onStatusChange});
  final String title;
  final ApplicationStatus status;
  final List<JobApplicationEntity> applications;
  final Color color;
  final Function(JobApplicationEntity, ApplicationStatus) onStatusChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusMedium))),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text('${applications.length}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ]),
        ),
        Expanded(
          child: applications.isEmpty
              ? Center(child: Text('لا يوجد', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingSmall),
                  itemCount: applications.length,
                  itemBuilder: (context, index) => _PipelineCard(
                    application: applications[index],
                    onMoveNext: () {
                      final nextStatus = _getNextStatus(status);
                      if (nextStatus != null) onStatusChange(applications[index], nextStatus);
                    },
                    onReject: () => onStatusChange(applications[index], ApplicationStatus.rejected),
                  ),
                ),
        ),
      ]),
    );
  }

  ApplicationStatus? _getNextStatus(ApplicationStatus current) {
    switch (current) {
      case ApplicationStatus.pending: return ApplicationStatus.reviewing;
      case ApplicationStatus.reviewing: return ApplicationStatus.shortlisted;
      case ApplicationStatus.shortlisted: return ApplicationStatus.interview;
      case ApplicationStatus.interview: return ApplicationStatus.offered;
      case ApplicationStatus.offered: return ApplicationStatus.accepted;
      default: return null;
    }
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({required this.application, required this.onMoveNext, required this.onReject});
  final JobApplicationEntity application;
  final VoidCallback onMoveNext;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      intensity: GlassIntensity.light,
      padding: const EdgeInsets.all(AppConstants.spacingSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLighter,
            backgroundImage: application.applicant?.avatarUrl != null ? NetworkImage(application.applicant!.avatarUrl!) : null,
            child: application.applicant?.avatarUrl == null
                ? Text((application.applicant?.fullName ?? 'U')[0].toUpperCase(), style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(child: Text(application.applicant?.fullName ?? 'مستخدم', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: AppConstants.spacingSmall),
        Row(children: [
          Expanded(
            child: InkWell(
              onTap: onMoveNext,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: const Icon(Iconsax.arrow_left, size: 16, color: AppColors.success),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: onReject,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: const Icon(Iconsax.close_circle, size: 16, color: AppColors.error),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
