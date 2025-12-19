import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/certificate_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/course_bloc.dart';

/// Public certificate verification page
/// Accessible at /verify/:code
class CertificateVerifyPage extends StatefulWidget {
  const CertificateVerifyPage({
    super.key,
    this.code,
  });

  /// Serial number code from URL
  final String? code;

  @override
  State<CertificateVerifyPage> createState() => _CertificateVerifyPageState();
}

class _CertificateVerifyPageState extends State<CertificateVerifyPage> {
  final _serialController = TextEditingController();
  bool _isLoading = false;
  CertificateVerificationResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.code != null && widget.code!.isNotEmpty) {
      _serialController.text = widget.code!;
      _verifyCertificate();
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _verifyCertificate() async {
    final serial = _serialController.text.trim();
    if (serial.isEmpty) {
      setState(() {
        _error = 'الرجاء إدخال رقم الشهادة';
      });
      return;
    }

    if (!CertificateSerialGenerator.isValid(serial)) {
      setState(() {
        _error = 'صيغة الرقم التسلسلي غير صحيحة';
        _result = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      context.read<CourseBloc>().add(VerifyCertificate(serial));
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء التحقق';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CertificateVerified) {
            setState(() {
              _result = state.result;
              _isLoading = false;
              _error = null;
            });
          }
          if (state is CourseError) {
            setState(() {
              _error = state.message;
              _isLoading = false;
            });
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 64,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'التحقق من الشهادة',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'أدخل الرقم التسلسلي للشهادة للتحقق من صحتها',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _serialController,
                      decoration: InputDecoration(
                        labelText: 'الرقم التسلسلي',
                        hintText: 'TAMAD-2024-XXXXXX',
                        prefixIcon: const Icon(Icons.qr_code),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              _serialController.text = data!.text!;
                            }
                          },
                          icon: const Icon(Icons.paste),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _verifyCertificate(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _verifyCertificate,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: const Text('تحقق'),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: theme.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_result != null) ...[
                      const SizedBox(height: 32),
                      _buildResultCard(context, _result!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, CertificateVerificationResult result) {
    final theme = Theme.of(context);

    if (result.isValid && result.certificate != null) {
      final cert = result.certificate!;
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'شهادة صالحة',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cert.serialNumber,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.9),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    icon: Icons.person,
                    label: 'اسم الحاصل',
                    value: cert.studentName ?? 'غير متوفر',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    icon: Icons.school,
                    label: 'اسم الدورة',
                    value: cert.courseName ?? 'غير متوفر',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    icon: Icons.supervisor_account,
                    label: 'المدرب',
                    value: cert.instructorName ?? 'غير متوفر',
                  ),
                  if (cert.companyName != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.business,
                      label: 'الشركة',
                      value: cert.companyName!,
                    ),
                  ],
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'تاريخ الإصدار',
                    value: _formatDate(cert.issuedAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Invalid certificate
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.cancel,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'شهادة غير صالحة',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (result.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                result.errorMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'إذا كنت تعتقد أن هذا خطأ، يرجى التواصل مع الدعم الفني',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
