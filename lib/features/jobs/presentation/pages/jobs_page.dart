import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/injection/injection.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/job_bloc.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<JobBloc>()..add(const LoadJobs()),
      child: const ResponsiveLayout(
        mobile: _MobileJobsPage(),
        desktop: _DesktopJobsPage(),
      ),
    );
  }
}

class _MobileJobsPage extends StatefulWidget {
  const _MobileJobsPage();

  @override
  State<_MobileJobsPage> createState() => _MobileJobsPageState();
}

class _MobileJobsPageState extends State<_MobileJobsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Filter states
  JobType? _selectedJobType;
  ExperienceLevel? _selectedExperienceLevel;
  LocationType? _selectedLocationType;
  bool? _isRemote;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<JobBloc>().state;
      if (state is JobsLoaded && state.hasMore) {
        context.read<JobBloc>().add(LoadJobs(
          searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
          jobType: _selectedJobType,
          isRemote: _isRemote,
          offset: state.jobs.length,
        ));
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<JobBloc>().add(LoadJobs(
        searchQuery: query.isEmpty ? null : query,
        jobType: _selectedJobType,
        isRemote: _isRemote,
      ));
    });
  }

  void _applyFilters() {
    Navigator.pop(context);
    context.read<JobBloc>().add(LoadJobs(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      jobType: _selectedJobType,
      isRemote: _isRemote,
    ));
  }

  void _clearFilters() {
    setState(() {
      _selectedJobType = null;
      _selectedExperienceLevel = null;
      _selectedLocationType = null;
      _isRemote = null;
      _selectedCity = null;
    });
    Navigator.pop(context);
    context.read<JobBloc>().add(LoadJobs(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
    ));
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التصفية',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedJobType = null;
                          _selectedExperienceLevel = null;
                          _selectedLocationType = null;
                          _isRemote = null;
                        });
                      },
                      child: const Text('مسح الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLarge),

                // Job Type Filter
                Text(
                  'نوع العمل',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Wrap(
                  spacing: AppConstants.spacingSmall,
                  runSpacing: AppConstants.spacingSmall,
                  children: JobType.values.map((type) {
                    final isSelected = _selectedJobType == type;
                    return FilterChip(
                      label: Text(type.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setSheetState(() {
                          _selectedJobType = selected ? type : null;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppConstants.spacingMedium),

                // Experience Level Filter
                Text(
                  'مستوى الخبرة',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Wrap(
                  spacing: AppConstants.spacingSmall,
                  runSpacing: AppConstants.spacingSmall,
                  children: ExperienceLevel.values.map((level) {
                    final isSelected = _selectedExperienceLevel == level;
                    return FilterChip(
                      label: Text(level.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setSheetState(() {
                          _selectedExperienceLevel = selected ? level : null;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppConstants.spacingMedium),

                // Location Type Filter
                Text(
                  'نوع الموقع',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Wrap(
                  spacing: AppConstants.spacingSmall,
                  runSpacing: AppConstants.spacingSmall,
                  children: LocationType.values.map((loc) {
                    final isSelected = _selectedLocationType == loc;
                    return FilterChip(
                      label: Text(loc.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setSheetState(() {
                          _selectedLocationType = selected ? loc : null;
                          if (loc == LocationType.remote && selected) {
                            _isRemote = true;
                          } else if (loc == LocationType.remote && !selected) {
                            _isRemote = null;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppConstants.spacingLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'الوظائف',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterSheet(context),
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
              hint: 'ابحث عن وظائف...',
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<JobBloc, JobState>(
              builder: (context, state) {
                if (state is JobLoading && state is! JobsLoaded) {
                  return _buildSkeletonList();
                }

                if (state is JobError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is JobsLoaded) {
                  if (state.jobs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<JobBloc>().add(LoadJobs(
                        searchQuery: _searchController.text.isEmpty
                            ? null
                            : _searchController.text,
                        jobType: _selectedJobType,
                        isRemote: _isRemote,
                      ));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMedium,
                      ),
                      itemCount: state.jobs.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.jobs.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppConstants.spacingMedium),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final job = state.jobs[index];
                        return _JobCard(
                          job: job,
                          onTap: () => context.push('${RouteNames.jobs}/${job.id}'),
                          onSave: () {
                            context.read<JobBloc>().add(ToggleSaveJob(jobId: job.id));
                          },
                        );
                      },
                    ),
                  );
                }

                return _buildSkeletonList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
        ),
        itemCount: 5,
        itemBuilder: (context, index) => const _JobCardSkeleton(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: () {
                context.read<JobBloc>().add(const LoadJobs());
              },
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.briefcase,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا توجد وظائف',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'لم يتم العثور على وظائف مطابقة لبحثك',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopJobsPage extends StatefulWidget {
  const _DesktopJobsPage();

  @override
  State<_DesktopJobsPage> createState() => _DesktopJobsPageState();
}

class _DesktopJobsPageState extends State<_DesktopJobsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _sortBy = 'الأحدث';

  // Filter states
  JobType? _selectedJobType;
  ExperienceLevel? _selectedExperienceLevel;
  LocationType? _selectedLocationType;
  bool? _isRemote;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<JobBloc>().state;
      if (state is JobsLoaded && state.hasMore) {
        context.read<JobBloc>().add(LoadJobs(
          searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
          jobType: _selectedJobType,
          isRemote: _isRemote,
          offset: state.jobs.length,
        ));
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<JobBloc>().add(LoadJobs(
        searchQuery: query.isEmpty ? null : query,
        jobType: _selectedJobType,
        isRemote: _isRemote,
      ));
    });
  }

  void _applyFilters() {
    context.read<JobBloc>().add(LoadJobs(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      jobType: _selectedJobType,
      isRemote: _isRemote,
    ));
  }

  void _clearFilters() {
    setState(() {
      _selectedJobType = null;
      _selectedExperienceLevel = null;
      _selectedLocationType = null;
      _isRemote = null;
    });
    context.read<JobBloc>().add(LoadJobs(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'الوظائف',
        actions: [
          GlassButton(
            onPressed: () => context.push(RouteNames.postJob),
            icon: Iconsax.add,
            label: 'نشر وظيفة',
            intensity: GlassIntensity.light,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () => context.push(RouteNames.notifications),
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: _buildFiltersPanel(),
          ),
          Container(
            width: 1,
            color: AppColors.dividerLight,
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassSearchField(
                          controller: _searchController,
                          hint: 'ابحث عن وظائف...',
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      _buildSortDropdown(),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<JobBloc, JobState>(
                    builder: (context, state) {
                      if (state is JobLoading && state is! JobsLoaded) {
                        return _buildSkeletonGrid();
                      }

                      if (state is JobError) {
                        return _buildErrorState(context, state.message);
                      }

                      if (state is JobsLoaded) {
                        if (state.jobs.isEmpty) {
                          return _buildEmptyState();
                        }

                        return GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppConstants.spacingMedium),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppConstants.spacingMedium,
                            mainAxisSpacing: AppConstants.spacingMedium,
                            childAspectRatio: 1.8,
                          ),
                          itemCount: state.jobs.length + (state.hasMore ? 2 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.jobs.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final job = state.jobs[index];
                            return _JobCard(
                              job: job,
                              onTap: () => context.push('${RouteNames.jobs}/${job.id}'),
                              onSave: () {
                                context.read<JobBloc>().add(ToggleSaveJob(jobId: job.id));
                              },
                            );
                          },
                        );
                      }

                      return _buildSkeletonGrid();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التصفية',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Job Type Filter
          _buildFilterSection(
            title: 'نوع العمل',
            options: JobType.values.map((e) => e.label).toList(),
            selectedIndex: _selectedJobType?.index,
            onSelected: (index) {
              setState(() {
                _selectedJobType = index != null ? JobType.values[index] : null;
              });
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Experience Level Filter
          _buildFilterSection(
            title: 'مستوى الخبرة',
            options: ExperienceLevel.values.map((e) => e.label).toList(),
            selectedIndex: _selectedExperienceLevel?.index,
            onSelected: (index) {
              setState(() {
                _selectedExperienceLevel = index != null
                    ? ExperienceLevel.values[index]
                    : null;
              });
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Location Type Filter
          _buildFilterSection(
            title: 'نوع الموقع',
            options: LocationType.values.map((e) => e.label).toList(),
            selectedIndex: _selectedLocationType?.index,
            onSelected: (index) {
              setState(() {
                _selectedLocationType = index != null
                    ? LocationType.values[index]
                    : null;
                if (_selectedLocationType == LocationType.remote) {
                  _isRemote = true;
                } else {
                  _isRemote = null;
                }
              });
            },
          ),

          const SizedBox(height: AppConstants.spacingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('تطبيق التصفية'),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _clearFilters,
              child: const Text('مسح الكل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    int? selectedIndex,
    required void Function(int?) onSelected,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Wrap(
          spacing: AppConstants.spacingSmall,
          runSpacing: AppConstants.spacingSmall,
          children: List.generate(options.length, (index) {
            final isSelected = selectedIndex == index;
            return FilterChip(
              label: Text(options[index]),
              selected: isSelected,
              onSelected: (selected) {
                onSelected(selected ? index : null);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall,
      ),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          items: ['الأحدث', 'الأكثر صلة', 'الأعلى راتباً', 'الأقرب']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sortBy = value;
              });
              // TODO: Implement sorting
            }
          },
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.spacingMedium,
          mainAxisSpacing: AppConstants.spacingMedium,
          childAspectRatio: 1.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const _JobCardSkeleton(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: () {
                context.read<JobBloc>().add(const LoadJobs());
              },
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.briefcase,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا توجد وظائف',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'لم يتم العثور على وظائف مطابقة لبحثك',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.onTap,
    required this.onSave,
  });

  final JobEntity job;
  final VoidCallback onTap;
  final VoidCallback onSave;

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 30) {
      return 'منذ ${difference.inDays ~/ 30} شهر';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: onTap,
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                  image: job.company?.logoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(job.company!.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: job.company?.logoUrl == null
                    ? Center(
                        child: Text(
                          job.company?.name.isNotEmpty == true
                              ? job.company!.name[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.company?.name ?? 'شركة',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (job.company?.isVerified == true) ...[
                          const SizedBox(width: AppConstants.spacingExtraSmall),
                          const CompanyVerifiedBadge(
                            isVerified: true,
                            size: VerifiedBadgeSize.small,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              BlocBuilder<JobBloc, JobState>(
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(
                      job.isSaved ? Iconsax.bookmark_25 : Iconsax.bookmark,
                      color: job.isSaved ? AppColors.primary : null,
                    ),
                    onPressed: onSave,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Wrap(
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingSmall,
            children: [
              if (job.city != null || job.location != null)
                _JobTag(
                  icon: Iconsax.location,
                  label: job.city ?? job.location ?? '',
                ),
              _JobTag(
                icon: Iconsax.briefcase,
                label: job.jobType.label,
              ),
              if (job.showSalary && (job.salaryMin != null || job.salaryMax != null))
                _JobTag(
                  icon: Iconsax.money,
                  label: job.salaryRange,
                ),
              _JobTag(
                icon: Iconsax.chart,
                label: job.experienceLevel.label,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            job.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTimeAgo(job.publishedAt ?? job.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
              if (job.hasAvailableVacancies)
                Text(
                  '${job.remainingVacancies} وظائف متبقية',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Text(
                  'مكتمل',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCardSkeleton extends StatelessWidget {
  const _JobCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              Container(
                width: 80,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Container(
                width: 80,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Container(
                width: 80,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Container(
            width: double.infinity,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 12,
                color: Colors.white,
              ),
              Container(
                width: 100,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobTag extends StatelessWidget {
  const _JobTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
