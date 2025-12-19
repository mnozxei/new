import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_bloc.dart' hide EnrollInCourse;
import '../bloc/student_bloc.dart';

class CourseEnrollmentPage extends StatefulWidget {
  const CourseEnrollmentPage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<CourseEnrollmentPage> createState() => _CourseEnrollmentPageState();
}

class _CourseEnrollmentPageState extends State<CourseEnrollmentPage> {
  CourseEntity? _course;
  String? _selectedPaymentMethod;
  bool _agreeToTerms = false;
  bool _isProcessing = false;

  final List<_PaymentMethod> _paymentMethods = [
    const _PaymentMethod(
      id: 'mada',
      name: 'مدى',
      icon: Iconsax.card,
      description: 'الدفع ببطاقة مدى',
    ),
    const _PaymentMethod(
      id: 'visa',
      name: 'Visa / Mastercard',
      icon: Iconsax.card_pos,
      description: 'بطاقات الائتمان والخصم',
    ),
    const _PaymentMethod(
      id: 'apple_pay',
      name: 'Apple Pay',
      icon: Iconsax.wallet_3,
      description: 'الدفع عبر Apple Pay',
    ),
    const _PaymentMethod(
      id: 'stc_pay',
      name: 'STC Pay',
      icon: Iconsax.mobile,
      description: 'الدفع عبر STC Pay',
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadCourseDetails(courseId: widget.courseId));
  }

  void _processEnrollment() {
    if (_course == null) return;

    if (_course!.isFree || _course!.price == 0) {
      // Free course - enroll directly
      context.read<StudentBloc>().add(EnrollInCourse(courseId: widget.courseId));
    } else {
      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار طريقة الدفع'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب الموافقة على الشروط والأحكام'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() => _isProcessing = true);

      // TODO: Process payment and get paymentId
      // For now, simulate payment
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.read<StudentBloc>().add(
                EnrollInCourse(
                  courseId: widget.courseId,
                  paymentId: 'simulated_payment_${DateTime.now().millisecondsSinceEpoch}',
                ),
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<CourseBloc, CourseState>(
          listener: (context, state) {
            if (state is CourseDetailsLoaded) {
              setState(() => _course = state.course);
            }
          },
        ),
        BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is EnrollmentSuccess) {
              setState(() => _isProcessing = false);
              _showSuccessDialog();
            } else if (state is StudentError) {
              setState(() => _isProcessing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: GlassAppBar(
          title: 'إتمام الاشتراك',
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_1),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_course == null) {
              return const Center(child: Text('لم يتم العثور على الدورة'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Summary
                  _buildCourseSummary(theme),

                  const SizedBox(height: AppConstants.spacingMedium),

                  // Price Breakdown
                  _buildPriceBreakdown(theme),

                  if (!_course!.isFree && _course!.price > 0) ...[
                    const SizedBox(height: AppConstants.spacingMedium),

                    // Payment Methods
                    _buildPaymentMethods(theme),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Terms and conditions
                    _buildTermsCheckbox(theme),
                  ],

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Enroll Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isProcessing ? null : _processEnrollment,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _course!.isFree || _course!.price == 0
                                  ? 'اشترك مجاناً'
                                  : 'ادفع الآن ${_course!.formattedPrice}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingMedium),

                  // Security note
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.shield_tick, color: AppColors.success),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: Text(
                            'جميع عمليات الدفع مشفرة ومؤمنة',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingLarge),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseSummary(ThemeData theme) {
    return GlassCard(
      intensity: GlassIntensity.light,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            child: _course!.thumbnailUrl != null
                ? Image.network(
                    _course!.thumbnailUrl!,
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(),
                  )
                : _buildThumbnailPlaceholder(),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _course!.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingExtraSmall),
                if (_course!.instructor != null)
                  Text(
                    _course!.instructor!.fullName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  children: [
                    Icon(Iconsax.video, size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      '${_course!.lessonCount} درس',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Icon(Iconsax.clock, size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      _course!.formattedDuration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: const Icon(Iconsax.book_1, color: Colors.white),
    );
  }

  Widget _buildPriceBreakdown(ThemeData theme) {
    final price = _course!.price;
    final isFree = _course!.isFree || price == 0;

    return GlassPanel(
      title: 'ملخص الطلب',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سعر الدورة', style: theme.textTheme.bodyMedium),
              Text(
                isFree ? 'مجاني' : '${price.toStringAsFixed(0)} ر.س',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          if (!isFree) ...[
            const SizedBox(height: AppConstants.spacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الضريبة (15%)', style: theme.textTheme.bodyMedium),
                Text(
                  '${(price * 0.15).toStringAsFixed(0)} ر.س',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          const Divider(height: AppConstants.spacingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isFree ? 'مجاني' : '${(price * 1.15).toStringAsFixed(0)} ر.س',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(ThemeData theme) {
    return GlassPanel(
      title: 'طريقة الدفع',
      intensity: GlassIntensity.light,
      child: Column(
        children: _paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method.id;
          return InkWell(
            onTap: () => setState(() => _selectedPaymentMethod = method.id),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingSmall),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryLighter.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Icon(
                      method.icon,
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          method.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<String>(
                    value: method.id,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTermsCheckbox(ThemeData theme) {
    return CheckboxListTile(
      value: _agreeToTerms,
      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'أوافق على '),
            TextSpan(
              text: 'شروط الاستخدام',
              style: TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' و '),
            TextSpan(
              text: 'سياسة الاسترداد',
              style: TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
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
              'تم الاشتراك بنجاح!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'يمكنك الآن البدء في تعلم الدورة',
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
                context.go(
                  '${RouteNames.courses}/${widget.courseId}',
                );
              },
              child: const Text('ابدأ التعلم'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  final String id;
  final String name;
  final IconData icon;
  final String description;
}
