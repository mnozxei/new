import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';
import '../bloc/verification_bloc.dart';

class AdminInstructorVerificationsPage extends StatefulWidget {
  const AdminInstructorVerificationsPage({super.key});

  @override
  State<AdminInstructorVerificationsPage> createState() =>
      _AdminInstructorVerificationsPageState();
}

class _AdminInstructorVerificationsPageState
    extends State<AdminInstructorVerificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<VerificationBloc>().add(
          const LoadPendingInstructorApplications(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات توثيق المدربين'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VerificationBloc>().add(
                    const LoadPendingInstructorApplications(),
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

          if (state.pendingInstructorApplications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
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
                    'ستظهر طلبات التوثيق الجديدة هنا',
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
            itemCount: state.pendingInstructorApplications.length,
            itemBuilder: (context, index) {
              final application = state.pendingInstructorApplications[index];
              return _ApplicationCard(
                application: application,
                onApprove: () => _approveApplication(application.id),
                onReject: () => _showRejectDialog(application.id),
                onViewDetails: () => _showDetailsDialog(application),
              );
            },
          );
        },
      ),
    );
  }

  void _approveApplication(String applicationId) {
    context.read<VerificationBloc>().add(
          ApproveInstructorApplication(applicationId: applicationId),
        );
  }

  Future<void> _showRejectDialog(String applicationId) async {
    final reasonController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
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
            RejectInstructorApplication(
              applicationId: applicationId,
              reason: result['reason']!,
              adminNotes: result['notes']!.isEmpty ? null : result['notes'],
            ),
          );
    }
  }

  void _showDetailsDialog(InstructorApplication application) {
    showDialog(
      context: context,
      builder: (context) => _ApplicationDetailsDialog(application: application),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.onApprove,
    required this.onReject,
    required this.onViewDetails,
  });

  final InstructorApplication application;
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
                  child: Text(
                    application.userId.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب #${application.id.substring(0, 8)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'تقدم في ${_formatDate(application.submittedAt)}',
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
            if (application.bio != null) ...[
              Text(
                application.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(
                  Icons.work,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${application.yearsOfExperience ?? 0} سنوات خبرة',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.attachment,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${application.documents.length} مستند',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (application.expertiseAreas?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: application.expertiseAreas!.take(3).map((area) {
                  return Chip(
                    label: Text(area),
                    labelStyle: theme.textTheme.labelSmall,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
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

class _ApplicationDetailsDialog extends StatelessWidget {
  const _ApplicationDetailsDialog({required this.application});

  final InstructorApplication application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('تفاصيل الطلب #${application.id.substring(0, 8)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'النبذة التعريفية', application.bio ?? 'غير متوفر'),
            const Divider(height: 24),
            _buildSection(
              context,
              'سنوات الخبرة',
              '${application.yearsOfExperience ?? 0} سنة',
            ),
            const Divider(height: 24),
            if (application.expertiseAreas?.isNotEmpty ?? false) ...[
              Text(
                'مجالات الخبرة',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
              const Divider(height: 24),
            ],
            Text(
              'المستندات (${application.documents.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...application.documents.map((doc) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  doc.mimeType?.startsWith('image/') == true
                      ? Icons.image
                      : Icons.picture_as_pdf,
                  color: theme.colorScheme.primary,
                ),
                title: Text(doc.documentType.displayName),
                subtitle: Text(doc.originalFilename),
                dense: true,
              );
            }),
            if (application.portfolioUrl != null) ...[
              const Divider(height: 24),
              _buildSection(context, 'رابط الأعمال', application.portfolioUrl!),
            ],
            if (application.linkedinUrl != null) ...[
              const Divider(height: 24),
              _buildSection(context, 'LinkedIn', application.linkedinUrl!),
            ],
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
}
