import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/certificate_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/student_bloc.dart';

class CertificatePage extends StatefulWidget {
  const CertificatePage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final _certificateService = CertificateService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadCertificate(widget.courseId));
  }

  Future<void> _shareCertificate(EnrollmentEntity enrollment) async {
    await ShareService.instance.shareCertificate(
      context: context,
      certificateId: enrollment.id,
      courseName: enrollment.course?.title ?? '',
      holderName: 'المتدرب', // This would come from user profile
    );
  }

  Future<void> _downloadCertificate(EnrollmentEntity enrollment) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final certificateData = CertificateData(
        id: enrollment.id,
        verifyCode: 'TH-${enrollment.id.substring(0, 12).toUpperCase()}',
        holderName: 'المتدرب', // This would come from user profile
        courseName: enrollment.course?.title ?? '',
        instructorName: enrollment.course?.instructor?.fullName ?? '',
        issuerName: enrollment.course?.instructor?.fullName ?? '',
        issueDate: enrollment.completedAt ?? DateTime.now(),
      );

      await _certificateService.shareCertificate(certificateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الشهادة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في إنشاء الشهادة'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _shareToLinkedIn(EnrollmentEntity enrollment) async {
    final url = Uri.parse(
      'https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME'
      '&name=${Uri.encodeComponent(enrollment.course?.title ?? '')}'
      '&organizationName=${Uri.encodeComponent(AppConstants.appName)}'
      '&certUrl=${Uri.encodeComponent('${AppConstants.appWebUrl}/verify/${enrollment.id}')}'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح LinkedIn'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        final enrollment = state is CertificateLoaded ? state.enrollment : null;

        return Scaffold(
          appBar: GlassAppBar(
            title: 'الشهادة',
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_right_1),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.share),
                onPressed: enrollment != null
                    ? () => _shareCertificate(enrollment)
                    : null,
                tooltip: 'مشاركة',
              ),
              IconButton(
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.document_download),
                onPressed: enrollment != null && !_isProcessing
                    ? () => _downloadCertificate(enrollment)
                    : null,
                tooltip: 'تحميل',
              ),
            ],
          ),
          body: _buildBody(theme, state),
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme, StudentState state) {
    if (state is CertificateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StudentError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              state.message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('العودة'),
            ),
          ],
        ),
      );
    }

    if (state is CertificateLoaded) {
      return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                children: [
                  // Certificate Preview
                  _CertificatePreview(
                    enrollment: state.enrollment,
                    certificateUrl: state.certificateUrl,
                  ),

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Certificate Details
                  GlassPanel(
                    title: 'تفاصيل الشهادة',
                    intensity: GlassIntensity.light,
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Iconsax.book_1,
                          label: 'الدورة',
                          value: state.enrollment.course?.title ?? '',
                        ),
                        _DetailRow(
                          icon: Iconsax.teacher,
                          label: 'المدرب',
                          value: state.enrollment.course?.instructor?.fullName ?? '',
                        ),
                        _DetailRow(
                          icon: Iconsax.calendar_1,
                          label: 'تاريخ الإنجاز',
                          value: _formatDate(state.enrollment.completedAt),
                        ),
                        _DetailRow(
                          icon: Iconsax.document,
                          label: 'رقم الشهادة',
                          value: state.enrollment.id.substring(0, 8).toUpperCase(),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingMedium),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareToLinkedIn(state.enrollment),
                          icon: const Icon(Iconsax.share),
                          label: const Text('شارك على LinkedIn'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingSmall),

                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () => _downloadCertificate(state.enrollment),
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Iconsax.document_download),
                          label: const Text('تحميل PDF'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Verification info
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.info_circle, color: AppColors.info),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: Text(
                            'يمكن التحقق من صحة هذه الشهادة عبر الرابط الموجود عليها',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CertificatePreview extends StatelessWidget {
  const _CertificatePreview({
    required this.enrollment,
    required this.certificateUrl,
  });

  final EnrollmentEntity enrollment;
  final String certificateUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          children: [
            // Header decorations
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                const Icon(
                  Iconsax.medal_star,
                  color: AppColors.warning,
                  size: 32,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Certificate title
            Text(
              'شهادة إتمام',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            Text(
              'تشهد منصة تماد هب بأن',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: AppConstants.spacingSmall),

            // Student name placeholder
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
                vertical: AppConstants.spacingSmall,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                'اسم الطالب',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            Text(
              'قد أتم بنجاح دورة',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: AppConstants.spacingSmall),

            // Course title
            Text(
              enrollment.course?.title ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Date and signature area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      _formatDate(enrollment.completedAt),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'التاريخ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      enrollment.course?.instructor?.fullName ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'المدرب',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Certificate ID
            Text(
              'رقم الشهادة: ${enrollment.id.substring(0, 8).toUpperCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
