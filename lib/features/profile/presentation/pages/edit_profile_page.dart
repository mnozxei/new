import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _industryController = TextEditingController();

  File? _selectedImage;
  String? _avatarUrl;
  List<String> _skills = [];
  final _skillController = TextEditingController();
  bool _isLoading = false;

  static const List<String> _industries = [
    'تقنية المعلومات',
    'الاتصالات',
    'التعليم',
    'الصحة',
    'المالية والبنوك',
    'التجارة الإلكترونية',
    'التصنيع',
    'الطاقة',
    'العقارات',
    'النقل والخدمات اللوجستية',
    'الإعلام والترفيه',
    'السياحة والضيافة',
    'الأغذية والمشروبات',
    'الزراعة',
    'القانون',
    'الاستشارات',
    'التصميم والفنون',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final profile = state.profile;
      _fullNameController.text = profile.fullName ?? '';
      _headlineController.text = profile.headline ?? profile.jobTitle ?? '';
      _bioController.text = profile.bio ?? '';
      _jobTitleController.text = profile.jobTitle ?? '';
      _cityController.text = profile.city ?? '';
      _locationController.text = profile.location ?? '';
      _websiteController.text = profile.website ?? '';
      _phoneController.text = profile.phone ?? '';
      _industryController.text = profile.industry ?? '';
      _avatarUrl = profile.avatarUrl;
      _skills = List.from(profile.skills);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _jobTitleController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _industryController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && _isLoading) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
          );
          context.pop();
        } else if (state is ProfileError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: GlassAppBar(
          title: 'تعديل الملف الشخصي',
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('حفظ'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: AppConstants.spacingLarge),
                    // Basic Information
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionHeader(
                            theme,
                            'المعلومات الأساسية',
                            Iconsax.user,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _fullNameController,
                            label: 'الاسم الكامل *',
                            hint: 'أدخل اسمك الكامل',
                            prefixIcon: const Icon(Iconsax.user),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الاسم الكامل مطلوب';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _headlineController,
                            label: 'العنوان المهني',
                            hint: 'مثال: مهندس برمجيات | خبير في Flutter',
                            prefixIcon: const Icon(Iconsax.tag),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _jobTitleController,
                            label: 'المسمى الوظيفي',
                            hint: 'مثال: مهندس برمجيات',
                            prefixIcon: const Icon(Iconsax.briefcase),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _bioController,
                            label: 'نبذة عنك',
                            hint: 'اكتب نبذة مختصرة عن نفسك وخبراتك...',
                            maxLines: 4,
                            prefixIcon: const Icon(Iconsax.document_text),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Location & Industry
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionHeader(
                            theme,
                            'الموقع والمجال',
                            Iconsax.location,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _cityController,
                            label: 'المدينة',
                            hint: 'مثال: الرياض',
                            prefixIcon: const Icon(Iconsax.buildings),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _locationController,
                            label: 'الموقع الكامل',
                            hint: 'مثال: الرياض، المملكة العربية السعودية',
                            prefixIcon: const Icon(Iconsax.location),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          _buildIndustryDropdown(theme, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Skills
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionHeader(
                            theme,
                            'المهارات',
                            Iconsax.cpu,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          _buildSkillsInput(theme, isDark),
                          if (_skills.isNotEmpty) ...[
                            const SizedBox(height: AppConstants.spacingMedium),
                            _buildSkillsChips(theme),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Contact Information
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionHeader(
                            theme,
                            'معلومات التواصل',
                            Iconsax.call,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _phoneController,
                            label: 'رقم الهاتف',
                            hint: '+966 5XX XXX XXXX',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Iconsax.call),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            controller: _websiteController,
                            label: 'الموقع الإلكتروني',
                            hint: 'https://yourwebsite.com',
                            keyboardType: TextInputType.url,
                            prefixIcon: const Icon(Iconsax.global),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingExtraLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppConstants.spacingSmall),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.primaryLighter,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
                child: _selectedImage == null && _avatarUrl == null
                    ? const Icon(
                        Iconsax.user,
                        size: 48,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.camera,
                  size: 20,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustryDropdown(ThemeData theme, bool isDark) {
    return DropdownButtonFormField<String>(
      value: _industryController.text.isEmpty ? null : _industryController.text,
      decoration: InputDecoration(
        labelText: 'مجال العمل',
        prefixIcon: const Icon(Iconsax.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _industries.map((industry) {
        return DropdownMenuItem(
          value: industry,
          child: Text(industry),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _industryController.text = value ?? '';
        });
      },
    );
  }

  Widget _buildSkillsInput(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GlassTextField(
            controller: _skillController,
            label: 'أضف مهارة',
            hint: 'مثال: Flutter',
            prefixIcon: const Icon(Iconsax.add_circle),
            onSubmitted: (_) => _addSkill(),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        IconButton(
          onPressed: _addSkill,
          icon: const Icon(Iconsax.add_circle),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSkillsChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skills.map((skill) {
        return Chip(
          label: Text(skill),
          deleteIcon: const Icon(Iconsax.close_circle, size: 18),
          onDeleted: () => _removeSkill(skill),
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded) {
        final updatedProfile = state.profile.copyWith(
          fullName: _fullNameController.text.trim().isEmpty
              ? null
              : _fullNameController.text.trim(),
          headline: _headlineController.text.trim().isEmpty
              ? null
              : _headlineController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          jobTitle: _jobTitleController.text.trim().isEmpty
              ? null
              : _jobTitleController.text.trim(),
          city: _cityController.text.trim().isEmpty
              ? null
              : _cityController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          industry: _industryController.text.trim().isEmpty
              ? null
              : _industryController.text.trim(),
          skills: _skills,
        );

        context.read<ProfileBloc>().add(ProfileUpdateRequested(updatedProfile));
      }
    }
  }
}
