import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/verification_entity.dart';

class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile({
    super.key,
    required this.requirement,
    this.existingDocument,
    this.onUpload,
    this.onDelete,
    this.onReplace,
    this.isUploading = false,
  });

  final VerificationRequirement requirement;
  final VerificationDocument? existingDocument;
  final void Function(File file, DateTime? expiryDate)? onUpload;
  final void Function(String documentId)? onDelete;
  final void Function(String documentId, File newFile, DateTime? expiryDate)? onReplace;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDocument = existingDocument != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            requirement.documentType.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (requirement.isRequired) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'مطلوب',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (requirement.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          requirement.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusIcon(context),
              ],
            ),
            const SizedBox(height: 12),
            if (hasDocument) ...[
              _buildDocumentInfo(context),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUploading ? null : () => _pickAndReplaceFile(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('استبدال'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: isUploading
                        ? null
                        : () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton.icon(
                        onPressed: () => _pickAndUploadFile(context),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('رفع المستند'),
                      ),
              ),
            ],
            if (requirement.acceptedFormats != null) ...[
              const SizedBox(height: 8),
              Text(
                'الصيغ المقبولة: ${requirement.acceptedFormats!.join(', ')}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
            if (requirement.maxFileSizeMb != null) ...[
              const SizedBox(height: 4),
              Text(
                'الحد الأقصى للحجم: ${requirement.maxFileSizeMb} ميجابايت',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final theme = Theme.of(context);

    if (existingDocument == null) {
      return Icon(
        Icons.upload_outlined,
        color: requirement.isRequired
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface.withOpacity(0.5),
      );
    }

    if (existingDocument!.isVerified) {
      return Icon(
        Icons.verified,
        color: theme.colorScheme.primary,
      );
    }

    if (existingDocument!.isExpired) {
      return Icon(
        Icons.warning_amber,
        color: theme.colorScheme.error,
      );
    }

    if (existingDocument!.isExpiringSoon) {
      return Icon(
        Icons.schedule,
        color: theme.colorScheme.tertiary,
      );
    }

    return Icon(
      Icons.check_circle_outline,
      color: theme.colorScheme.primary,
    );
  }

  Widget _buildDocumentInfo(BuildContext context) {
    final theme = Theme.of(context);
    final doc = existingDocument!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFileIcon(doc.mimeType),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doc.originalFilename,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (doc.fileSize != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatFileSize(doc.fileSize!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
          if (doc.expiryDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 14,
                  color: doc.isExpired
                      ? theme.colorScheme.error
                      : doc.isExpiringSoon
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  doc.isExpired
                      ? 'منتهي الصلاحية'
                      : 'ينتهي في ${_formatDate(doc.expiryDate!)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: doc.isExpired
                        ? theme.colorScheme.error
                        : doc.isExpiringSoon
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
          if (doc.version > 1) ...[
            const SizedBox(height: 4),
            Text(
              'الإصدار ${doc.version}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;

    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: requirement.acceptedFormats ?? ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      // Check file size
      if (requirement.maxFileSizeMb != null) {
        final sizeInMb = file.lengthSync() / (1024 * 1024);
        if (sizeInMb > requirement.maxFileSizeMb!) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'حجم الملف يتجاوز الحد المسموح (${requirement.maxFileSizeMb} MB)',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      DateTime? expiryDate;
      if (requirement.requiresExpiry && context.mounted) {
        expiryDate = await _selectExpiryDate(context);
        if (expiryDate == null) return; // User cancelled
      }

      onUpload?.call(file, expiryDate);
    }
  }

  Future<void> _pickAndReplaceFile(BuildContext context) async {
    if (existingDocument == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: requirement.acceptedFormats ?? ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      // Check file size
      if (requirement.maxFileSizeMb != null) {
        final sizeInMb = file.lengthSync() / (1024 * 1024);
        if (sizeInMb > requirement.maxFileSizeMb!) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'حجم الملف يتجاوز الحد المسموح (${requirement.maxFileSizeMb} MB)',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      DateTime? expiryDate;
      if (requirement.requiresExpiry && context.mounted) {
        expiryDate = await _selectExpiryDate(context);
      }

      onReplace?.call(existingDocument!.id, file, expiryDate);
    }
  }

  Future<DateTime?> _selectExpiryDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: 'تاريخ انتهاء الصلاحية',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (existingDocument == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستند'),
        content: const Text('هل أنت متأكد من حذف هذا المستند؟'),
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
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete?.call(existingDocument!.id);
    }
  }
}
