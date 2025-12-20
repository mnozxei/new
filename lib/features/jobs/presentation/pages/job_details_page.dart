import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/injection/injection.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/impressions_service.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/job_bloc.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({
    required this.jobId,
    super.key,
  });

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()..add(LoadJobDetails(jobId: jobId)),
      child: _JobDetailsContent(jobId: jobId),
    );
  }
}

class _JobDetailsContent extends StatefulWidget {
  const _JobDetailsContent({required this.jobId});

  final String jobId;

  @override
  State<_JobDetailsContent> createState() => _JobDetailsContentState();
}

class _JobDetailsContentState extends State<_JobDetailsContent> {
  final ImpressionsService _impressionsService = ImpressionsService();

  @override
  void initState() {
    super.initState();
    _recordImpression();
  }

  void _recordImpression() {
    _impressionsService.recordImpression(
      entityType: ImpressionEntityType.job,
      entityId: widget.jobId,
    );
  }

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _handleSave(BuildContext context) {
    if (_isAuthenticated) {
      context.read<JobBloc>().add(ToggleSaveJob(jobId: widget.jobId));
    } else {
      LoginRequiredDialog.showForAction(context, 'save');
    }
  }

  void _handleShare(JobEntity job) {
    Share.share(
      'تقدم لوظيفة ${job.title} في ${job.company?.name ?? 'شركة'}\nhttps://tamadhub.com/jobs/${widget.jobId}',
      subject: 'فرصة عمل على تماد هب',
    );
  }

  void _handleApply(BuildContext context, JobDetailsLoaded state) {
    if (!_isAuthenticated) {
      LoginRequiredDialog.showForAction(context, 'apply');
      return;
    }

    if (state.hasApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لقد تقدمت لهذه الوظيفة مسبقاً')),
      );
      return;
    }

    if (!state.job.canApply) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.job.isExpired
                ? 'انتهى موعد التقديم'
                : 'لا تتوفر شواغر حالياً',
          ),
        ),
      );
      return;
    }

    context.pushNamed(RouteNames.jobApply, pathParameters: {'id': widget.jobId});
  }

  void _handleViewCompany(BuildContext context, String companyId) {
    context.push('/companies/$companyId');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobSaveToggled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isSaved ? 'تم حفظ الوظيفة' : 'تم إزالة الحفظ'),
              duration: const Duration(seconds: 1),
            ),
          );
          // Reload job details to update saved state
          context.read<JobBloc>().add(LoadJobDetails(jobId: widget.jobId));
        }
      },
      builder: (context, state) {
        if (state is JobLoading) {
          return _buildLoadingState(context);
        }

        if (state is JobError) {
          return _buildErrorState(context, state.message);
        }

        if (state is JobDetailsLoaded) {
          return ResponsiveLayout(
            mobile: _MobileJobDetails(
              job: state.job,
              hasApplied: state.hasApplied,
              isSaved: state.isSaved,
              myApplication: state.myApplication,
              onSave: () => _handleSave(context),
              onShare: () => _handleShare(state.job),
              onApply: () => _handleApply(context, state),
              onViewCompany: () => _handleViewCompany(context, state.job.companyId),
            ),
            desktop: _DesktopJobDetails(
              job: state.job,
              hasApplied: state.hasApplied,
              isSaved: state.isSaved,
              myApplication: state.myApplication,
              onSave: () => _handleSave(context),
              onShare: () => _handleShare(state.job),
              onApply: () => _handleApply(context, state),
              onViewCompany: () => _handleViewCompany(context, state.job.companyId),
            ),
          );
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
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            children: [
              _buildSkeletonHeader(),
              const SizedBox(height: AppConstants.spacingMedium),
              _buildSkeletonSection(),
              const SizedBox(height: AppConstants.spacingMedium),
              _buildSkeletonSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 14, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 180, height: 22, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingSmall),
                child: Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 120, height: 18, color: Colors.white),
          const SizedBox(height: AppConstants.spacingMedium),
          Container(width: double.infinity, height: 14, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 14, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 200, height: 14, color: Colors.white),
        ],
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
                  context.read<JobBloc>().add(LoadJobDetails(jobId: widget.jobId));
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
}

class _MobileJobDetails extends StatelessWidget {
  const _MobileJobDetails({
    required this.job,
    required this.hasApplied,
    required this.isSaved,
    this.myApplication,
    required this.onSave,
    required this.onShare,
    required this.onApply,
    required this.onViewCompany,
  });

