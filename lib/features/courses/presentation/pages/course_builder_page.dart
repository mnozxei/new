import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/instructor_bloc.dart';

class CourseBuilderPage extends StatefulWidget {
  const CourseBuilderPage({
    super.key,
    this.courseId,
  });

  /// If provided, we're editing an existing course
  final String? courseId;

  @override
  State<CourseBuilderPage> createState() => _CourseBuilderPageState();
}

class _CourseBuilderPageState extends State<CourseBuilderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _priceController = TextEditingController();

  CourseLevel _selectedLevel = CourseLevel.beginner;
  String? _selectedCategory;
  bool _isFree = false;
  String _language = 'ar';

  // Course content
  List<_SectionData> _sections = [];

  // Requirements & Objectives
  List<String> _requirements = [];
  List<String> _objectives = [];
  List<String> _tags = [];

  final _requirementController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _tagController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.courseId != null;

  final List<String> _categories = [
    'البرمجة والتطوير',
    'التصميم والجرافيك',
    'التسويق الرقمي',
    'إدارة الأعمال',
    'اللغات',
    'المحاسبة والمالية',
    'تطوير الذات',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (_isEditing) {
      _loadCourse();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _priceController.dispose();
    _requirementController.dispose();
    _objectiveController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    // TODO: Load course data from bloc
  }

  void _addSection() {
    setState(() {
      _sections.add(_SectionData(
        title: 'قسم جديد ${_sections.length + 1}',
        lessons: [],
      ));
    });
  }

  void _addLesson(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].lessons.add(_LessonData(
        title: 'درس جديد ${_sections[sectionIndex].lessons.length + 1}',
      ));
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
    });
  }

  void _removeLesson(int sectionIndex, int lessonIndex) {
    setState(() {
      _sections[sectionIndex].lessons.removeAt(lessonIndex);
    });
  }

  void _addRequirement() {
    if (_requirementController.text.isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text);
        _requirementController.clear();
      });
    }
  }

  void _addObjective() {
    if (_objectiveController.text.isNotEmpty) {
      setState(() {
        _objectives.add(_objectiveController.text);
        _objectiveController.clear();
      });
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty && _tags.length < 10) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    setState(() => _isLoading = true);

    final params = CreateCourseParams(
      title: _titleController.text,
      description: _descriptionController.text,
      shortDescription: _shortDescriptionController.text,
      level: _selectedLevel,
      category: _selectedCategory,
      language: _language,
      price: double.tryParse(_priceController.text) ?? 0,
      isFree: _isFree,
      requirements: _requirements,
      objectives: _objectives,
      tags: _tags,
    );

    if (_isEditing) {
      context.read<InstructorBloc>().add(UpdateCourse(
            courseId: widget.courseId!,
            params: UpdateCourseParams(
              title: params.title,
              description: params.description,
              shortDescription: params.shortDescription,
              level: params.level,
              category: params.category,
              language: params.language,
              price: params.price,
              isFree: params.isFree,
              requirements: params.requirements,
              objectives: params.objectives,
              tags: params.tags,
            ),
          ));
    } else {
      context.read<InstructorBloc>().add(CreateCourse(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<InstructorBloc, InstructorState>(
      listener: (context, state) {
        if (state is CourseCreated || state is CourseUpdated) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'تم تحديث الدورة بنجاح'
                  : 'تم إنشاء الدورة بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state is InstructorError) {
          setState(() => _isLoading = false);
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
          title: _isEditing ? 'تعديل الدورة' : 'إنشاء دورة جديدة',
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_1),
            onPressed: () => context.pop(),
          ),
          actions: [
            TextButton.icon(
              onPressed: _isLoading ? null : _saveCourse,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Iconsax.tick_circle),
              label: Text(_isEditing ? 'حفظ' : 'إنشاء'),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'المعلومات الأساسية'),
              Tab(text: 'المحتوى'),
              Tab(text: 'المتطلبات والأهداف'),
              Tab(text: 'الإعدادات'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(theme),
              _buildContentTab(theme),
              _buildRequirementsTab(theme),
              _buildSettingsTab(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail upload
          GlassCard(
            intensity: GlassIntensity.light,
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.image,
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        'اضغط لرفع صورة الدورة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      Text(
                        'الحجم الموصى به: 1280x720 بكسل',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Title
          GlassPanel(
            title: 'عنوان الدورة *',
            intensity: GlassIntensity.light,
            child: TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'مثال: تعلم Flutter من الصفر للاحتراف',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'عنوان الدورة مطلوب';
                }
                if (value.length < 10) {
                  return 'العنوان قصير جداً';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Short Description
          GlassPanel(
            title: 'وصف مختصر *',
            intensity: GlassIntensity.light,
            child: TextFormField(
              controller: _shortDescriptionController,
              maxLines: 2,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: 'وصف موجز يظهر في البطاقات',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الوصف المختصر مطلوب';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Full Description
          GlassPanel(
            title: 'الوصف الكامل',
            intensity: GlassIntensity.light,
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'وصف تفصيلي للدورة ومحتواها...',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Category & Level
          Row(
            children: [
              Expanded(
                child: GlassPanel(
                  title: 'التصنيف *',
                  intensity: GlassIntensity.light,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('اختر'),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    validator: (value) {
                      if (value == null) return 'مطلوب';
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: GlassPanel(
                  title: 'المستوى',
                  intensity: GlassIntensity.light,
                  child: DropdownButtonFormField<CourseLevel>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: CourseLevel.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(_getLevelName(level)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLevel = value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildContentTab(ThemeData theme) {
    return Column(
      children: [
        // Add section button
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addSection,
              icon: const Icon(Iconsax.add),
              label: const Text('إضافة قسم جديد'),
            ),
          ),
        ),

        // Sections list
        Expanded(
          child: _sections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.folder_open,
                        size: 64,
                        color: AppColors.textTertiaryLight,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        'لا توجد أقسام بعد',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        'ابدأ بإضافة قسم جديد لتنظيم محتوى الدورة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
                  itemCount: _sections.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final section = _sections.removeAt(oldIndex);
                      _sections.insert(newIndex, section);
                    });
                  },
                  itemBuilder: (context, index) {
                    return _SectionCard(
                      key: ValueKey('section_$index'),
                      section: _sections[index],
                      index: index,
                      onAddLesson: () => _addLesson(index),
                      onRemove: () => _removeSection(index),
                      onRemoveLesson: (lessonIndex) =>
                          _removeLesson(index, lessonIndex),
                      onTitleChanged: (title) {
                        setState(() {
                          _sections[index].title = title;
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRequirementsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Requirements
          GlassPanel(
            title: 'متطلبات الدورة',
            trailing: Text(
              '${_requirements.length}/10',
              style: theme.textTheme.bodySmall,
            ),
            intensity: GlassIntensity.light,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _requirementController,
                        decoration: const InputDecoration(
                          hintText: 'مثال: معرفة أساسيات البرمجة',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _addRequirement(),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    IconButton.filled(
                      onPressed: _addRequirement,
                      icon: const Icon(Iconsax.add),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                ..._requirements.asMap().entries.map((entry) {
                  return _ListItem(
                    text: entry.value,
                    onRemove: () {
                      setState(() {
                        _requirements.removeAt(entry.key);
                      });
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Objectives
          GlassPanel(
            title: 'أهداف الدورة',
            trailing: Text(
              '${_objectives.length}/10',
              style: theme.textTheme.bodySmall,
            ),
            intensity: GlassIntensity.light,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _objectiveController,
                        decoration: const InputDecoration(
                          hintText: 'مثال: بناء تطبيقات Flutter احترافية',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _addObjective(),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    IconButton.filled(
                      onPressed: _addObjective,
                      icon: const Icon(Iconsax.add),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                ..._objectives.asMap().entries.map((entry) {
                  return _ListItem(
                    text: entry.value,
                    onRemove: () {
                      setState(() {
                        _objectives.removeAt(entry.key);
                      });
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Tags
          GlassPanel(
            title: 'الوسوم',
            trailing: Text(
              '${_tags.length}/10',
              style: theme.textTheme.bodySmall,
            ),
            intensity: GlassIntensity.light,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          hintText: 'أضف وسم...',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    IconButton.filled(
                      onPressed: _addTag,
                      icon: const Icon(Iconsax.add),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Wrap(
                  spacing: AppConstants.spacingSmall,
                  runSpacing: AppConstants.spacingSmall,
                  children: _tags.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      onDeleted: () {
                        setState(() {
                          _tags.removeAt(entry.key);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        children: [
          // Pricing
          GlassPanel(
            title: 'التسعير',
            intensity: GlassIntensity.light,
            child: Column(
              children: [
                SwitchListTile(
                  value: _isFree,
                  onChanged: (value) {
                    setState(() => _isFree = value);
                  },
                  title: const Text('دورة مجانية'),
                  subtitle: const Text('اجعل الدورة متاحة للجميع مجاناً'),
                  contentPadding: EdgeInsets.zero,
                ),
                if (!_isFree) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      suffixText: 'ر.س',
                    ),
                    validator: (value) {
                      if (!_isFree && (value == null || value.isEmpty)) {
                        return 'يرجى تحديد السعر';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Language
          GlassPanel(
            title: 'لغة الدورة',
            intensity: GlassIntensity.light,
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'ar',
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() => _language = value ?? 'ar');
                  },
                  title: const Text('العربية'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  value: 'en',
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() => _language = value ?? 'ar');
                  },
                  title: const Text('English'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingLarge),

          // Info note
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, color: AppColors.info),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: Text(
                    'يمكنك نشر الدورة بعد إضافة درس واحد على الأقل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.info,
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
  }

  String _getLevelName(CourseLevel level) {
    switch (level) {
      case CourseLevel.beginner:
        return 'مبتدئ';
      case CourseLevel.intermediate:
        return 'متوسط';
      case CourseLevel.advanced:
        return 'متقدم';
      case CourseLevel.allLevels:
        return 'جميع المستويات';
    }
  }
}

class _SectionData {
  _SectionData({
    required this.title,
    required this.lessons,
    this.description,
  });

  String title;
  String? description;
  List<_LessonData> lessons;
}

class _LessonData {
  _LessonData({
    required this.title,
    this.description,
    this.videoUrl,
    this.durationSeconds = 0,
    this.isFreePreview = false,
  });

  String title;
  String? description;
  String? videoUrl;
  int durationSeconds;
  bool isFreePreview;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    super.key,
    required this.section,
    required this.index,
    required this.onAddLesson,
    required this.onRemove,
    required this.onRemoveLesson,
    required this.onTitleChanged,
  });

  final _SectionData section;
  final int index;
  final VoidCallback onAddLesson;
  final VoidCallback onRemove;
  final void Function(int) onRemoveLesson;
  final void Function(String) onTitleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.menu_1, size: 20),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Text(
                  'القسم ${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, size: 20),
                onPressed: onRemove,
                color: AppColors.error,
              ),
            ],
          ),
          TextFormField(
            initialValue: section.title,
            decoration: const InputDecoration(
              hintText: 'عنوان القسم',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            onChanged: onTitleChanged,
          ),
          const Divider(),
          // Lessons
          ...section.lessons.asMap().entries.map((entry) {
            return _LessonItem(
              lesson: entry.value,
              index: entry.key,
              onRemove: () => onRemoveLesson(entry.key),
            );
          }),
          // Add lesson button
          TextButton.icon(
            onPressed: onAddLesson,
            icon: const Icon(Iconsax.add, size: 18),
            label: const Text('إضافة درس'),
          ),
        ],
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  const _LessonItem({
    required this.lesson,
    required this.index,
    required this.onRemove,
  });

  final _LessonData lesson;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingSmall,
        horizontal: AppConstants.spacingMedium,
      ),
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            lesson.videoUrl != null ? Iconsax.video : Iconsax.video_add,
            size: 20,
            color: lesson.videoUrl != null
                ? AppColors.primary
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (lesson.isFreePreview)
                  Text(
                    'معاينة مجانية',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.edit_2, size: 18),
            onPressed: () {
              // TODO: Edit lesson
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, size: 18),
            onPressed: onRemove,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.text,
    required this.onRemove,
  });

  final String text;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingSmall,
        horizontal: AppConstants.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.tick_circle, size: 18, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
          IconButton(
            icon: const Icon(Iconsax.close_circle, size: 18),
            onPressed: onRemove,
            color: AppColors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
