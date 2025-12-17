import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';

class PostJobPage extends StatelessWidget {
  const PostJobPage({
    this.companyId,
    super.key,
  });

  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'Post a Job',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassPanel(
                  title: 'Basic Information',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: [
                      GlassTextField(
                        label: 'Job Title',
                        hint: 'e.g. Senior Software Engineer',
                        prefixIcon: const Icon(Iconsax.briefcase),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      GlassDropdownField<String>(
                        label: 'Company',
                        hint: 'Select company',
                        items: const ['Company A', 'Company B', 'Company C'],
                        onChanged: (value) {},
                        prefixIcon: const Icon(Iconsax.building),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      GlassDropdownField<String>(
                        label: 'Job Type',
                        hint: 'Select job type',
                        items: const ['Full-time', 'Part-time', 'Contract', 'Remote'],
                        onChanged: (value) {},
                        prefixIcon: const Icon(Iconsax.clock),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      GlassTextField(
                        label: 'Location',
                        hint: 'e.g. Riyadh, Saudi Arabia',
                        prefixIcon: const Icon(Iconsax.location),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassPanel(
                  title: 'Job Details',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: [
                      GlassTextField(
                        label: 'Description',
                        hint: 'Describe the job role and responsibilities...',
                        maxLines: 6,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      GlassTextField(
                        label: 'Requirements',
                        hint: 'List the job requirements...',
                        maxLines: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassPanel(
                  title: 'Compensation',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GlassTextField(
                              label: 'Minimum Salary',
                              hint: '10000',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Iconsax.money),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingMedium),
                          Expanded(
                            child: GlassTextField(
                              label: 'Maximum Salary',
                              hint: '20000',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Iconsax.money),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      GlassTextField(
                        label: 'Number of Vacancies',
                        hint: '1',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Iconsax.people),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Post Job'),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
