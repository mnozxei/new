import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class JobApplyPage extends StatefulWidget {
  const JobApplyPage({
    super.key,
    required this.jobId,
  });

  final String jobId;

  @override
  State<JobApplyPage> createState() => _JobApplyPageState();
}

class _JobApplyPageState extends State<JobApplyPage> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _portfolioUrlController = TextEditingController();

  bool _useProfileResume = true;
  bool _isSubmitting = false;
  String? _uploadedResumeName;

  @override
  void dispose() {
    _coverLetterController.dispose();
    _expectedSalaryController.dispose();
    _yearsExperienceController.dispose();
    _portfolioUrlController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate submission
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    });
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
              decoration: BoxDecoration(
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
                      ),
                      child: const Icon(
                        Iconsax.briefcase,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مطور Flutter أول',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'شركة التقنية المتقدمة',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.location,
                                size: 14,
                                color: AppColors.textTertiaryLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'الرياض',
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
                'السيرة الذاتية',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              GlassCard(
                intensity: GlassIntensity.light,
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _useProfileResume,
                      onChanged: (value) {
                        setState(() => _useProfileResume = value!);
                      },
                      title: const Text('استخدام السيرة الذاتية من ملفي الشخصي'),
                      subtitle: const Text('CV_محمد_أحمد.pdf'),
                      secondary: const Icon(Iconsax.document, color: AppColors.primary),
                    ),
                    const Divider(),
                    RadioListTile<bool>(
                      value: false,
                      groupValue: _useProfileResume,
                      onChanged: (value) {
                        setState(() => _useProfileResume = value!);
                      },
                      title: const Text('رفع سيرة ذاتية جديدة'),
                      subtitle: _uploadedResumeName != null
                          ? Text(_uploadedResumeName!)
                          : const Text('PDF, DOC, DOCX - حتى 5MB'),
                      secondary: const Icon(Iconsax.document_upload, color: AppColors.primary),
                    ),
                    if (!_useProfileResume) ...[
                      const SizedBox(height: AppConstants.spacingMedium),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: File picker
                          setState(() {
                            _uploadedResumeName = 'new_resume.pdf';
                          });
                        },
                        icon: const Icon(Iconsax.document_upload),
                        label: const Text('اختيار ملف'),
                      ),
                    ],
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى كتابة رسالة التقديم';
                  }
                  if (value.trim().length < 50) {
                    return 'يجب أن تكون الرسالة 50 حرف على الأقل';
                  }
                  return null;
                },
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
                      controller: _yearsExperienceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'سنوات الخبرة',
                        prefixIcon: const Icon(Iconsax.calendar),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
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
                ],
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              TextFormField(
                controller: _portfolioUrlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'رابط الأعمال / Portfolio (اختياري)',
                  prefixIcon: const Icon(Iconsax.link),
                  hintText: 'https://...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Screening Questions
              Text(
                'أسئلة الفرز',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              GlassCard(
                intensity: GlassIntensity.light,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScreeningQuestion(
                      question: 'هل لديك خبرة في تطوير تطبيقات Flutter؟',
                      isRequired: true,
                    ),
                    const Divider(),
                    _ScreeningQuestion(
                      question: 'هل أنت مستعد للعمل من المكتب؟',
                      isRequired: true,
                    ),
                    const Divider(),
                    _ScreeningQuestion(
                      question: 'هل لديك خبرة في العمل مع فرق Agile؟',
                      isRequired: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Agreement
              GlassCard(
                intensity: GlassIntensity.light,
                child: Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
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
                  onPressed: _isSubmitting ? null : _submitApplication,
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

class _ScreeningQuestion extends StatefulWidget {
  const _ScreeningQuestion({
    required this.question,
    required this.isRequired,
  });

  final String question;
  final bool isRequired;

  @override
  State<_ScreeningQuestion> createState() => _ScreeningQuestionState();
}

class _ScreeningQuestionState extends State<_ScreeningQuestion> {
  String? _answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.question,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (widget.isRequired)
              Text(
                '*',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'yes',
                groupValue: _answer,
                onChanged: (value) => setState(() => _answer = value),
                title: const Text('نعم'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: 'no',
                groupValue: _answer,
                onChanged: (value) => setState(() => _answer = value),
                title: const Text('لا'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
