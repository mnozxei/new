import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _jobTitleController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Edit Profile',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
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
                  GlassCard(
                    intensity: GlassIntensity.light,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Basic Information',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        GlassTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          prefixIcon: const Icon(Iconsax.user),
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        GlassTextField(
                          controller: _jobTitleController,
                          label: 'Job Title',
                          hint: 'e.g. Software Engineer',
                          prefixIcon: const Icon(Iconsax.briefcase),
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        GlassTextField(
                          controller: _locationController,
                          label: 'Location',
                          hint: 'e.g. Riyadh, Saudi Arabia',
                          prefixIcon: const Icon(Iconsax.location),
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        GlassTextField(
                          controller: _bioController,
                          label: 'Bio',
                          hint: 'Tell us about yourself',
                          maxLines: 4,
                          prefixIcon: const Icon(Iconsax.document_text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassCard(
                    intensity: GlassIntensity.light,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Contact Information',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        GlassTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+966 5XX XXX XXXX',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Iconsax.call),
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        GlassTextField(
                          controller: _websiteController,
                          label: 'Website',
                          hint: 'https://yourwebsite.com',
                          keyboardType: TextInputType.url,
                          prefixIcon: const Icon(Iconsax.global),
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

  Widget _buildAvatarSection() {
    return Center(
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
            child: const CircleAvatar(
              radius: 56,
              backgroundColor: AppColors.primaryLighter,
              child: Icon(
                Iconsax.user,
                size: 48,
                color: AppColors.white,
              ),
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
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.pop();
    }
  }
}
