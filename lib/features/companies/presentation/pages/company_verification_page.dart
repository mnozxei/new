import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';

class CompanyVerificationPage extends StatefulWidget {
  const CompanyVerificationPage({
    required this.companyId,
    super.key,
  });

  final String companyId;

  @override
  State<CompanyVerificationPage> createState() => _CompanyVerificationPageState();
}

class _CompanyVerificationPageState extends State<CompanyVerificationPage> {
  int _currentStep = 0;
  bool _commercialRegisterUploaded = false;
  bool _taxCertificateUploaded = false;
  bool _authorizationLetterUploaded = false;
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileVerificationPage(
        companyId: widget.companyId,
        currentStep: _currentStep,
        commercialRegisterUploaded: _commercialRegisterUploaded,
        taxCertificateUploaded: _taxCertificateUploaded,
        authorizationLetterUploaded: _authorizationLetterUploaded,
        termsAccepted: _termsAccepted,
        onStepChanged: (step) => setState(() => _currentStep = step),
        onCommercialRegisterUpload: () => setState(() => _commercialRegisterUploaded = true),
        onTaxCertificateUpload: () => setState(() => _taxCertificateUploaded = true),
        onAuthorizationLetterUpload: () => setState(() => _authorizationLetterUploaded = true),
        onTermsAcceptedChanged: (value) => setState(() => _termsAccepted = value ?? false),
      ),
      desktop: _DesktopVerificationPage(
        companyId: widget.companyId,
        currentStep: _currentStep,
        commercialRegisterUploaded: _commercialRegisterUploaded,
        taxCertificateUploaded: _taxCertificateUploaded,
        authorizationLetterUploaded: _authorizationLetterUploaded,
        termsAccepted: _termsAccepted,
        onStepChanged: (step) => setState(() => _currentStep = step),
        onCommercialRegisterUpload: () => setState(() => _commercialRegisterUploaded = true),
        onTaxCertificateUpload: () => setState(() => _taxCertificateUploaded = true),
        onAuthorizationLetterUpload: () => setState(() => _authorizationLetterUploaded = true),
        onTermsAcceptedChanged: (value) => setState(() => _termsAccepted = value ?? false),
      ),
    );
  }
}

class _MobileVerificationPage extends StatelessWidget {
  const _MobileVerificationPage({
    required this.companyId,
    required this.currentStep,
    required this.commercialRegisterUploaded,
    required this.taxCertificateUploaded,
    required this.authorizationLetterUploaded,
    required this.termsAccepted,
    required this.onStepChanged,
    required this.onCommercialRegisterUpload,
    required this.onTaxCertificateUpload,
    required this.onAuthorizationLetterUpload,
    required this.onTermsAcceptedChanged,
  });

  final String companyId;
  final int currentStep;
  final bool commercialRegisterUploaded;
  final bool taxCertificateUploaded;
  final bool authorizationLetterUploaded;
  final bool termsAccepted;
  final ValueChanged<int> onStepChanged;
  final VoidCallback onCommercialRegisterUpload;
  final VoidCallback onTaxCertificateUpload;
  final VoidCallback onAuthorizationLetterUpload;
  final ValueChanged<bool?> onTermsAcceptedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'توثيق الشركة',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepIndicator(currentStep: currentStep),
            const SizedBox(height: AppConstants.spacingLarge),
            if (currentStep == 0) ...[
              _DocumentsStep(
                commercialRegisterUploaded: commercialRegisterUploaded,
                taxCertificateUploaded: taxCertificateUploaded,
                authorizationLetterUploaded: authorizationLetterUploaded,
                onCommercialRegisterUpload: onCommercialRegisterUpload,
                onTaxCertificateUpload: onTaxCertificateUpload,
                onAuthorizationLetterUpload: onAuthorizationLetterUpload,
              ),
            ] else if (currentStep == 1) ...[
              _ReviewStep(
                termsAccepted: termsAccepted,
                onTermsAcceptedChanged: onTermsAcceptedChanged,
              ),
            ] else ...[
              _SubmittedStep(),
            ],
            const SizedBox(height: AppConstants.spacingLarge),
            if (currentStep < 2)
              Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStepChanged(currentStep - 1),
                        child: const Text('السابق'),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: GlassButton(
                      onPressed: _canProceed()
                          ? () {
                              if (currentStep < 2) {
                                onStepChanged(currentStep + 1);
                              }
                            }
                          : null,
                      child: Text(
                        currentStep == 1 ? 'إرسال الطلب' : 'التالي',
                        style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (currentStep == 0) {
      return commercialRegisterUploaded && taxCertificateUploaded;
    } else if (currentStep == 1) {
      return termsAccepted;
    }
    return true;
  }
}

class _DesktopVerificationPage extends StatelessWidget {
  const _DesktopVerificationPage({
    required this.companyId,
    required this.currentStep,
    required this.commercialRegisterUploaded,
    required this.taxCertificateUploaded,
    required this.authorizationLetterUploaded,
    required this.termsAccepted,
    required this.onStepChanged,
    required this.onCommercialRegisterUpload,
    required this.onTaxCertificateUpload,
    required this.onAuthorizationLetterUpload,
    required this.onTermsAcceptedChanged,
  });

