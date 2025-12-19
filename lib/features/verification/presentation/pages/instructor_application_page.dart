import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/verification_entity.dart';
import '../bloc/verification_bloc.dart';
import '../widgets/document_upload_tile.dart';

class InstructorApplicationPage extends StatefulWidget {
  const InstructorApplicationPage({super.key});

  @override
  State<InstructorApplicationPage> createState() => _InstructorApplicationPageState();
}

class _InstructorApplicationPageState extends State<InstructorApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _portfolioUrlController = TextEditingController();
  final _linkedinUrlController = TextEditingController();

  List<String> _selectedExpertise = [];
  int _yearsOfExperience = 1;
  int _currentStep = 0;

  final List<String> _expertiseOptions = [
    'تطوير البرمجيات',
    'تصميم الجرافيك',
    'التسويق الرقمي',
    'إدارة الأعمال',
    'تحليل البيانات',
    'الذكاء الاصطناعي',
    'تطوير الألعاب',
    'تصميم المواقع',
    'تطوير التطبيقات',
    'الأمن السيبراني',
    'الحوسبة السحابية',
    'اللغات',
    'المحاسبة والمالية',
    'الموارد البشرية',
    'التصوير والفيديو',
    'الموسيقى',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    context.read<VerificationBloc>().add(const LoadInstructorApplication());
  }

  @override
  void dispose() {
    _bioController.dispose();
    _portfolioUrlController.dispose();
    _linkedinUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب التسجيل كمدرب'),
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
          if (state.status == VerificationStateStatus.success &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Pre-fill form if editing existing application
          if (state.instructorApplication != null && _bioController.text.isEmpty) {
            _prefillForm(state.instructorApplication!);
          }

          return Stepper(
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            onStepTapped: (step) => setState(() => _currentStep = step),
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    if (_currentStep < 2)
                      FilledButton(
                        onPressed: details.onStepContinue,
                        child: const Text('التالي'),
                      )
                    else
                      FilledButton(
                        onPressed: state.isSubmitting ? null : _submitApplication,
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('تقديم الطلب'),
                      ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('السابق'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('معلومات شخصية'),
                subtitle: const Text('أخبرنا عن نفسك'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: _buildPersonalInfoStep(),
              ),
              Step(
                title: const Text('الخبرات والتخصصات'),
                subtitle: const Text('مجالات خبرتك'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: _buildExpertiseStep(),
              ),
              Step(
                title: const Text('المستندات'),
                subtitle: const Text('الوثائق المطلوبة'),
                isActive: _currentStep >= 2,
                state: StepState.indexed,
                content: _buildDocumentsStep(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'نبذة تعريفية',
              hintText: 'اكتب نبذة موجزة عن خبراتك ومؤهلاتك...',
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء كتابة نبذة تعريفية';
              }
              if (value.trim().length < 50) {
                return 'النبذة قصيرة جداً (50 حرف على الأقل)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _portfolioUrlController,
            decoration: const InputDecoration(
              labelText: 'رابط الأعمال (اختياري)',
              hintText: 'https://your-portfolio.com',
              prefixIcon: Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _linkedinUrlController,
            decoration: const InputDecoration(
              labelText: 'حساب LinkedIn (اختياري)',
              hintText: 'https://linkedin.com/in/username',
              prefixIcon: Icon(Icons.business),
            ),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseStep() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر مجالات خبرتك (حد أقصى 5)',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _expertiseOptions.map((option) {
            final isSelected = _selectedExpertise.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (_selectedExpertise.length < 5) {
                      _selectedExpertise.add(option);
                    }
                  } else {
                    _selectedExpertise.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_selectedExpertise.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'الرجاء اختيار مجال واحد على الأقل',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'سنوات الخبرة',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton.outlined(
              onPressed: _yearsOfExperience > 1
                  ? () => setState(() => _yearsOfExperience--)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            Text(
              '$_yearsOfExperience',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' سنة',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            IconButton.outlined(
              onPressed: _yearsOfExperience < 30
                  ? () => setState(() => _yearsOfExperience++)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsStep(VerificationState state) {
    final requirements = state.instructorRequirements.isNotEmpty
        ? state.instructorRequirements
        : VerificationRequirement.instructorRequirements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final requirement in requirements)
          DocumentUploadTile(
            requirement: requirement,
            existingDocument: _findDocument(state.documents, requirement.documentType),
            isUploading: state.isUploading,
            onUpload: (file, expiryDate) => _uploadDocument(file, requirement.documentType, expiryDate),
            onDelete: _deleteDocument,
            onReplace: _replaceDocument,
          ),
      ],
    );
  }

  VerificationDocument? _findDocument(
    List<VerificationDocument> documents,
    DocumentType type,
  ) {
    try {
      return documents.firstWhere((doc) => doc.documentType == type);
    } catch (_) {
      return null;
    }
  }

  void _prefillForm(InstructorApplication application) {
    _bioController.text = application.bio ?? '';
    _portfolioUrlController.text = application.portfolioUrl ?? '';
    _linkedinUrlController.text = application.linkedinUrl ?? '';
    _selectedExpertise = List.from(application.expertiseAreas ?? []);
    _yearsOfExperience = application.yearsOfExperience ?? 1;
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_selectedExpertise.isNotEmpty) {
        setState(() => _currentStep++);
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _uploadDocument(File file, DocumentType type, DateTime? expiryDate) {
    final state = context.read<VerificationBloc>().state;
    context.read<VerificationBloc>().add(
          UploadVerificationDocument(
            file: file,
            documentType: type,
            applicationId: state.instructorApplication?.id,
            expiryDate: expiryDate,
          ),
        );
  }

  void _deleteDocument(String documentId) {
    context.read<VerificationBloc>().add(
          DeleteVerificationDocument(documentId),
        );
  }

  void _replaceDocument(String documentId, File newFile, DateTime? expiryDate) {
    context.read<VerificationBloc>().add(
          ReplaceVerificationDocument(
            documentId: documentId,
            newFile: newFile,
            newExpiryDate: expiryDate,
          ),
        );
  }

  void _submitApplication() {
    final state = context.read<VerificationBloc>().state;

    // Validate required documents
    final requirements = state.instructorRequirements.isNotEmpty
        ? state.instructorRequirements
        : VerificationRequirement.instructorRequirements;

    for (final req in requirements.where((r) => r.isRequired)) {
      if (_findDocument(state.documents, req.documentType) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الرجاء رفع ${req.documentType.displayName}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    if (state.instructorApplication != null) {
      // Update existing application
      context.read<VerificationBloc>().add(
            UpdateInstructorApplication(
              applicationId: state.instructorApplication!.id,
              bio: _bioController.text.trim(),
              expertiseAreas: _selectedExpertise,
              yearsOfExperience: _yearsOfExperience,
              portfolioUrl: _portfolioUrlController.text.trim().isEmpty
                  ? null
                  : _portfolioUrlController.text.trim(),
              linkedinUrl: _linkedinUrlController.text.trim().isEmpty
                  ? null
                  : _linkedinUrlController.text.trim(),
            ),
          );
    } else {
      // Submit new application
      context.read<VerificationBloc>().add(
            SubmitInstructorApplication(
              bio: _bioController.text.trim(),
              expertiseAreas: _selectedExpertise,
              yearsOfExperience: _yearsOfExperience,
              portfolioUrl: _portfolioUrlController.text.trim().isEmpty
                  ? null
                  : _portfolioUrlController.text.trim(),
              linkedinUrl: _linkedinUrlController.text.trim().isEmpty
                  ? null
                  : _linkedinUrlController.text.trim(),
            ),
          );
    }
  }
}
