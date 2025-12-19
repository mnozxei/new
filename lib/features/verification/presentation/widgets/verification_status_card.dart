import 'package:flutter/material.dart';

import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';

class VerificationStatusCard extends StatelessWidget {
  const VerificationStatusCard({
    super.key,
    required this.status,
    this.application,
    this.rejectionReason,
    this.onApplyPressed,
    this.onViewDetailsPressed,
    this.onReapplyPressed,
  });

  final VerificationStatus status;
  final InstructorApplication? application;
  final String? rejectionReason;
  final VoidCallback? onApplyPressed;
  final VoidCallback? onViewDetailsPressed;
  final VoidCallback? onReapplyPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (status == VerificationStatus.rejected && rejectionReason != null) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سبب الرفض',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rejectionReason!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color backgroundColor;
    Color iconColor;

    switch (status) {
      case VerificationStatus.notSubmitted:
        icon = Icons.person_add;
        backgroundColor = theme.colorScheme.primaryContainer;
        iconColor = theme.colorScheme.primary;
        break;
      case VerificationStatus.pending:
        icon = Icons.hourglass_empty;
        backgroundColor = theme.colorScheme.tertiaryContainer;
        iconColor = theme.colorScheme.tertiary;
        break;
      case VerificationStatus.approved:
        icon = Icons.verified;
        backgroundColor = theme.colorScheme.primaryContainer;
        iconColor = theme.colorScheme.primary;
        break;
      case VerificationStatus.rejected:
        icon = Icons.cancel;
        backgroundColor = theme.colorScheme.errorContainer;
        iconColor = theme.colorScheme.error;
        break;
      case VerificationStatus.suspended:
        icon = Icons.block;
        backgroundColor = theme.colorScheme.errorContainer;
        iconColor = theme.colorScheme.error;
        break;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }

  String _getStatusTitle() {
    switch (status) {
      case VerificationStatus.notSubmitted:
        return 'كن مدرباً معتمداً';
      case VerificationStatus.pending:
        return 'طلبك قيد المراجعة';
      case VerificationStatus.approved:
        return 'مدرب معتمد';
      case VerificationStatus.rejected:
        return 'تم رفض الطلب';
      case VerificationStatus.suspended:
        return 'الحساب موقوف';
    }
  }

  String _getStatusDescription() {
    switch (status) {
      case VerificationStatus.notSubmitted:
        return 'شارك خبراتك وأنشئ دورات تعليمية على منصتنا';
      case VerificationStatus.pending:
        return 'نراجع طلبك وسنرد خلال 3-5 أيام عمل';
      case VerificationStatus.approved:
        return 'يمكنك الآن إنشاء ونشر دورات تعليمية';
      case VerificationStatus.rejected:
        return 'يمكنك تقديم طلب جديد بعد تصحيح الملاحظات';
      case VerificationStatus.suspended:
        return 'تواصل مع الدعم لمزيد من المعلومات';
    }
  }

  Widget _buildActionButton(BuildContext context) {
    switch (status) {
      case VerificationStatus.notSubmitted:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onApplyPressed,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('تقديم طلب الآن'),
          ),
        );
      case VerificationStatus.pending:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onViewDetailsPressed,
            icon: const Icon(Icons.visibility),
            label: const Text('عرض تفاصيل الطلب'),
          ),
        );
      case VerificationStatus.approved:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onViewDetailsPressed,
            icon: const Icon(Icons.school),
            label: const Text('إدارة دوراتي'),
          ),
        );
      case VerificationStatus.rejected:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onReapplyPressed,
            icon: const Icon(Icons.refresh),
            label: const Text('تقديم طلب جديد'),
          ),
        );
      case VerificationStatus.suspended:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.support_agent),
            label: const Text('تواصل مع الدعم'),
          ),
        );
    }
  }
}
