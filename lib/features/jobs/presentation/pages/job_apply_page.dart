import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/injection/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../bloc/job_bloc.dart';

class JobApplyPage extends StatelessWidget {
  const JobApplyPage({
    super.key,
    required this.jobId,
  });

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()..add(LoadJobDetails(jobId: jobId)),
      child: _JobApplyContent(jobId: jobId),
    );
  }
}

class _JobApplyContent extends StatefulWidget {
  const _JobApplyContent({required this.jobId});

  final String jobId;

  @override
  State<_JobApplyContent> createState() => _JobApplyContentState();
}

class _JobApplyContentState extends State<_JobApplyContent> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  DateTime? _availabilityDate;
  bool _agreedToTerms = false;

  File? _selectedResumeFile;
  String? _selectedResumeName;
  bool _isSubmitting = false;

  final Map<String, String> _questionAnswers = {};

  @override
  void dispose() {
    _coverLetterController.dispose();
    _expectedSalaryController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Check file size (max 5MB)
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حجم الملف يتجاوز 5 ميجابايت'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedResumeFile = file;
          _selectedResumeName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في اختيار الملف: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectAvailabilityDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _availabilityDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _availabilityDate = picked;
      });
    }
  }

  void _submitApplication(JobEntity job) {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final params = ApplyToJobParams(
      jobId: widget.jobId,
      coverLetter: _coverLetterController.text.trim(),
      resumeFile: _selectedResumeFile,
      expectedSalary: _expectedSalaryController.text.isNotEmpty
          ? double.tryParse(_expectedSalaryController.text)
          : null,
      availabilityDate: _availabilityDate,
      answers: _questionAnswers,
    );

    context.read<JobBloc>().add(ApplyToJob(params: params));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              decoration: const BoxDecoration(
                color: AppColors.successBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'تم إرسال طلبك بنجاح!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'سيتم مراجعة طلبك من قبل الشركة وإعلامك بأي تحديثات.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
                context.pop();
              },
              child: const Text('العودة للوظائف'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is ApplicationSubmitted) {
          setState(() => _isSubmitting = false);
          _showSuccessDialog();
        } else if (state is JobError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is JobLoading) {
          return _buildLoadingState(context);
        }

        if (state is JobError) {
          return _buildErrorState(context, state.message);
        }

        if (state is JobDetailsLoaded) {
          return _buildApplicationForm(context, state.job);
        }

        return _buildLoadingState(context);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'التقديم على الوظيفة',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'التقديم على الوظيفة',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: () {
                context.read<JobBloc>().add(LoadJobDetails(jobId: widget.jobId));
              },
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationForm(BuildContext context, JobEntity job) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'التقديم على الوظيفة',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Summary
              GlassCard(
                intensity: GlassIntensity.light,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                        image: job.company?.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(job.company!.logoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: job.company?.logoUrl == null
                          ? Center(
                              child: Text(
                                job.company?.name.isNotEmpty == true
                                    ? job.company!.name[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            job.company?.name ?? 'شركة',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          if (job.city != null || job.location != null)
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.location,
                                  size: 14,
                                  color: AppColors.textTertiaryLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  job.city ?? job.location ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiaryLight,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Resume Section
              Text(
                'السيرة الذاتية *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'PDF, DOC, DOCX - حتى 5MB',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              GlassCard(
                intensity: GlassIntensity.light,
                onTap: _pickResume,
                child: _selectedResumeName != null
                    ? Row(
                        children: [
                          const Icon(
                            Iconsax.document,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: AppConstants.spacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedResumeName!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'اضغط لتغيير الملف',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.close_circle, color: AppColors.error),
                            onPressed: () {
                              setState(() {
                                _selectedResumeFile = null;
                                _selectedResumeName = null;
                              });
                            },
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.primaryExtraLight,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            ),
                            child: const Icon(
                              Iconsax.document_upload,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Text(
                            'اضغط لرفع السيرة الذاتية',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Cover Letter
              Text(
                'رسالة التقديم',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'اكتب رسالة قصيرة توضح لماذا أنت مناسب لهذه الوظيفة',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              TextFormField(
                controller: _coverLetterController,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة التقديم هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Additional Information
              Text(
                'معلومات إضافية',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expectedSalaryController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الراتب المتوقع',
                        prefixIcon: const Icon(Iconsax.money),
                        suffixText: 'ر.س',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: InkWell(
                      onTap: _selectAvailabilityDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'تاريخ الإتاحة',
                          prefixIcon: const Icon(Iconsax.calendar),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                        ),
                        child: Text(
                          _availabilityDate != null
                              ? '${_availabilityDate!.day}/${_availabilityDate!.month}/${_availabilityDate!.year}'
                              : 'اختر التاريخ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _availabilityDate != null
                                ? null
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Agreement
              GlassCard(
                intensity: GlassIntensity.light,
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'أوافق على مشاركة معلوماتي مع صاحب العمل وأقر بأن جميع المعلومات المقدمة صحيحة.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : () => _submitApplication(job),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.send_1),
                  label: Text(_isSubmitting ? 'جاري الإرسال...' : 'إرسال الطلب'),
                ),
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('إلغاء'),
                ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }
}
