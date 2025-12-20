import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/repositories/profile_repository.dart';

export '../../domain/repositories/profile_repository.dart' show CertificatePreview;

class CertificatesPreviewCard extends StatelessWidget {
  const CertificatesPreviewCard({
    super.key,
    required this.certificates,
    required this.totalCount,
    this.onViewAll,
    this.onDownload,
    this.onVerify,
  });

  final List<CertificatePreview> certificates;
  final int totalCount;
  final VoidCallback? onViewAll;
  final void Function(CertificatePreview)? onDownload;
  final void Function(CertificatePreview)? onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.award,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الشهادات',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (totalCount > 0)
                        Text(
                          '$totalCount شهادة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (totalCount > 0)
                TextButton(
                  onPressed: onViewAll ?? () => context.push('/profile/certificates'),
                  child: const Text('عرض الكل'),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          if (certificates.isEmpty)
            _EmptyState()
          else
            ...certificates.take(3).map(
                  (cert) => _CertificateTile(
                    certificate: cert,
                    onDownload: onDownload != null ? () => onDownload!(cert) : null,
                    onVerify: onVerify != null ? () => onVerify!(cert) : null,
                  ),
                ),
          if (totalCount > 3)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
              child: Center(
                child: TextButton(
                  onPressed: onViewAll ?? () => context.push('/profile/certificates'),
                  child: Text('+${totalCount - 3} شهادات أخرى'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundSecondaryDark
            : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.medal,
            size: 40,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'لا توجد شهادات بعد',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'أكمل دورة للحصول على شهادتك الأولى',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CertificateTile extends StatelessWidget {
  const _CertificateTile({
    required this.certificate,
    this.onDownload,
    this.onVerify,
  });

  final CertificatePreview certificate;
  final VoidCallback? onDownload;
  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundSecondaryDark
            : AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, Color(0xFF22C55E)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.award,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.courseName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      certificate.issuerName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.calendar_1,
                    size: 14,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(certificate.issuedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (certificate.pdfUrl != null)
                    IconButton(
                      onPressed: onDownload,
                      icon: const Icon(Iconsax.document_download, size: 20),
                      tooltip: 'تحميل',
                      visualDensity: VisualDensity.compact,
                      color: AppColors.primary,
                    ),
                  IconButton(
                    onPressed: onVerify ?? () => context.push('/verify/${certificate.serialNumber}'),
                    icon: const Icon(Iconsax.verify, size: 20),
                    tooltip: 'التحقق',
                    visualDensity: VisualDensity.compact,
                    color: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
