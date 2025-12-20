import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/injection/injection.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../bloc/job_bloc.dart';

class ManageJobPage extends StatefulWidget {
  const ManageJobPage({
    required this.jobId,
    super.key,
  });

  final String jobId;

  @override
  State<ManageJobPage> createState() => _ManageJobPageState();
}

class _ManageJobPageState extends State<ManageJobPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _requirementsController;
  late final TextEditingController _responsibilitiesController;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late final TextEditingController _vacancyCountController;

  bool _isEditing = false;
  bool _hasChanges = false;
  JobEntity? _job;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _requirementsController = TextEditingController();
    _responsibilitiesController = TextEditingController();
    _salaryMinController = TextEditingController();
    _salaryMaxController = TextEditingController();
    _vacancyCountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _responsibilitiesController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _vacancyCountController.dispose();
    super.dispose();
  }

  void _populateFields(JobEntity job) {
    if (!_isEditing) {
      _titleController.text = job.title;
      _descriptionController.text = job.description;
      _requirementsController.text = job.requirements ?? '';
      _responsibilitiesController.text = job.responsibilities ?? '';
      _salaryMinController.text = job.salaryMin?.toStringAsFixed(0) ?? '';
      _salaryMaxController.text = job.salaryMax?.toStringAsFixed(0) ?? '';
      _vacancyCountController.text = job.vacancyCount.toString();
    }
  }

  void _toggleEditing() {
    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()..add(LoadJobDetails(jobId: widget.jobId)),
      child: BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
          if (state is JobDetailsLoaded) {
            setState(() {
              _job = state.job;
              _isLoading = false;
            });
            _populateFields(state.job);
          }
          if (state is JobUpdated || state is JobPublished || state is JobClosed || state is JobArchived) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم التحديث بنجاح'), backgroundColor: AppColors.success),
            );
            context.read<JobBloc>().add(LoadJobDetails(jobId: widget.jobId));
          }
        },
        builder: (context, state) {
          final isLoading = state is JobLoading || _isLoading;

          return Scaffold(
            appBar: GlassAppBar(
              title: 'إدارة الوظيفة',
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_right_1),
                onPressed: () {
                  if (_hasChanges) {
                    _showDiscardDialog(context);
                  } else {
                    context.pop();
                  }
                },
              ),
              actions: [
                if (_isEditing)
                  TextButton(
                    onPressed: isLoading ? null : () => _saveChanges(context, _job),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('حفظ'),
                  )
                else if (_job != null)
                  IconButton(icon: const Icon(Iconsax.edit), onPressed: _toggleEditing, tooltip: 'تعديل'),
              ],
            ),
            body: isLoading && _job == null
                ? const Center(child: CircularProgressIndicator())
                : _job == null
                    ? _buildErrorState(context)
                    : _buildContent(context, _job!, isLoading),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Iconsax.warning_2, size: 64, color: AppColors.error.withValues(alpha: 0.5)),
        const SizedBox(height: AppConstants.spacingMedium),
        Text('لم يتم العثور على الوظيفة', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppConstants.spacingMedium),
        ElevatedButton(onPressed: () => context.pop(), child: const Text('العودة')),
      ]),
    );
  }

  Widget _buildContent(BuildContext context, JobEntity job, bool isLoading) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Status Panel
            GlassPanel(
              title: 'حالة الوظيفة',
              intensity: GlassIntensity.light,
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('الحالة', style: theme.textTheme.titleSmall),
                  _StatusChip(status: job.status),
                ]),
                const SizedBox(height: AppConstants.spacingMedium),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('عدد الطلبات', style: theme.textTheme.bodyMedium),
                  Text('${job.applicationCount}', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                ]),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('المشاهدات', style: theme.textTheme.bodyMedium),
                  Text('${job.viewCount}', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.info)),
                ]),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('الشواغر', style: theme.textTheme.bodyMedium),
                  Text('${job.vacancyCount}', style: theme.textTheme.titleMedium),
                ]),
                if (job.applicationDeadline != null) ...[
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('الموعد النهائي', style: theme.textTheme.bodyMedium),
                    Text(
                      _formatDate(job.applicationDeadline!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: job.applicationDeadline!.isBefore(DateTime.now()) ? AppColors.error : null,
                      ),
                    ),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // Quick Actions
            GlassPanel(
              title: 'إجراءات سريعة',
              intensity: GlassIntensity.light,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('${RouteNames.jobs}/${widget.jobId}/applications'),
                  icon: const Icon(Iconsax.people),
                  label: Text('عرض الطلبات (${job.applicationCount})'),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                if (job.status == JobStatus.draft)
                  FilledButton.icon(
                    onPressed: isLoading ? null : () => _publishJob(context, job),
                    icon: const Icon(Iconsax.send_1),
                    label: const Text('نشر الوظيفة'),
                  )
                else if (job.status == JobStatus.published)
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : () => _closeJob(context, job),
                    icon: const Icon(Iconsax.pause_circle),
                    label: const Text('إغلاق الوظيفة'),
                  )
                else if (job.status == JobStatus.closed)
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : () => _publishJob(context, job),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة نشر'),
                  ),
                const SizedBox(height: AppConstants.spacingSmall),
                if (job.status != JobStatus.archived)
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : () => _archiveJob(context, job),
                    icon: Icon(Iconsax.archive, color: isDark ? AppColors.warningLight : AppColors.warning),
                    label: Text('أرشفة الوظيفة', style: TextStyle(color: isDark ? AppColors.warningLight : AppColors.warning)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: isDark ? AppColors.warningLight : AppColors.warning)),
                  ),
              ]),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // Edit Panel
            GlassPanel(
              title: 'تفاصيل الوظيفة',
              intensity: GlassIntensity.light,
              trailing: _isEditing
                  ? TextButton(onPressed: () { _populateFields(job); setState(() { _isEditing = false; _hasChanges = false; }); }, child: const Text('إلغاء'))
                  : null,
              child: Column(children: [
                GlassTextField(label: 'عنوان الوظيفة', controller: _titleController, enabled: _isEditing, onChanged: (_) => _markChanged()),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassTextField(label: 'وصف الوظيفة', controller: _descriptionController, maxLines: 5, enabled: _isEditing, onChanged: (_) => _markChanged()),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassTextField(label: 'المتطلبات', controller: _requirementsController, maxLines: 4, enabled: _isEditing, onChanged: (_) => _markChanged()),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassTextField(label: 'المسؤوليات', controller: _responsibilitiesController, maxLines: 4, enabled: _isEditing, onChanged: (_) => _markChanged()),
                const SizedBox(height: AppConstants.spacingMedium),
                Row(children: [
                  Expanded(child: GlassTextField(label: 'الحد الأدنى للراتب', controller: _salaryMinController, keyboardType: TextInputType.number, enabled: _isEditing, onChanged: (_) => _markChanged())),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(child: GlassTextField(label: 'الحد الأقصى للراتب', controller: _salaryMaxController, keyboardType: TextInputType.number, enabled: _isEditing, onChanged: (_) => _markChanged())),
                ]),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassTextField(label: 'عدد الشواغر', controller: _vacancyCountController, keyboardType: TextInputType.number, enabled: _isEditing, onChanged: (_) => _markChanged()),
              ]),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
          ]),
        ),
      ),
    );
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _saveChanges(BuildContext context, JobEntity? job) {
    if (job == null) return;
    context.read<JobBloc>().add(UpdateJob(
      jobId: widget.jobId,
      params: UpdateJobParams(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text.trim().isNotEmpty ? _requirementsController.text.trim() : null,
        responsibilities: _responsibilitiesController.text.trim().isNotEmpty ? _responsibilitiesController.text.trim() : null,
        salaryMin: double.tryParse(_salaryMinController.text),
        salaryMax: double.tryParse(_salaryMaxController.text),
        vacancyCount: int.tryParse(_vacancyCountController.text),
      ),
    ));
    setState(() { _isEditing = false; _hasChanges = false; });
  }

  void _publishJob(BuildContext context, JobEntity job) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('نشر الوظيفة'),
      content: const Text('هل أنت متأكد من نشر هذه الوظيفة؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(onPressed: () { Navigator.pop(ctx); context.read<JobBloc>().add(PublishJob(jobId: job.id)); }, child: const Text('نشر')),
      ],
    ));
  }

  void _closeJob(BuildContext context, JobEntity job) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('إغلاق الوظيفة'),
      content: const Text('هل أنت متأكد من إغلاق هذه الوظيفة؟ لن يتمكن المتقدمون الجدد من التقديم.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(onPressed: () { Navigator.pop(ctx); context.read<JobBloc>().add(CloseJob(jobId: job.id)); }, style: FilledButton.styleFrom(backgroundColor: AppColors.warning), child: const Text('إغلاق')),
      ],
    ));
  }

  void _archiveJob(BuildContext context, JobEntity job) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('أرشفة الوظيفة'),
      content: const Text('هل أنت متأكد من أرشفة هذه الوظيفة؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(onPressed: () { Navigator.pop(ctx); context.read<JobBloc>().add(ArchiveJob(jobId: job.id)); }, style: FilledButton.styleFrom(backgroundColor: AppColors.warning), child: const Text('أرشفة')),
      ],
    ));
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('تجاهل التغييرات'),
      content: const Text('لديك تغييرات غير محفوظة. هل تريد تجاهلها؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('متابعة التعديل')),
        FilledButton(onPressed: () { Navigator.pop(ctx); context.pop(); }, style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: const Text('تجاهل')),
      ],
    ));
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case JobStatus.draft: color = AppColors.warning; label = 'مسودة'; break;
      case JobStatus.published: color = AppColors.success; label = 'منشورة'; break;
      case JobStatus.closed: color = AppColors.textSecondaryLight; label = 'مغلقة'; break;
      case JobStatus.archived: color = AppColors.info; label = 'مؤرشفة'; break;
      case JobStatus.hidden: color = AppColors.error; label = 'مخفية'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSmall, vertical: AppConstants.spacingExtraSmall),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
