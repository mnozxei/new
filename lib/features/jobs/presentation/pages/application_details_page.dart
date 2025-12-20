import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/injection/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/job_bloc.dart';

class ApplicationDetailsPage extends StatelessWidget {
  const ApplicationDetailsPage({
    required this.applicationId,
    super.key,
  });

  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()..add(LoadApplicationDetails(applicationId: applicationId)),
      child: _ApplicationDetailsContent(applicationId: applicationId),
    );
  }
}

class _ApplicationDetailsContent extends StatelessWidget {
  const _ApplicationDetailsContent({required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is ApplicationWithdrawn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم سحب الطلب بنجاح')),
          );
          context.pop();
        } else if (state is JobError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is JobLoading) {
          return _buildLoadingState(context);
        }

        if (state is JobError) {
          return _buildErrorState(context, state.message);
        }

        if (state is ApplicationDetailsLoaded) {
          return _buildDetailsView(context, state.application);
        }

        return _buildLoadingState(context);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        title: 'تفاصيل الطلب',
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        title: 'تفاصيل الطلب',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.warning_2,
                size: 64,
                color: AppColors.error.withOpacity(0.5),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                'حدث خطأ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<JobBloc>().add(
                    LoadApplicationDetails(applicationId: applicationId),
                  );
                },
                icon: const Icon(Iconsax.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsView(BuildContext context, JobApplicationEntity application) {
    final theme = Theme.of(context);
    final job = application.job;

    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        title: 'تفاصيل الطلب',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _StatusCard(application: application),
            const SizedBox(height: AppConstants.spacingMedium),

            // Job Info
            GlassCard(
              intensity: GlassIntensity.light,
              onTap: job != null
                  ? () => context.push('/jobs/${job.id}')
                  : null,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      image: job?.company?.logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(job!.company!.logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: job?.company?.logoUrl == null
                        ? Center(
                            child: Text(
                              job?.company?.name.isNotEmpty == true
                                  ? job!.company!.name[0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job?.title ?? 'وظيفة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                job?.company?.name ?? 'شركة',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (job?.company?.isVerified == true) ...[
                              const SizedBox(width: AppConstants.spacingExtraSmall),
                              const CompanyVerifiedBadge(
                                isVerified: true,
                                size: VerifiedBadgeSize.small,
                              ),
                            ],
                          ],
                        ),
                        if (job?.city != null || job?.location != null)
                          Row(
                            children: [
                              const Icon(
                                Iconsax.location,
                                size: 14,
                                color: AppColors.textTertiaryLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                job?.city ?? job?.location ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_left_2, color: AppColors.textTertiaryLight),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Application Timeline
            _TimelineSection(application: application),

            const SizedBox(height: AppConstants.spacingMedium),

            // Application Details
            GlassPanel(
              title: 'تفاصيل الطلب',
              intensity: GlassIntensity.light,
              child: Column(
                children: [
                  _DetailRow(
                    label: 'تاريخ التقديم',
                    value: _formatDate(application.createdAt),
                  ),
                  if (application.expectedSalary != null)
                    _DetailRow(
                      label: 'الراتب المتوقع',
                      value: '${application.expectedSalary!.toStringAsFixed(0)} ر.س',
                    ),
                  if (application.availabilityDate != null)
                    _DetailRow(
                      label: 'تاريخ الإتاحة',
                      value: _formatDate(application.availabilityDate!),
                    ),
                  if (application.interviewDate != null)
                    _DetailRow(
                      label: 'موعد المقابلة',
                      value: _formatDate(application.interviewDate!),
                      valueColor: AppColors.info,
                    ),
                  if (application.offeredSalary != null)
                    _DetailRow(
                      label: 'الراتب المعروض',
                      value: '${application.offeredSalary!.toStringAsFixed(0)} ر.س',
                      valueColor: AppColors.success,
                    ),
                ],
              ),
            ),

            if (application.coverLetter != null && application.coverLetter!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingMedium),
              GlassPanel(
                title: 'رسالة التقديم',
                intensity: GlassIntensity.light,
                child: Text(
                  application.coverLetter!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
            ],

            if (application.resumeUrl != null) ...[
              const SizedBox(height: AppConstants.spacingMedium),
              GlassCard(
                intensity: GlassIntensity.light,
                onTap: () => _openResume(application.resumeUrl!),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingSmall),
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      ),
                      child: const Icon(Iconsax.document, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السيرة الذاتية',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'اضغط لعرض الملف',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.document_download, color: AppColors.primary),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingLarge),

            // Actions
            if (application.status == ApplicationStatus.pending ||
                application.status == ApplicationStatus.reviewing)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showWithdrawDialog(context, application),
                  icon: const Icon(Iconsax.logout),
                  label: const Text('سحب الطلب'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),

            if (application.status == ApplicationStatus.offered) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showWithdrawDialog(context, application),
                      child: const Text('رفض العرض'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Accept offer
                      },
                      child: const Text('قبول العرض'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppConstants.spacingLarge),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, JobApplicationEntity application) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('سحب الطلب'),
        content: const Text('هل أنت متأكد من رغبتك في سحب طلبك؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<JobBloc>().add(
                WithdrawApplication(applicationId: application.id),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('سحب الطلب'),
          ),
        ],
      ),
    );
  }

  Future<void> _openResume(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.application});

  final JobApplicationEntity application;

  Color _getStatusColor() {
    switch (application.status) {
      case ApplicationStatus.pending:
        return AppColors.warning;
      case ApplicationStatus.reviewing:
        return AppColors.info;
      case ApplicationStatus.shortlisted:
        return AppColors.primary;
      case ApplicationStatus.interview:
        return AppColors.secondary;
      case ApplicationStatus.offered:
        return AppColors.success;
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.withdrawn:
        return AppColors.textTertiaryLight;
    }
  }

  IconData _getStatusIcon() {
    switch (application.status) {
      case ApplicationStatus.pending:
        return Iconsax.clock;
      case ApplicationStatus.reviewing:
        return Iconsax.document;
      case ApplicationStatus.shortlisted:
        return Iconsax.star;
      case ApplicationStatus.interview:
        return Iconsax.calendar;
      case ApplicationStatus.offered:
        return Iconsax.gift;
      case ApplicationStatus.accepted:
        return Iconsax.tick_circle;
      case ApplicationStatus.rejected:
        return Iconsax.close_circle;
      case ApplicationStatus.withdrawn:
        return Iconsax.logout;
    }
  }

  String _getStatusDescription() {
    switch (application.status) {
      case ApplicationStatus.pending:
        return 'طلبك قيد الانتظار وسيتم مراجعته قريباً';
      case ApplicationStatus.reviewing:
        return 'يتم مراجعة طلبك حالياً من قبل فريق التوظيف';
      case ApplicationStatus.shortlisted:
        return 'تهانينا! تم اختيارك ضمن القائمة المختصرة';
      case ApplicationStatus.interview:
        return 'تم جدولة مقابلة معك، يرجى الاستعداد';
      case ApplicationStatus.offered:
        return 'مبروك! لقد تلقيت عرض عمل';
      case ApplicationStatus.accepted:
        return 'تم قبولك في الوظيفة';
      case ApplicationStatus.rejected:
        return 'نأسف، لم يتم قبول طلبك';
      case ApplicationStatus.withdrawn:
        return 'تم سحب طلبك';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(_getStatusIcon(), color: statusColor, size: 40),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            application.status.label,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            _getStatusDescription(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.application});

  final JobApplicationEntity application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define timeline steps based on application status
    final steps = [
      _TimelineStep(
        title: 'تم التقديم',
        date: application.createdAt,
        isCompleted: true,
        isActive: application.status == ApplicationStatus.pending,
      ),
      _TimelineStep(
        title: 'قيد المراجعة',
        date: application.status.index >= ApplicationStatus.reviewing.index
            ? application.updatedAt
            : null,
        isCompleted: application.status.index >= ApplicationStatus.reviewing.index,
        isActive: application.status == ApplicationStatus.reviewing,
      ),
      _TimelineStep(
        title: 'القائمة المختصرة',
        date: application.status.index >= ApplicationStatus.shortlisted.index
            ? application.updatedAt
            : null,
        isCompleted: application.status.index >= ApplicationStatus.shortlisted.index,
        isActive: application.status == ApplicationStatus.shortlisted,
      ),
      if (application.status == ApplicationStatus.interview ||
          application.interviewDate != null)
        _TimelineStep(
          title: 'المقابلة',
          date: application.interviewDate ?? application.updatedAt,
          isCompleted: application.status.index >= ApplicationStatus.interview.index,
          isActive: application.status == ApplicationStatus.interview,
        ),
      if (application.status == ApplicationStatus.offered ||
          application.status == ApplicationStatus.accepted)
        _TimelineStep(
          title: 'العرض',
          date: application.updatedAt,
          isCompleted: application.status.index >= ApplicationStatus.offered.index,
          isActive: application.status == ApplicationStatus.offered,
        ),
      if (application.status == ApplicationStatus.accepted)
        _TimelineStep(
          title: 'تم القبول',
          date: application.updatedAt,
          isCompleted: true,
          isActive: true,
        ),
      if (application.status == ApplicationStatus.rejected)
        _TimelineStep(
          title: 'مرفوض',
          date: application.updatedAt,
          isCompleted: true,
          isActive: true,
          isError: true,
        ),
    ];

    return GlassPanel(
      title: 'سجل الطلب',
      intensity: GlassIntensity.light,
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: step.isError
                          ? AppColors.error
                          : (step.isCompleted ? AppColors.primary : AppColors.dividerLight),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.isError
                          ? Icons.close
                          : (step.isCompleted ? Icons.check : Icons.circle),
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: step.isCompleted
                          ? AppColors.primary
                          : AppColors.dividerLight,
                    ),
                ],
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppConstants.spacingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: step.isActive ? FontWeight.bold : FontWeight.normal,
                          color: step.isError
                              ? AppColors.error
                              : (step.isActive ? AppColors.primary : null),
                        ),
                      ),
                      if (step.date != null)
                        Text(
                          '${step.date!.day}/${step.date!.month}/${step.date!.year}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.title,
    this.date,
    required this.isCompleted,
    required this.isActive,
    this.isError = false,
  });

  final String title;
  final DateTime? date;
  final bool isCompleted;
  final bool isActive;
  final bool isError;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