  final JobEntity job;
  final bool hasApplied;
  final bool isSaved;
  final JobApplicationEntity? myApplication;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onApply;
  final VoidCallback onViewCompany;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(isSaved ? Iconsax.bookmark5 : Iconsax.bookmark),
            color: isSaved ? AppColors.primary : null,
            onPressed: onSave,
          ),
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: onShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _JobHeader(job: job),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasApplied && myApplication != null) ...[
                    _ApplicationStatusCard(application: myApplication!),
                    const SizedBox(height: AppConstants.spacingMedium),
                  ],
                  _JobInfoSection(job: job),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _JobDescriptionSection(job: job),
                  if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    _JobRequirementsSection(requirements: job.requirements!),
                  ],
                  if (job.responsibilities != null && job.responsibilities!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    _JobResponsibilitiesSection(responsibilities: job.responsibilities!),
                  ],
                  if (job.benefits.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    _JobBenefitsSection(benefits: job.benefits),
                  ],
                  if (job.skillsRequired.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    _JobSkillsSection(skills: job.skillsRequired),
                  ],
                  const SizedBox(height: AppConstants.spacingMedium),
                  _CompanySection(job: job, onViewCompany: onViewCompany),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _ApplyBottomSheet(
        job: job,
        hasApplied: hasApplied,
        onApply: onApply,
      ),
    );
  }
}

class _DesktopJobDetails extends StatelessWidget {
  const _DesktopJobDetails({
    required this.job,
    required this.hasApplied,
    required this.isSaved,
    this.myApplication,
    required this.onSave,
    required this.onShare,
    required this.onApply,
    required this.onViewCompany,
  });

