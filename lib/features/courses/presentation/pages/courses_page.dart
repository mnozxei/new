import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/injection/injection.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_bloc.dart';
import '../bloc/course_event.dart';
import '../bloc/course_state.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late final CourseBloc _courseBloc;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  String? _selectedCategory;
  CourseLevel? _selectedLevel;
  bool? _isFree;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _courseBloc = getIt<CourseBloc>()..add(const LoadCourses());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _courseBloc.state;
      if (state is CoursesLoaded && state.hasMore) {
        _courseBloc.add(LoadMoreCourses(
          category: _selectedCategory,
          level: _selectedLevel,
          isFree: _isFree,
          searchQuery: _searchQuery,
        ));
      }
    }
  }

  void _applyFilters() {
    _courseBloc.add(LoadCourses(
      category: _selectedCategory,
      level: _selectedLevel,
      isFree: _isFree,
      searchQuery: _searchQuery,
    ));
  }

  void _onSearch(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _applyFilters();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(
        selectedCategory: _selectedCategory,
        selectedLevel: _selectedLevel,
        isFree: _isFree,
        onApply: (category, level, isFree) {
          setState(() {
            _selectedCategory = category;
            _selectedLevel = level;
            _isFree = isFree;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _courseBloc,
      child: Scaffold(
        appBar: GlassAppBar(
          title: 'الدورات',
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Iconsax.filter),
                  if (_selectedCategory != null ||
                      _selectedLevel != null ||
                      _isFree != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _showFilterSheet,
            ),
            IconButton(
              icon: const Icon(Iconsax.book_saved),
              onPressed: () => context.push(RouteNames.myLearning),
            ),
            IconButton(
              icon: const Icon(Iconsax.notification),
              onPressed: () => context.push(RouteNames.notifications),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: GlassSearchField(
                controller: _searchController,
                hint: 'ابحث عن دورات...',
                onChanged: _onSearch,
                onSubmitted: _onSearch,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMedium),
              child: SizedBox(
                height: 40,
                child: _CategoryChips(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory =
                          _selectedCategory == category ? null : category;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Expanded(
              child: BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return const GlassLoading();
                  }

                  if (state is CourseError) {
                    return EmptyState(
                      icon: Iconsax.warning_2,
                      title: 'حدث خطأ',
                      message: state.message,
                      actionLabel: 'إعادة المحاولة',
                      onAction: () => _courseBloc.add(const LoadCourses()),
                    );
                  }

                  if (state is CoursesLoaded) {
                    if (state.courses.isEmpty) {
                      return EmptyState(
                        icon: Iconsax.book_1,
                        title: 'لا توجد دورات',
                        message: _searchQuery != null
                            ? 'لم يتم العثور على دورات تطابق بحثك'
                            : 'لا توجد دورات متاحة حالياً',
                        actionLabel:
                            _searchQuery != null ? 'مسح البحث' : null,
                        onAction: _searchQuery != null
                            ? () {
                                _searchController.clear();
                                _searchQuery = null;
                                _applyFilters();
                              }
                            : null,
                      );
                    }

                    return ResponsiveLayout(
                      mobile: _MobileCoursesList(
                        courses: state.courses,
                        hasMore: state.hasMore,
                        scrollController: _scrollController,
                      ),
                      desktop: _DesktopCoursesList(
                        courses: state.courses,
                        hasMore: state.hasMore,
                        scrollController: _scrollController,
                      ),
                    );
                  }

                  if (state is CourseSearchResults) {
                    if (state.courses.isEmpty) {
                      return EmptyState(
                        icon: Iconsax.search_normal_1,
                        title: 'لا توجد نتائج',
                        message: 'لم يتم العثور على دورات تطابق "${state.query}"',
                      );
                    }

                    return ResponsiveLayout(
                      mobile: _MobileCoursesList(
                        courses: state.courses,
                        hasMore: state.hasMore,
                        scrollController: _scrollController,
                      ),
                      desktop: _DesktopCoursesList(
                        courses: state.courses,
                        hasMore: state.hasMore,
                        scrollController: _scrollController,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  static const _categories = [
    'الكل',
    'البرمجة والتقنية',
    'التصميم',
    'التسويق',
    'الأعمال والإدارة',
    'التطوير الشخصي',
    'اللغات',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isAll = category == 'الكل';
        final isSelected = isAll
            ? selectedCategory == null
            : selectedCategory == category;

        return Padding(
          padding: const EdgeInsets.only(left: AppConstants.spacingSmall),
          child: FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              onCategorySelected(isAll ? null : category);
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primary,
          ),
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.selectedCategory,
    required this.selectedLevel,
    required this.isFree,
    required this.onApply,
  });

  final String? selectedCategory;
  final CourseLevel? selectedLevel;
  final bool? isFree;
  final void Function(String?, CourseLevel?, bool?) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _category;
  late CourseLevel? _level;
  late bool? _isFree;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _level = widget.selectedLevel;
    _isFree = widget.isFree;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية الدورات',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _category = null;
                    _level = null;
                    _isFree = null;
                  });
                },
                child: const Text('مسح الكل'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Level filter
          Text(
            'المستوى',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Wrap(
            spacing: 8,
            children: CourseLevel.selectableLevels.map((level) {
              return ChoiceChip(
                label: Text(level.label),
                selected: _level == level,
                onSelected: (selected) {
                  setState(() {
                    _level = selected ? level : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Price filter
          Text(
            'السعر',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: _isFree == null,
                onSelected: (selected) {
                  setState(() => _isFree = null);
                },
              ),
              ChoiceChip(
                label: const Text('مجاني'),
                selected: _isFree == true,
                onSelected: (selected) {
                  setState(() => _isFree = selected ? true : null);
                },
              ),
              ChoiceChip(
                label: const Text('مدفوع'),
                selected: _isFree == false,
                onSelected: (selected) {
                  setState(() => _isFree = selected ? false : null);
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLarge),

          ElevatedButton(
            onPressed: () => widget.onApply(_category, _level, _isFree),
            child: const Text('تطبيق'),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
        ],
      ),
    );
  }
}

class _MobileCoursesList extends StatelessWidget {
  const _MobileCoursesList({
    required this.courses,
    required this.hasMore,
    required this.scrollController,
  });

  final List<CourseEntity> courses;
  final bool hasMore;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: courses.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= courses.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingMedium),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return CourseCard(
          course: courses[index],
          onTap: () =>
              context.push('${RouteNames.courses}/${courses[index].id}'),
        );
      },
    );
  }
}

class _DesktopCoursesList extends StatelessWidget {
  const _DesktopCoursesList({
    required this.courses,
    required this.hasMore,
    required this.scrollController,
  });

  final List<CourseEntity> courses;
  final bool hasMore;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppConstants.spacingMedium,
        mainAxisSpacing: AppConstants.spacingMedium,
        childAspectRatio: 0.8,
      ),
      itemCount: courses.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= courses.length) {
          return const Center(child: CircularProgressIndicator());
        }

        return CourseCard(
          course: courses[index],
          isCompact: true,
          onTap: () =>
              context.push('${RouteNames.courses}/${courses[index].id}'),
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.isCompact = false,
    this.showProgress = false,
    this.progress = 0,
  });

  final CourseEntity course;
  final VoidCallback onTap;
  final bool isCompact;
  final bool showProgress;
  final int progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: onTap,
      intensity: GlassIntensity.light,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            height: isCompact ? 120 : 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusLarge),
                topRight: Radius.circular(AppConstants.borderRadiusLarge),
              ),
              image: course.thumbnailUrl != null
                  ? DecorationImage(
                      image: NetworkImage(course.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (course.thumbnailUrl == null)
                  Center(
                    child: Icon(
                      Iconsax.book_1,
                      size: 48,
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                // Category badge
                if (course.category != null)
                  Positioned(
                    top: AppConstants.spacingSmall,
                    left: AppConstants.spacingSmall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingSmall,
                        vertical: AppConstants.spacingExtraSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall),
                      ),
                      child: Text(
                        course.category!,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                // Price badge
                Positioned(
                  top: AppConstants.spacingSmall,
                  right: AppConstants.spacingSmall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSmall,
                      vertical: AppConstants.spacingExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: course.isFree || course.price == 0
                          ? AppColors.success
                          : AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      course.formattedPrice,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Level badge
                Positioned(
                  bottom: AppConstants.spacingSmall,
                  left: AppConstants.spacingSmall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSmall,
                      vertical: AppConstants.spacingExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      course.level.label,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                // Instructor info
                if (course.instructor != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryLighter,
                        backgroundImage: course.instructor!.avatarUrl != null
                            ? NetworkImage(course.instructor!.avatarUrl!)
                            : null,
                        child: course.instructor!.avatarUrl == null
                            ? Text(
                                course.instructor!.fullName.isNotEmpty
                                    ? course.instructor!.fullName[0]
                                    : 'م',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Expanded(
                        child: Text(
                          course.instructor!.fullName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppConstants.spacingSmall),
                // Stats row
                Row(
                  children: [
                    if (course.ratingAverage > 0) ...[
                      const Icon(
                        Iconsax.star1,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      Text(
                        course.ratingAverage.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (course.ratingCount > 0) ...[
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        Text(
                          '(${course.ratingCount})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                      const SizedBox(width: AppConstants.spacingMedium),
                    ],
                    Icon(
                      Iconsax.people,
                      size: 14,
                      color: AppColors.textTertiaryLight,
                    ),
                    const SizedBox(width: AppConstants.spacingExtraSmall),
                    Text(
                      '${course.enrollmentCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Iconsax.clock,
                      size: 14,
                      color: AppColors.textTertiaryLight,
                    ),
                    const SizedBox(width: AppConstants.spacingExtraSmall),
                    Text(
                      course.formattedDuration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                // Progress bar (for enrolled courses)
                if (showProgress && !isCompact) ...[
                  const SizedBox(height: AppConstants.spacingSmall),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: AppColors.primaryLightest,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: AppConstants.spacingExtraSmall),
                  Text(
                    '$progress% مكتمل',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
