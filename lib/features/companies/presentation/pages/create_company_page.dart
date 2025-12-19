import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';

class CreateCompanyPage extends StatefulWidget {
  const CreateCompanyPage({super.key});

  @override
  State<CreateCompanyPage> createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedIndustry;
  String? _selectedSize;
  String? _logoPath;

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في اختيار الصورة')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileCreateCompanyPage(
        formKey: _formKey,
        nameController: _nameController,
        descriptionController: _descriptionController,
        websiteController: _websiteController,
        emailController: _emailController,
        phoneController: _phoneController,
        addressController: _addressController,
        selectedIndustry: _selectedIndustry,
        selectedSize: _selectedSize,
        onIndustryChanged: (value) => setState(() => _selectedIndustry = value),
        onSizeChanged: (value) => setState(() => _selectedSize = value),
      ),
      desktop: _DesktopCreateCompanyPage(
        formKey: _formKey,
        nameController: _nameController,
        descriptionController: _descriptionController,
        websiteController: _websiteController,
        emailController: _emailController,
        phoneController: _phoneController,
        addressController: _addressController,
        selectedIndustry: _selectedIndustry,
        selectedSize: _selectedSize,
        onIndustryChanged: (value) => setState(() => _selectedIndustry = value),
        onSizeChanged: (value) => setState(() => _selectedSize = value),
      ),
    );
  }
}

class _MobileCreateCompanyPage extends StatelessWidget {
  const _MobileCreateCompanyPage({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.websiteController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.selectedIndustry,
    required this.selectedSize,
    required this.onIndustryChanged,
    required this.onSizeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController websiteController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final String? selectedIndustry;
  final String? selectedSize;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<String?> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'إضافة شركة',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoUpload(),
              const SizedBox(height: AppConstants.spacingLarge),
              _FormFields(
                nameController: nameController,
                descriptionController: descriptionController,
                websiteController: websiteController,
                emailController: emailController,
                phoneController: phoneController,
                addressController: addressController,
                selectedIndustry: selectedIndustry,
                selectedSize: selectedSize,
                onIndustryChanged: onIndustryChanged,
                onSizeChanged: onSizeChanged,
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      // TODO: Save company
                      context.pop();
                    }
                  },
                  child: Text('حفظ الشركة', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopCreateCompanyPage extends StatelessWidget {
  const _DesktopCreateCompanyPage({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.websiteController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.selectedIndustry,
    required this.selectedSize,
    required this.onIndustryChanged,
    required this.onSizeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController websiteController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final String? selectedIndustry;
  final String? selectedSize;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<String?> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: 700,
          margin: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                      Text('إضافة شركة جديدة', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  GlassCard(
                    intensity: GlassIntensity.light,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LogoUpload(),
                        const SizedBox(height: AppConstants.spacingLarge),
                        _FormFields(
                          nameController: nameController,
                          descriptionController: descriptionController,
                          websiteController: websiteController,
                          emailController: emailController,
                          phoneController: phoneController,
                          addressController: addressController,
                          selectedIndustry: selectedIndustry,
                          selectedSize: selectedSize,
                          onIndustryChanged: onIndustryChanged,
                          onSizeChanged: onSizeChanged,
                        ),
                        const SizedBox(height: AppConstants.spacingLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('إلغاء'),
                            ),
                            const SizedBox(width: AppConstants.spacingMedium),
                            GlassButton(
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  // TODO: Save company
                                  context.pop();
                                }
                              },
                              child: Text('حفظ الشركة', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoUpload extends StatefulWidget {
  const _LogoUpload();

  @override
  State<_LogoUpload> createState() => _LogoUploadState();
}

class _LogoUploadState extends State<_LogoUpload> {
  final _imagePicker = ImagePicker();
  String? _logoPath;

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في اختيار الصورة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _logoPath != null ? AppColors.white : AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              border: Border.all(color: AppColors.primaryLighter, width: 2, style: BorderStyle.solid),
              image: _logoPath != null
                  ? DecorationImage(
                      image: AssetImage(_logoPath!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: InkWell(
              onTap: _pickLogo,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              child: _logoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.camera, size: 32, color: AppColors.primaryLighter),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Text('شعار الشركة', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryLighter)),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      ),
                      child: const Icon(Iconsax.edit, size: 24, color: AppColors.white),
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            _logoPath != null ? 'اضغط لتغيير الشعار' : 'اضغط لرفع الشعار',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }
}

class _FormFields extends StatelessWidget {
  const _FormFields({
    required this.nameController,
    required this.descriptionController,
    required this.websiteController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.selectedIndustry,
    required this.selectedSize,
    required this.onIndustryChanged,
    required this.onSizeChanged,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController websiteController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final String? selectedIndustry;
  final String? selectedSize;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<String?> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المعلومات الأساسية', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.spacingMedium),
        GlassTextField(
          controller: nameController,
          labelText: 'اسم الشركة',
          hintText: 'أدخل اسم الشركة',
          prefixIcon: const Icon(Iconsax.building),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال اسم الشركة';
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        GlassTextField(
          controller: descriptionController,
          labelText: 'وصف الشركة',
          hintText: 'أدخل وصفاً مختصراً للشركة',
          maxLines: 4,
          minLines: 3,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        _DropdownField(
          label: 'القطاع',
          hint: 'اختر قطاع الشركة',
          value: selectedIndustry,
          items: const ['تقنية المعلومات', 'الصحة', 'التعليم', 'المالية', 'الإنشاءات', 'التجزئة', 'الصناعة', 'أخرى'],
          onChanged: onIndustryChanged,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        _DropdownField(
          label: 'حجم الشركة',
          hint: 'اختر حجم الشركة',
          value: selectedSize,
          items: const ['1-10 موظفين', '11-50 موظف', '51-200 موظف', '201-500 موظف', '500+ موظف'],
          onChanged: onSizeChanged,
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        Text('معلومات التواصل', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.spacingMedium),
        GlassTextField(
          controller: websiteController,
          labelText: 'الموقع الإلكتروني',
          hintText: 'www.example.com',
          prefixIcon: const Icon(Iconsax.global),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        GlassTextField(
          controller: emailController,
          labelText: 'البريد الإلكتروني',
          hintText: 'info@example.com',
          prefixIcon: const Icon(Iconsax.sms),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!value.contains('@')) {
              return 'يرجى إدخال بريد إلكتروني صحيح';
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        GlassTextField(
          controller: phoneController,
          labelText: 'رقم الهاتف',
          hintText: '+966 XX XXX XXXX',
          prefixIcon: const Icon(Iconsax.call),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        GlassTextField(
          controller: addressController,
          labelText: 'العنوان',
          hintText: 'أدخل عنوان الشركة',
          prefixIcon: const Icon(Iconsax.location),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: AppConstants.spacingSmall),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(hint),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
                vertical: AppConstants.spacingSmall,
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