  final String companyId;
  final int currentStep;
  final bool commercialRegisterUploaded;
  final bool taxCertificateUploaded;
  final bool authorizationLetterUploaded;
  final bool termsAccepted;
  final ValueChanged<int> onStepChanged;
  final VoidCallback onCommercialRegisterUpload;
  final VoidCallback onTaxCertificateUpload;
  final VoidCallback onAuthorizationLetterUpload;
  final ValueChanged<bool?> onTermsAcceptedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: 800,
          margin: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.arrow_right_1),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Text('توثيق الشركة', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Expanded(
                child: GlassCard(
                  intensity: GlassIntensity.light,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StepIndicator(currentStep: currentStep),
                        const SizedBox(height: AppConstants.spacingLarge),
                        if (currentStep == 0) ...[
                          _DocumentsStep(
                            commercialRegisterUploaded: commercialRegisterUploaded,
                            taxCertificateUploaded: taxCertificateUploaded,
                            authorizationLetterUploaded: authorizationLetterUploaded,
                            onCommercialRegisterUpload: onCommercialRegisterUpload,
                            onTaxCertificateUpload: onTaxCertificateUpload,
                            onAuthorizationLetterUpload: onAuthorizationLetterUpload,
                          ),
                        ] else if (currentStep == 1) ...[
                          _ReviewStep(
                            termsAccepted: termsAccepted,
                            onTermsAcceptedChanged: onTermsAcceptedChanged,
                          ),
                        ] else ...[
                          _SubmittedStep(),
                        ],
                        const SizedBox(height: AppConstants.spacingLarge),
                        if (currentStep < 2)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (currentStep > 0)
                                OutlinedButton(
                                  onPressed: () => onStepChanged(currentStep - 1),
                                  child: const Text('السابق'),
                                ),
                              if (currentStep > 0) const SizedBox(width: AppConstants.spacingMedium),
                              GlassButton(
                                onPressed: _canProceed()
                                    ? () {
                                        if (currentStep < 2) {
                                          onStepChanged(currentStep + 1);
                                        }
                                      }
                                    : null,
                                child: Text(
                                  currentStep == 1 ? 'إرسال الطلب' : 'التالي',
                                  style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    if (currentStep == 0) {
      return commercialRegisterUploaded && taxCertificateUploaded;
    } else if (currentStep == 1) {
      return termsAccepted;
    }
    return true;
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _StepDot(step: 0, currentStep: currentStep, label: 'المستندات'),
        Expanded(child: _StepLine(isActive: currentStep > 0)),
        _StepDot(step: 1, currentStep: currentStep, label: 'المراجعة'),
        Expanded(child: _StepLine(isActive: currentStep > 1)),
        _StepDot(step: 2, currentStep: currentStep, label: 'الإرسال'),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.currentStep,
    required this.label,
  });

  final int step;
  final int currentStep;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isActive = step <= currentStep;
    final bool isCurrent = step == currentStep;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.primaryExtraLight,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: AppColors.primary, width: 3) : null,
          ),
          child: Center(
            child: isActive && step < currentStep
                ? const Icon(Iconsax.tick_circle, color: AppColors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? AppColors.white : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondaryLight,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  const _DocumentsStep({
    required this.commercialRegisterUploaded,
    required this.taxCertificateUploaded,
    required this.authorizationLetterUploaded,
    required this.onCommercialRegisterUpload,
    required this.onTaxCertificateUpload,
    required this.onAuthorizationLetterUpload,
  });

  final bool commercialRegisterUploaded;
  final bool taxCertificateUploaded;
  final bool authorizationLetterUploaded;
  final VoidCallback onCommercialRegisterUpload;
  final VoidCallback onTaxCertificateUpload;
  final VoidCallback onAuthorizationLetterUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المستندات المطلوبة', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          'يرجى رفع المستندات التالية للتحقق من هوية الشركة',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        _DocumentUploadCard(
          title: 'السجل التجاري',
          description: 'نسخة سارية من السجل التجاري للشركة',
          icon: Iconsax.document_text,
          isRequired: true,
          isUploaded: commercialRegisterUploaded,
          onUpload: onCommercialRegisterUpload,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        _DocumentUploadCard(
          title: 'شهادة الضريبة',
          description: 'شهادة التسجيل في ضريبة القيمة المضافة',
          icon: Iconsax.receipt_text,
          isRequired: true,
          isUploaded: taxCertificateUploaded,
          onUpload: onTaxCertificateUpload,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        _DocumentUploadCard(
          title: 'خطاب التفويض',
          description: 'خطاب يثبت صلاحيتك لتمثيل الشركة (اختياري)',
          icon: Iconsax.document_favorite,
          isRequired: false,
          isUploaded: authorizationLetterUploaded,
          onUpload: onAuthorizationLetterUpload,
        ),
      ],
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  const _DocumentUploadCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isRequired,
    required this.isUploaded,
    required this.onUpload,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isRequired;
  final bool isUploaded;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isUploaded ? AppColors.success.withValues(alpha: 0.1) : AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: isUploaded ? AppColors.success : AppColors.dividerLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUploaded ? AppColors.success : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(
              isUploaded ? Iconsax.tick_circle : icon,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    if (isRequired) ...[
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      Text('*', style: theme.textTheme.titleSmall?.copyWith(color: AppColors.error)),
                    ],
                  ],
                ),
                Text(description, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          if (isUploaded)
            const Icon(Iconsax.tick_circle, color: AppColors.success)
          else
            OutlinedButton(
              onPressed: onUpload,
              child: const Text('رفع'),
            ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.termsAccepted,
    required this.onTermsAcceptedChanged,
  });

  final bool termsAccepted;
  final ValueChanged<bool?> onTermsAcceptedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مراجعة الطلب', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          'يرجى مراجعة البيانات والموافقة على الشروط والأحكام',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        GlassPanel(
          title: 'ملخص المستندات',
          intensity: GlassIntensity.light,
          child: Column(
            children: [
              _ReviewItem(label: 'السجل التجاري', status: 'تم الرفع'),
              _ReviewItem(label: 'شهادة الضريبة', status: 'تم الرفع'),
              _ReviewItem(label: 'خطاب التفويض', status: 'اختياري'),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Iconsax.info_circle, color: AppColors.warning),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Text(
                  'سيتم مراجعة طلبك خلال 2-3 أيام عمل. ستصلك إشعار عند الانتهاء من المراجعة.',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        Row(
          children: [
            Checkbox(
              value: termsAccepted,
              onChanged: onTermsAcceptedChanged,
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onTermsAcceptedChanged(!termsAccepted),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'أوافق على ', style: theme.textTheme.bodyMedium),
                      TextSpan(
                        text: 'الشروط والأحكام',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: ' و', style: theme.textTheme.bodyMedium),
                      TextSpan(
                        text: 'سياسة الخصوصية',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.label,
    required this.status,
  });

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUploaded = status == 'تم الرفع';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      child: Row(
        children: [
          Icon(
            isUploaded ? Iconsax.tick_circle : Iconsax.minus_cirlce,
            size: 18,
            color: isUploaded ? AppColors.success : AppColors.textTertiaryLight,
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(status, style: theme.textTheme.bodySmall?.copyWith(color: isUploaded ? AppColors.success : AppColors.textTertiaryLight)),
        ],
      ),
    );
  }
}

class _SubmittedStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.tick_circle, size: 50, color: AppColors.success),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text('تم إرسال الطلب بنجاح!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'سيتم مراجعة طلبك وإشعارك بالنتيجة خلال 2-3 أيام عمل',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          GlassButton(
            onPressed: () => context.pop(),
            child: Text('العودة للشركات', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
