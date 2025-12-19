import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';
import '../bloc/verification_bloc.dart';

class AdminCompanyVerificationsPage extends StatefulWidget {
  const AdminCompanyVerificationsPage({super.key});

  @override
  State<AdminCompanyVerificationsPage> createState() =>
      _AdminCompanyVerificationsPageState();
}

class _AdminCompanyVerificationsPageState
    extends State<AdminCompanyVerificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<VerificationBloc>().add(
          const LoadPendingCompanyVerifications(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات توثيق الشركات'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VerificationBloc>().add(
                    const LoadPendingCompanyVerifications(),
                  );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.pendingCompanyVerifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات معلقة',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستظهر طلبات توثيق الشركات هنا',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.pendingCompanyVerifications.length,
            itemBuilder: (context, index) {
              final verification = state.pendingCompanyVerifications[index];
              return _CompanyVerificationCard(
                verification: verification,
                onApprove: () => _approveVerification(verification.id),
                onReject: () => _showRejectDialog(verification.id),
                onViewDetails: () => _showDetailsDialog(verification),
              );
            },
          );
        },
      ),
    );
  }

  void _approveVerification(String verificationId) {
    context.read<VerificationBloc>().add(
          ApproveCompanyVerification(verificationId: verificationId),
        );
  }

  Future<void> _showRejectDialog(String verificationId) async {
    final reasonController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض التوثيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض *',
                hintText: 'أدخل سبب الرفض...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات داخلية (اختياري)',
                hintText: 'ملاحظات للمراجع الآخرين...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال سبب الرفض')),
                );
                return;
              }
              Navigator.pop(context, {
                'reason': reasonController.text.trim(),
                'notes': notesController.text.trim(),
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      context.read<VerificationBloc>().add(
            RejectCompanyVerification(
              verificationId: verificationId,
              reason: result['reason']!,
              adminNotes: result['notes']!.isEmpty ? null : result['notes'],
            ),
          );
    }
  }

  void _showDetailsDialog(CompanyVerificationRequest verification) {
    showDialog(
      context: context,
      builder: (context) =>
          _VerificationDetailsDialog(verification: verification),
    );
  }
}

class _CompanyVerificationCard extends StatelessWidget {
  const _CompanyVerificationCard({
    required this.verification,
    required this.onApprove,
    required this.onReject,
    required this.onViewDetails,
  });

  final CompanyVerificationRequest verification;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.business,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب #${verification.id.substring(0, 8)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'تقدم في ${_formatDate(verification.submittedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                if (verification.companyType != null) ...[
                  Icon(
                    Icons.category,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    verification.companyType!,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.attachment,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${verification.documents.length} مستند',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (verification.industry != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(verification.industry!),
                labelStyle: theme.textTheme.labelSmall,
                visualDensity: VisualDensity.compact,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: const Text('قبول'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _VerificationDetailsDialog extends StatelessWidget {
  const _VerificationDetailsDialog({required this.verification});

  final CompanyVerificationRequest verification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('تفاصيل التوثيق #${verification.id.substring(0, 8)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'معرف الشركة', verification.companyId),
            const Divider(height: 24),
            if (verification.companyType != null) ...[
              _buildSection(context, 'نوع الشركة', verification.companyType!),
              const Divider(height: 24),
            ],
            if (verification.employeeCountRange != null) ...[
              _buildSection(
                context,
                'عدد الموظفين',
                verification.employeeCountRange!,
              ),
              const Divider(height: 24),
            ],
            if (verification.industry != null) ...[
              _buildSection(context, 'القطاع', verification.industry!),
              const Divider(height: 24),
            ],
            if (verification.websiteUrl != null) ...[
              _buildSection(context, 'الموقع الإلكتروني', verification.websiteUrl!),
              const Divider(height: 24),
            ],
            Text(
              'المستندات (${verification.documents.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...verification.documents.map((doc) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  doc.mimeType?.startsWith('image/') == true
                      ? Icons.image
                      : Icons.picture_as_pdf,
                  color: theme.colorScheme.primary,
                ),
                title: Text(doc.documentType.displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.originalFilename),
                    if (doc.expiryDate != null)
                      Text(
                        doc.isExpired
                            ? 'منتهي الصلاحية'
                            : 'ينتهي في ${_formatDate(doc.expiryDate!)}',
                        style: TextStyle(
                          color: doc.isExpired
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                dense: true,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
