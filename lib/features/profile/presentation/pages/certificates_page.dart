import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../widgets/certificates_preview_card.dart';
import '../bloc/profile_bloc.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlassAppBar(
        title: 'شهاداتي',
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            if (state.certificates.isEmpty) {
              return _EmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              itemCount: state.certificates.length,
              itemBuilder: (context, index) {
                final certificate = state.certificates[index];
                return _CertificateCard(
                  certificate: certificate,
                  onDownload: () => _downloadCertificate(context, certificate),
                  onVerify: () => context.push('/verify/${certificate.serialNumber}'),
                  onShare: () => _shareCertificate(context, certificate),
                  onCopyLink: () => _copyVerificationLink(context, certificate),
                );
              },
            );
          }

          return const Center(child: GlassLoadingIndicator());
        },
      ),
    );
  }

  void _downloadCertificate(BuildContext context, CertificatePreview certificate) async {
    if (certificate.pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد ملف PDF للتحميل')),
      );
      return;
    }

    final uri = Uri.parse(certificate.pdfUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط التحميل')),
        );
      }
    }
  }

  void _shareCertificate(BuildContext context, CertificatePreview certificate) {
    final verifyUrl = 'https://tamadhub.com/verify/${certificate.serialNumber}';
    Share.share(
      'لقد حصلت على شهادة في "${certificate.courseName}" من ${certificate.issuerName}.\n\nيمكنك التحقق من الشهادة عبر: $verifyUrl',
      subject: 'شهادة ${certificate.courseName}',
    );
  }

  void _copyVerificationLink(BuildContext context, CertificatePreview certificate) {
    final verifyUrl = 'https://tamadhub.com/verify/${certificate.serialNumber}';
    Clipboard.setData(ClipboardData(text: verifyUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ رابط التحقق')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.award,
                size: 60,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'لا توجد شهادات بعد',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'أكمل الدورات واجتز الاختبارات للحصول على شهاداتك',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: () => context.push('/courses'),
              icon: const Icon(Iconsax.book),
              label: const Text('تصفح الدورات'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.certificate,
    required this.onDownload,
    required this.onVerify,
    required this.onShare,
    required this.onCopyLink,
  });

  final CertificatePreview certificate;
  final VoidCallback onDownload;
  final VoidCallback onVerify;
  final VoidCallback onShare;
  final VoidCallback onCopyLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMMM yyyy', 'ar');

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Certificate header with gradient
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF22C55E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.award,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'شهادة إتمام',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        certificate.courseName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Certificate details
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              children: [
                _DetailRow(
                  icon: Iconsax.teacher,
                  label: 'المدرب',
                  value: certificate.issuerName,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                _DetailRow(
                  icon: Iconsax.calendar_1,
                  label: 'تاريخ الإصدار',
                  value: dateFormat.format(certificate.issuedAt),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                _DetailRow(
                  icon: Iconsax.key,
                  label: 'الرقم التسلسلي',
                  value: certificate.serialNumber,
                  isMonospace: true,
                ),
                const Divider(height: AppConstants.spacingLarge),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onVerify,
                        icon: const Icon(Iconsax.verify, size: 18),
                        label: const Text('التحقق'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(
                            color: AppColors.success.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    if (certificate.pdfUrl != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDownload,
                          icon: const Icon(Iconsax.document_download, size: 18),
                          label: const Text('تحميل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Iconsax.share, size: 18),
                        label: const Text('مشاركة'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onCopyLink,
                        icon: const Icon(Iconsax.copy, size: 18),
                        label: const Text('نسخ الرابط'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: isMonospace ? 'monospace' : null,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