  final JobEntity job;
  final bool hasApplied;
  final bool isSaved;
  final JobApplicationEntity? myApplication;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onApply;
  final VoidCallback onViewCompany;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        title: 'تفاصيل الوظيفة',
        actions: [
          IconButton(
            icon: Icon(isSaved ? Iconsax.bookmark5 : Iconsax.bookmark),
            color: isSaved ? AppColors.primary : null,
            onPressed: onSave,
          ),
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: onShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _JobHeader(job: job),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _JobDescriptionSection(job: job),
                      if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacingMedium),
                        _JobRequirementsSection(requirements: job.requirements!),
                      ],
                      if (job.responsibilities != null && job.responsibilities!.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacingMedium),
                        _JobResponsibilitiesSection(responsibilities: job.responsibilities!),
                      ],
                      if (job.benefits.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacingMedium),
                        _JobBenefitsSection(benefits: job.benefits),
                      ],
                      if (job.skillsRequired.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacingMedium),
                        _JobSkillsSection(skills: job.skillsRequired),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingLarge),
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      if (hasApplied && myApplication != null) ...[
                        _ApplicationStatusCard(application: myApplication!),
                        const SizedBox(height: AppConstants.spacingMedium),
                      ],
                      _ApplyCard(
                        job: job,
                        hasApplied: hasApplied,
                        onApply: onApply,
                        onSave: onSave,
                        isSaved: isSaved,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _JobInfoSection(job: job),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _CompanySection(job: job, onViewCompany: onViewCompany),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationStatusCard extends StatelessWidget {
  const _ApplicationStatusCard({required this.application});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Icon(_getStatusIcon(), color: statusColor, size: 20),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة طلبك',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      application.status.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (application.interviewDate != null) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.calendar, color: AppColors.info, size: 16),
                  const SizedBox(width: AppConstants.spacingSmall),
                  Text(
                    'موعد المقابلة: ${_formatDate(application.interviewDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _JobHeader extends StatelessWidget {
  const _JobHeader({required this.job});

  final JobEntity job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  image: job.company?.logoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(job.company!.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: job.company?.logoUrl == null
                    ? Center(
                        child: Text(
                          job.company?.name.isNotEmpty == true
                              ? job.company!.name[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.company?.name ?? 'شركة',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (job.company?.isVerified == true) ...[
                          const SizedBox(width: AppConstants.spacingExtraSmall),
                          const CompanyVerifiedBadge(
                            isVerified: true,
                            size: VerifiedBadgeSize.small,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Text(
                      job.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Wrap(
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingSmall,
            children: [
              if (job.city != null || job.location != null)
                _Tag(
                  icon: Iconsax.location,
                  label: job.city ?? job.location ?? '',
                ),
              _Tag(icon: Iconsax.briefcase, label: job.jobType.label),
              if (job.showSalary && (job.salaryMin != null || job.salaryMax != null))
                _Tag(icon: Iconsax.money, label: job.salaryRange),
              _Tag(icon: Iconsax.chart, label: job.experienceLevel.label),
              _Tag(icon: Iconsax.building, label: job.locationType.label),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobInfoSection extends StatelessWidget {
  const _JobInfoSection({required this.job});

  final JobEntity job;

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 30) {
      return 'منذ ${difference.inDays ~/ 30} شهر';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'الآن';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      title: 'معلومات الوظيفة',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          _InfoRow(
            label: 'تاريخ النشر',
            value: _getTimeAgo(job.publishedAt ?? job.createdAt),
          ),
          _InfoRow(
            label: 'عدد المتقدمين',
            value: '${job.applicationCount} متقدم',
          ),
          _InfoRow(
            label: 'الشواغر',
            value: '${job.remainingVacancies} من ${job.vacancyCount}',
          ),
          _InfoRow(
            label: 'عدد المشاهدات',
            value: '${job.viewCount} مشاهدة',
          ),
          _InfoRow(
            label: 'الحالة',
            value: job.canApply ? 'مفتوح' : (job.isExpired ? 'منتهي' : 'مغلق'),
            isHighlighted: job.canApply,
            isError: !job.canApply,
          ),
          if (job.applicationDeadline != null)
            _InfoRow(
              label: 'آخر موعد',
              value: _formatDate(job.applicationDeadline!),
            ),
          _InfoRow(
            label: 'سنوات الخبرة',
            value: job.experienceRange,
          ),
          if (job.educationLevel != null)
            _InfoRow(
              label: 'المستوى التعليمي',
              value: job.educationLevel!,
            ),
        ],
      ),
    );
  }
}

class _JobDescriptionSection extends StatelessWidget {
  const _JobDescriptionSection({required this.job});

  final JobEntity job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'وصف الوظيفة',
      intensity: GlassIntensity.light,
      child: Text(
        job.description,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    );
  }
}

class _JobRequirementsSection extends StatelessWidget {
  const _JobRequirementsSection({required this.requirements});

  final String requirements;

  @override
  Widget build(BuildContext context) {
    final lines = requirements.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return GlassPanel(
      title: 'المتطلبات',
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) => _RequirementItem(line.trim())).toList(),
      ),
    );
  }
}

class _JobResponsibilitiesSection extends StatelessWidget {
  const _JobResponsibilitiesSection({required this.responsibilities});

  final String responsibilities;

  @override
  Widget build(BuildContext context) {
    final lines = responsibilities.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return GlassPanel(
      title: 'المسؤوليات',
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) => _RequirementItem(line.trim())).toList(),
      ),
    );
  }
}

class _JobBenefitsSection extends StatelessWidget {
  const _JobBenefitsSection({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      title: 'المزايا',
      intensity: GlassIntensity.light,
      child: Wrap(
        spacing: AppConstants.spacingSmall,
        runSpacing: AppConstants.spacingSmall,
        children: benefits
            .map((benefit) => Chip(
                  avatar: const Icon(Iconsax.tick_circle, size: 16, color: AppColors.success),
                  label: Text(benefit),
                ))
            .toList(),
      ),
    );
  }
}

class _JobSkillsSection extends StatelessWidget {
  const _JobSkillsSection({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      title: 'المهارات المطلوبة',
      intensity: GlassIntensity.light,
      child: Wrap(
        spacing: AppConstants.spacingSmall,
        runSpacing: AppConstants.spacingSmall,
        children: skills
            .map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: AppColors.primaryExtraLight,
                ))
            .toList(),
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  const _CompanySection({required this.job, required this.onViewCompany});

  final JobEntity job;
  final VoidCallback onViewCompany;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'عن الشركة',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  image: job.company?.logoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(job.company!.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: job.company?.logoUrl == null
                    ? Center(
                        child: Text(
                          job.company?.name.isNotEmpty == true
                              ? job.company!.name[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.company?.name ?? 'شركة',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (job.company?.isVerified == true) ...[
                          const SizedBox(width: AppConstants.spacingExtraSmall),
                          const CompanyVerifiedBadge(
                            isVerified: true,
                            size: VerifiedBadgeSize.small,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          OutlinedButton(
            onPressed: onViewCompany,
            child: const Text('عرض ملف الشركة'),
          ),
        ],
      ),
    );
  }
}

class _ApplyBottomSheet extends StatelessWidget {
  const _ApplyBottomSheet({
    required this.job,
    required this.hasApplied,
    required this.onApply,
  });

  final JobEntity job;
  final bool hasApplied;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: hasApplied || !job.canApply ? null : onApply,
            child: Text(
              hasApplied
                  ? 'تم التقديم'
                  : (job.canApply ? 'تقدم الآن' : 'التقديم مغلق'),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplyCard extends StatelessWidget {
  const _ApplyCard({
    required this.job,
    required this.hasApplied,
    required this.onApply,
    required this.onSave,
    required this.isSaved,
  });

  final JobEntity job;
  final bool hasApplied;
  final VoidCallback onApply;
  final VoidCallback onSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      intensity: GlassIntensity.medium,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: hasApplied || !job.canApply ? null : onApply,
              child: Text(
                hasApplied
                    ? 'تم التقديم'
                    : (job.canApply ? 'تقدم الآن' : 'التقديم مغلق'),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSave,
              icon: Icon(isSaved ? Iconsax.bookmark5 : Iconsax.bookmark),
              label: Text(isSaved ? 'تم الحفظ' : 'حفظ الوظيفة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.isError = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;
  final bool isError;

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
              color: isError
                  ? AppColors.error
                  : (isHighlighted ? AppColors.success : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Remove bullet point prefix if exists
    final cleanText = text.replaceFirst(RegExp(r'^[•\-*]\s*'), '');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Text(cleanText, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
