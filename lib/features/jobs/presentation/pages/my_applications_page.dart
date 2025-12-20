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
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/job_bloc.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()..add(const LoadMyApplications()),
      child: const _MyApplicationsContent(),
    );
  }
}

class _MyApplicationsContent extends StatefulWidget {
  const _MyApplicationsContent();

  @override
  State<_MyApplicationsContent> createState() => _MyApplicationsContentState();
}

class _MyApplicationsContentState extends State<_MyApplicationsContent> {
  final ScrollController _scrollController = ScrollController();
  ApplicationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<JobBloc>().state;
      if (state is MyApplicationsLoaded && state.hasMore) {
        context.read<JobBloc>().add(LoadMyApplications(
          status: _selectedStatus,
          offset: state.applications.length,
        ));
      }
    }
  }

  void _onStatusFilterChanged(ApplicationStatus? status) {
    setState(() => _selectedStatus = status);
    context.read<JobBloc>().add(LoadMyApplications(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'طلباتي',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Row(
              children: [
                _FilterChip(
                  label: 'الكل',
                  isSelected: _selectedStatus == null,
                  onTap: () => _onStatusFilterChanged(null),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                ...ApplicationStatus.values.map((status) => Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spacingSmall),
                  child: _FilterChip(
                    label: status.label,
                    isSelected: _selectedStatus == status,
                    onTap: () => _onStatusFilterChanged(status),
                    color: _getStatusColor(status),
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<JobBloc, JobState>(
              builder: (context, state) {
                if (state is JobLoading) {
                  return _buildSkeletonList();
                }

                if (state is JobError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is MyApplicationsLoaded) {
                  if (state.applications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<JobBloc>().add(
                        LoadMyApplications(status: _selectedStatus),
                      );
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMedium,
                      ),
                      itemCount: state.applications.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.applications.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppConstants.spacingMedium),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final application = state.applications[index];
                        return _ApplicationCard(
                          application: application,
                          onTap: () => context.push(
                            '${RouteNames.myApplications}/${application.id}',
                          ),
                          onWithdraw: () {
                            _showWithdrawDialog(context, application);
                          },
                        );
                      },
                    ),
                  );
                }

                return _buildSkeletonList();
              },
            ),
          ),
        ],
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

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
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

  Widget _buildSkeletonList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
        ),
        itemCount: 5,
        itemBuilder: (context, index) => const _ApplicationCardSkeleton(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
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
                  LoadMyApplications(status: _selectedStatus),
                );
              },
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا توجد طلبات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              _selectedStatus != null
                  ? 'لم يتم العثور على طلبات بهذه الحالة'
                  : 'لم تتقدم لأي وظيفة بعد',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.jobs),
              icon: const Icon(Iconsax.briefcase),
              label: const Text('تصفح الوظائف'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.dividerLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.onTap,
    required this.onWithdraw,
  });

  final JobApplicationEntity application;
  final VoidCallback onTap;
  final VoidCallback onWithdraw;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = application.job;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      intensity: GlassIntensity.light,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
                            style: theme.textTheme.bodySmall?.copyWith(
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
                  ],
                ),
              ),
              _StatusChip(status: application.status),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              if (job?.city != null || job?.location != null) ...[
                _InfoTag(
                  icon: Iconsax.location,
                  label: job?.city ?? job?.location ?? '',
                ),
                const SizedBox(width: AppConstants.spacingSmall),
              ],
              _InfoTag(
                icon: Iconsax.calendar,
                label: 'تقدمت ${_getTimeAgo(application.createdAt)}',
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
                    'موعد المقابلة: ${application.interviewDate!.day}/${application.interviewDate!.month}/${application.interviewDate!.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (application.status == ApplicationStatus.offered) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onWithdraw,
                    child: const Text('رفض العرض'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
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
          if (application.status == ApplicationStatus.pending ||
              application.status == ApplicationStatus.reviewing) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onWithdraw,
                icon: const Icon(Iconsax.logout),
                label: const Text('سحب الطلب'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApplicationCardSkeleton extends StatelessWidget {
  const _ApplicationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 12, color: Colors.white),
                  ],
                ),
              ),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              Container(width: 80, height: 16, color: Colors.white),
              const SizedBox(width: AppConstants.spacingSmall),
              Container(width: 100, height: 16, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ApplicationStatus status;

  Color get backgroundColor {
    switch (status) {
      case ApplicationStatus.pending:
        return AppColors.warningBackground;
      case ApplicationStatus.reviewing:
        return AppColors.infoBackground;
      case ApplicationStatus.shortlisted:
        return AppColors.primaryLightest;
      case ApplicationStatus.interview:
        return AppColors.secondaryLight;
      case ApplicationStatus.offered:
        return AppColors.successBackground;
      case ApplicationStatus.accepted:
        return AppColors.successBackground;
      case ApplicationStatus.rejected:
        return AppColors.errorBackground;
      case ApplicationStatus.withdrawn:
        return AppColors.dividerLight;
    }
  }

  Color get textColor {
    switch (status) {
      case ApplicationStatus.pending:
        return AppColors.warningDark;
      case ApplicationStatus.reviewing:
        return AppColors.infoDark;
      case ApplicationStatus.shortlisted:
        return AppColors.primary;
      case ApplicationStatus.interview:
        return AppColors.secondary;
      case ApplicationStatus.offered:
        return AppColors.successDark;
      case ApplicationStatus.accepted:
        return AppColors.successDark;
      case ApplicationStatus.rejected:
        return AppColors.errorDark;
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiaryLight),
        const SizedBox(width: AppConstants.spacingExtraSmall),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}
