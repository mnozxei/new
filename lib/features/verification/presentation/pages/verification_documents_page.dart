import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';
import '../bloc/verification_bloc.dart';

class VerificationDocumentsPage extends StatefulWidget {
  const VerificationDocumentsPage({super.key});

  @override
  State<VerificationDocumentsPage> createState() => _VerificationDocumentsPageState();
}

class _VerificationDocumentsPageState extends State<VerificationDocumentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<VerificationBloc>().add(const LoadInstructorApplication());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة التوثيق'),
      ),
      body: BlocBuilder<VerificationBloc, VerificationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final application = state.instructorApplication;
          if (application == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد طلب توثيق',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(context, application),
                const SizedBox(height: 24),
                _buildApplicationDetails(context, application),
                const SizedBox(height: 24),
                _buildDocumentsList(context, state.documents),
                if (application.status == VerificationStatus.rejected &&
                    application.rejectionReason != null) ...[
                  const SizedBox(height: 24),
                  _buildRejectionInfo(context, application),
                ],
                if (application.status == VerificationStatus.pending) ...[
                  const SizedBox(height: 24),
                  _buildWithdrawSection(context, application),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, InstructorApplication application) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (application.status) {
      case VerificationStatus.pending:
        statusColor = theme.colorScheme.tertiary;
        statusIcon = Icons.hourglass_empty;
        statusText = 'قيد المراجعة';
        break;
      case VerificationStatus.approved:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.verified;
        statusText = 'تم القبول';
        break;
      case VerificationStatus.rejected:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel;
        statusText = 'مرفوض';
        break;
      case VerificationStatus.suspended:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.block;
        statusText = 'موقوف';
        break;
      default:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.help_outline;
        statusText = 'غير معروف';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تم التقديم في ${_formatDate(application.submittedAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (application.reviewedAt != null) ...[
                    Text(
                      'تمت المراجعة في ${_formatDate(application.reviewedAt!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationDetails(BuildContext context, InstructorApplication application) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الطلب',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            if (application.bio != null) ...[
              _buildDetailRow(context, 'النبذة التعريفية', application.bio!),
              const SizedBox(height: 12),
            ],
            if (application.expertiseAreas?.isNotEmpty ?? false) ...[
              Text(
                'مجالات الخبرة',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: application.expertiseAreas!
                    .map((area) => Chip(label: Text(area)))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (application.yearsOfExperience != null)
              _buildDetailRow(
                context,
                'سنوات الخبرة',
                '${application.yearsOfExperience} سنة',
              ),
            if (application.portfolioUrl != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(context, 'رابط الأعمال', application.portfolioUrl!),
            ],
            if (application.linkedinUrl != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(context, 'LinkedIn', application.linkedinUrl!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDocumentsList(BuildContext context, List<VerificationDocument> documents) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المستندات المرفقة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            if (documents.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'لا توجد مستندات',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              )
            else
              ...documents.map((doc) => _buildDocumentTile(context, doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, VerificationDocument document) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getDocumentIcon(document.mimeType),
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(document.documentType.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document.originalFilename,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (document.expiryDate != null)
            Text(
              document.isExpired
                  ? 'منتهي الصلاحية'
                  : 'ينتهي في ${_formatDate(document.expiryDate!)}',
              style: TextStyle(
                color: document.isExpired
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: document.isVerified
          ? Icon(Icons.verified, color: theme.colorScheme.primary)
          : Icon(
              Icons.pending,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
    );
  }

  Widget _buildRejectionInfo(BuildContext context, InstructorApplication application) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'سبب الرفض',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              application.rejectionReason!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawSection(BuildContext context, InstructorApplication application) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _confirmWithdraw(context, application.id),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('سحب الطلب'),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  Future<void> _confirmWithdraw(BuildContext context, String applicationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سحب الطلب'),
        content: const Text('هل أنت متأكد من سحب طلب التوثيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('سحب'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<VerificationBloc>().add(
            WithdrawInstructorApplication(applicationId),
          );
    }
  }

  IconData _getDocumentIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;

    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
