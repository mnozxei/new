import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';

class ExperienceEditorPage extends StatefulWidget {
  const ExperienceEditorPage({
    super.key,
    this.experienceId,
  });

  final String? experienceId;

  bool get isEditing => experienceId != null;

  @override
  State<ExperienceEditorPage> createState() => _ExperienceEditorPageState();
}

class _ExperienceEditorPageState extends State<ExperienceEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isLoading = false;

  ExperienceEntity? _existingExperience;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingExperience();
    }
  }

  void _loadExistingExperience() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _existingExperience = state.experiences.firstWhere(
        (e) => e.id == widget.experienceId,
        orElse: () => throw Exception('Experience not found'),
      );

      _titleController.text = _existingExperience!.title;
      _companyController.text = _existingExperience!.company;
      _locationController.text = _existingExperience!.location ?? '';
      _descriptionController.text = _existingExperience!.description ?? '';
      _startDate = _existingExperience!.startDate;
      _endDate = _existingExperience!.endDate;
      _isCurrent = _existingExperience!.isCurrent;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? _startDate ?? DateTime.now()
        : _endDate ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: isStartDate ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية',
      confirmText: 'اختر',
      cancelText: 'إلغاء',
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار تاريخ البداية')),
        );
        return;
      }

      if (!_isCurrent && _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار تاريخ النهاية أو تحديد أنها الوظيفة الحالية')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final experience = ExperienceEntity(
        id: widget.isEditing ? widget.experienceId! : const Uuid().v4(),
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _isCurrent ? null : _endDate,
        isCurrent: _isCurrent,
      );

      if (widget.isEditing) {
        context.read<ProfileBloc>().add(ExperienceUpdateRequested(experience));
      } else {
        context.read<ProfileBloc>().add(ExperienceAddRequested(experience));
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: GlassAppBar(
        title: widget.isEditing ? 'تعديل الخبرة' : 'إضافة خبرة',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSubmit,
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
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                intensity: GlassIntensity.light,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الوظيفة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'المسمى الوظيفي *',
                        hintText: 'مثال: مهندس برمجيات',
                        prefixIcon: Icon(Iconsax.briefcase),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'المسمى الوظيفي مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الشركة *',
                        hintText: 'مثال: شركة تقنية',
                        prefixIcon: Icon(Iconsax.building_3),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'اسم الشركة مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'الموقع',
                        hintText: 'مثال: الرياض، السعودية',
                        prefixIcon: Icon(Iconsax.location),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              GlassCard(
                intensity: GlassIntensity.light,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فترة العمل',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.spacingMedium),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.calendar_1,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: AppConstants.spacingSmall),
                            Expanded(
                              child: Text(
                                _startDate != null
                                    ? '${_startDate!.month}/${_startDate!.year}'
                                    : 'تاريخ البداية *',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _startDate == null
                                      ? (isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight)
                                      : null,
                                ),
                              ),
                            ),
                            Icon(
                              Iconsax.arrow_down_1,
                              size: 18,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    CheckboxListTile(
                      value: _isCurrent,
                      onChanged: (value) {
                        setState(() {
                          _isCurrent = value ?? false;
                          if (_isCurrent) {
                            _endDate = null;
                          }
                        });
                      },
                      title: const Text('هذه وظيفتي الحالية'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!_isCurrent) ...[
                      const SizedBox(height: AppConstants.spacingSmall),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.spacingMedium),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.calendar_1,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: AppConstants.spacingSmall),
                              Expanded(
                                child: Text(
                                  _endDate != null
                                      ? '${_endDate!.month}/${_endDate!.year}'
                                      : 'تاريخ النهاية *',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: _endDate == null
                                        ? (isDark
                                            ? AppColors.textTertiaryDark
                                            : AppColors.textTertiaryLight)
                                        : null,
                                  ),
                                ),
                              ),
                              Icon(
                                Iconsax.arrow_down_1,
                                size: 18,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              GlassCard(
                intensity: GlassIntensity.light,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وصف الوظيفة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'وصف المهام والإنجازات',
                        hintText: 'صف مسؤولياتك وإنجازاتك في هذه الوظيفة...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingSmall,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(widget.isEditing ? 'حفظ التغييرات' : 'إضافة الخبرة'),
                ),
              ),
              const SizedBox(height: AppConstants.spacingExtraLarge),
            ],
          ),
        ),
      ),
    );
  }
}
