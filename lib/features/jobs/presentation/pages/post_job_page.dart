import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/injection/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../bloc/job_bloc.dart';

class PostJobPage extends StatelessWidget {
  const PostJobPage({
    this.companyId,
    super.key,
  });

  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>(),
      child: _PostJobContent(companyId: companyId),
    );
  }
}

class _PostJobContent extends StatefulWidget {
  const _PostJobContent({this.companyId});

  final String? companyId;

  @override
  State<_PostJobContent> createState() => _PostJobContentState();
}

class _PostJobContentState extends State<_PostJobContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _vacancyCountController = TextEditingController(text: '1');
  final _experienceMinController = TextEditingController(text: '0');
  final _experienceMaxController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _tagsController = TextEditingController();

  JobType _selectedJobType = JobType.fullTime;
  ExperienceLevel _selectedExperienceLevel = ExperienceLevel.mid;
  LocationType _selectedLocationType = LocationType.onsite;
  bool _showSalary = true;
  bool _isSubmitting = false;
  DateTime? _applicationDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _responsibilitiesController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _vacancyCountController.dispose();
    _experienceMinController.dispose();
    _experienceMaxController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _benefitsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _applicationDeadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _applicationDeadline = picked;
      });
    }
  }

  void _submitJob({bool isDraft = false}) {
    if (!_formKey.currentState!.validate()) return;

    if (widget.companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تحديد الشركة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final params = CreateJobParams(
      companyId: widget.companyId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      requirements: _requirementsController.text.trim().isEmpty
          ? null
          : _requirementsController.text.trim(),
      responsibilities: _responsibilitiesController.text.trim().isEmpty
          ? null
          : _responsibilitiesController.text.trim(),
      jobType: _selectedJobType,
      experienceLevel: _selectedExperienceLevel,
      locationType: _selectedLocationType,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      isRemote: _selectedLocationType == LocationType.remote,
      salaryMin: _salaryMinController.text.isNotEmpty
          ? double.tryParse(_salaryMinController.text)
          : null,
      salaryMax: _salaryMaxController.text.isNotEmpty
          ? double.tryParse(_salaryMaxController.text)
          : null,
      showSalary: _showSalary,
      experienceYearsMin: int.tryParse(_experienceMinController.text) ?? 0,
      experienceYearsMax: _experienceMaxController.text.isNotEmpty
          ? int.tryParse(_experienceMaxController.text)
          : null,
      educationLevel: _educationController.text.trim().isEmpty
          ? null
          : _educationController.text.trim(),
      skillsRequired: _skillsController.text.trim().isEmpty
          ? []
          : _skillsController.text.split(',').map((e) => e.trim()).toList(),
      benefits: _benefitsController.text.trim().isEmpty
          ? []
          : _benefitsController.text.split(',').map((e) => e.trim()).toList(),
      tags: _tagsController.text.trim().isEmpty
          ? []
          : _tagsController.text.split(',').map((e) => e.trim()).toList(),
      vacancyCount: int.tryParse(_vacancyCountController.text) ?? 1,
      applicationDeadline: _applicationDeadline,
      isDraft: isDraft,
    );

    context.read<JobBloc>().add(CreateJob(params: params));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobCreated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.job.status == JobStatus.draft
                    ? 'تم حفظ المسودة بنجاح'
                    : 'تم نشر الوظيفة بنجاح',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
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
      child: Scaffold(
        appBar: GlassAppBar(
          title: 'نشر وظيفة',
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_1),
            onPressed: () => context.pop(),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : () => _submitJob(isDraft: true),
              child: const Text('حفظ كمسودة'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Basic Information
                    GlassPanel(
                      title: 'المعلومات الأساسية',
                      intensity: GlassIntensity.light,
                      child: Column(
                        children: [
                          GlassTextField(
                            label: 'عنوان الوظيفة *',
                            hint: 'مثال: مهندس برمجيات أول',
                            controller: _titleController,
                            prefixIcon: const Icon(Iconsax.briefcase),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال عنوان الوظيفة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Row(
                            children: [
                              Expanded(
                                child: GlassDropdownField<JobType>(
                                  label: 'نوع العمل *',
                                  hint: 'اختر نوع العمل',
                                  value: _selectedJobType,
                                  items: JobType.values,
                                  itemBuilder: (type) => Text(type.label),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedJobType = value);
                                    }
                                  },
                                  prefixIcon: const Icon(Iconsax.clock),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: GlassDropdownField<LocationType>(
                                  label: 'نوع الموقع *',
                                  hint: 'اختر نوع الموقع',
                                  value: _selectedLocationType,
                                  items: LocationType.values,
                                  itemBuilder: (type) => Text(type.label),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedLocationType = value);
                                    }
                                  },
                                  prefixIcon: const Icon(Iconsax.building),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Row(
                            children: [
                              Expanded(
                                child: GlassTextField(
                                  label: 'المدينة',
                                  hint: 'مثال: الرياض',
                                  controller: _cityController,
                                  prefixIcon: const Icon(Iconsax.location),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: GlassTextField(
                                  label: 'العنوان',
                                  hint: 'مثال: حي العليا',
                                  controller: _locationController,
                                  prefixIcon: const Icon(Iconsax.location),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Job Details
                    GlassPanel(
                      title: 'تفاصيل الوظيفة',
                      intensity: GlassIntensity.light,
                      child: Column(
                        children: [
                          GlassTextField(
                            label: 'وصف الوظيفة *',
                            hint: 'اكتب وصفاً تفصيلياً للوظيفة...',
                            controller: _descriptionController,
                            maxLines: 6,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال وصف الوظيفة';
                              }
                              if (value.trim().length < 50) {
                                return 'يجب أن يكون الوصف 50 حرف على الأقل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            label: 'المتطلبات',
                            hint: 'اكتب كل متطلب في سطر جديد...',
                            controller: _requirementsController,
                            maxLines: 5,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            label: 'المسؤوليات',
                            hint: 'اكتب كل مسؤولية في سطر جديد...',
                            controller: _responsibilitiesController,
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Experience & Education
                    GlassPanel(
                      title: 'الخبرة والتعليم',
                      intensity: GlassIntensity.light,
                      child: Column(
                        children: [
                          GlassDropdownField<ExperienceLevel>(
                            label: 'مستوى الخبرة *',
                            hint: 'اختر مستوى الخبرة',
                            value: _selectedExperienceLevel,
                            items: ExperienceLevel.values,
                            itemBuilder: (level) => Text(level.label),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedExperienceLevel = value);
                              }
                            },
                            prefixIcon: const Icon(Iconsax.chart),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Row(
                            children: [
                              Expanded(
                                child: GlassTextField(
                                  label: 'الحد الأدنى للخبرة (سنوات)',
                                  hint: '0',
                                  controller: _experienceMinController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Iconsax.calendar),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: GlassTextField(
                                  label: 'الحد الأقصى للخبرة (سنوات)',
                                  hint: 'اختياري',
                                  controller: _experienceMaxController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Iconsax.calendar),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            label: 'المستوى التعليمي',
                            hint: 'مثال: بكالوريوس في علوم الحاسب',
                            controller: _educationController,
                            prefixIcon: const Icon(Iconsax.teacher),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Compensation
                    GlassPanel(
                      title: 'الراتب والمزايا',
                      intensity: GlassIntensity.light,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GlassTextField(
                                  label: 'الحد الأدنى للراتب',
                                  hint: '10000',
                                  controller: _salaryMinController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Iconsax.money),
                                  suffix: const Text('ر.س'),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: GlassTextField(
                                  label: 'الحد الأقصى للراتب',
                                  hint: '20000',
                                  controller: _salaryMaxController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Iconsax.money),
                                  suffix: const Text('ر.س'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          CheckboxListTile(
                            value: _showSalary,
                            onChanged: (value) {
                              setState(() => _showSalary = value ?? true);
                            },
                            title: const Text('عرض الراتب للمتقدمين'),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            label: 'المزايا',
                            hint: 'افصل بين المزايا بفاصلة (تأمين طبي، بدل سكن، ...)',
                            controller: _benefitsController,
                            prefixIcon: const Icon(Iconsax.gift),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Skills & Tags
                    GlassPanel(
                      title: 'المهارات والكلمات المفتاحية',
                      intensity: GlassIntensity.light,
                      child: Column(
                        children: [
                          GlassTextField(
                            label: 'المهارات المطلوبة',
                            hint: 'افصل بين المهارات بفاصلة (Flutter, Dart, Firebase, ...)',
                            controller: _skillsController,
                            prefixIcon: const Icon(Iconsax.code),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          GlassTextField(
                            label: 'الكلمات المفتاحية (Tags)',
                            hint: 'افصل بين الكلمات بفاصلة',
                            controller: _tagsController,
                            prefixIcon: const Icon(Iconsax.tag),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Application Settings
                    GlassPanel(
                      title: 'إعدادات التقديم',
                      intensity: GlassIntensity.light,
                      child: Column(
                        children: [
                          GlassTextField(
                            label: 'عدد الشواغر *',
                            hint: '1',
                            controller: _vacancyCountController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Iconsax.people),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال عدد الشواغر';
                              }
                              final count = int.tryParse(value);
                              if (count == null || count < 1) {
                                return 'يجب أن يكون عدد الشواغر 1 على الأقل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          InkWell(
                            onTap: _selectDeadline,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'آخر موعد للتقديم',
                                prefixIcon: const Icon(Iconsax.calendar),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusMedium,
                                  ),
                                ),
                              ),
                              child: Text(
                                _applicationDeadline != null
                                    ? '${_applicationDeadline!.day}/${_applicationDeadline!.month}/${_applicationDeadline!.year}'
                                    : 'اختر التاريخ (اختياري)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _applicationDeadline != null
                                      ? null
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingLarge),

                    // Submit Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () => _submitJob(),
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
                        label: Text(_isSubmitting ? 'جاري النشر...' : 'نشر الوظيفة'),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
