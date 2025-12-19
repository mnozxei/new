import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class InstructorApplicationPage extends StatefulWidget {
  const InstructorApplicationPage({super.key});

  @override
  State<InstructorApplicationPage> createState() =>
      _InstructorApplicationPageState();
}

class _InstructorApplicationPageState extends State<InstructorApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isSubmitting = false;
  String? _selectedCategory;

  final List<String> _categories = [
    'البرمجة والتطوير',
    'التصميم والجرافيك',
    'التسويق الرقمي',
    'إدارة الأعمال',
    'اللغات',
    'المحاسبة والمالية',
    'تطوير الذات',
    'أخرى',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _expertiseController.dispose();
    _experienceController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Submit application to backend
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'تم إرسال طلبك بنجاح!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'سنقوم بمراجعة طلبك وإعلامك بالنتيجة خلال 3-5 أيام عمل',
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
                Navigator.of(context).pop();
                context.go(RouteNames.profile);
              },
              child: const Text('حسناً'),
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
        title: 'كن مدرباً',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              GlassCard(
                intensity: GlassIntensity.light,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMedium),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.teacher,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      'انضم لفريق المدربين',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      'شارك خبراتك مع آلاف المتعلمين واحصل على دخل إضافي',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              // Benefits Section
              GlassPanel(
                title: 'مميزات المدربين',
                intensity: GlassIntensity.light,
                child: Column(
                  children: [
                    _BenefitItem(
                      icon: Iconsax.money_recive,
                      title: 'دخل إضافي',
                      description: 'احصل على 70% من إيرادات دوراتك',
                    ),
                    _BenefitItem(
                      icon: Iconsax.people,
                      title: 'جمهور واسع',
                      description: 'الوصول لآلاف المتعلمين',
                    ),
                    _BenefitItem(
                      icon: Iconsax.chart_21,
                      title: 'تحليلات متقدمة',
                      description: 'تتبع أداء دوراتك بالتفصيل',
                    ),
                    _BenefitItem(
                      icon: Iconsax.support,
                      title: 'دعم فني',
                      description: 'فريق دعم متخصص لمساعدتك',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              // Application Form
              GlassPanel(
                title: 'نموذج التقديم',
                intensity: GlassIntensity.light,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio
                    Text(
                      'نبذة عنك *',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'اكتب نبذة مختصرة عن نفسك وخلفيتك المهنية...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        if (value.length < 50) {
                          return 'يجب أن تكون النبذة 50 حرف على الأقل';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Category
                    Text(
                      'مجال التخصص *',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        hintText: 'اختر مجال تخصصك',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'يرجى اختيار مجال التخصص';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Expertise
                    Text(
                      'مجالات الخبرة *',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    TextFormField(
                      controller: _expertiseController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText:
                            'مثال: تطوير تطبيقات Flutter، قواعد البيانات، APIs...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Experience
                    Text(
                      'سنوات الخبرة *',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    TextFormField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'عدد سنوات الخبرة في مجالك',
                        border: OutlineInputBorder(),
                        suffixText: 'سنة',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        final years = int.tryParse(value);
                        if (years == null || years < 1) {
                          return 'يجب أن يكون لديك سنة خبرة على الأقل';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // LinkedIn (optional)
                    Text(
                      'رابط LinkedIn (اختياري)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    TextFormField(
                      controller: _linkedinController,
                      decoration: const InputDecoration(
                        hintText: 'https://linkedin.com/in/username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.link),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Portfolio (optional)
                    Text(
                      'رابط الموقع الشخصي أو Portfolio (اختياري)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    TextFormField(
                      controller: _portfolioController,
                      decoration: const InputDecoration(
                        hintText: 'https://yourwebsite.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.global),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingLarge),

                    // Terms checkbox
                    CheckboxListTile(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() => _agreeToTerms = value ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'أوافق على '),
                            TextSpan(
                              text: 'شروط وأحكام',
                              style: TextStyle(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' المدربين'),
                          ],
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submitApplication,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('إرسال الطلب'),
                      ),
                    ),
                  ],
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

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
