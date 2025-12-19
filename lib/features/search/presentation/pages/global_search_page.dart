import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/verified_badge.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
      _performSearch();
    } else {
      // Focus search field on open
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;
    setState(() {
      _searchQuery = _searchController.text.trim();
      _isSearching = true;
    });
    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'البحث',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        bottom: _searchQuery.isNotEmpty
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'الكل'),
                  Tab(text: 'الوظائف'),
                  Tab(text: 'الدورات'),
                  Tab(text: 'الأشخاص'),
                  Tab(text: 'الشركات'),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'ابحث عن وظائف، دورات، أشخاص، شركات...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusLarge,
                  ),
                ),
                filled: true,
                fillColor: AppColors.primaryExtraLight,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Content
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildInitialState(theme)
                : _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _AllResultsTab(query: _searchQuery),
                          _JobsResultsTab(query: _searchQuery),
                          _CoursesResultsTab(query: _searchQuery),
                          _PeopleResultsTab(query: _searchQuery),
                          _CompaniesResultsTab(query: _searchQuery),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          Text(
            'عمليات البحث الأخيرة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Wrap(
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingSmall,
            children: [
              _RecentSearchChip(
                label: 'Flutter Developer',
                onTap: () {
                  _searchController.text = 'Flutter Developer';
                  _performSearch();
                },
              ),
              _RecentSearchChip(
                label: 'تصميم UI/UX',
                onTap: () {
                  _searchController.text = 'تصميم UI/UX';
                  _performSearch();
                },
              ),
              _RecentSearchChip(
                label: 'إدارة المشاريع',
                onTap: () {
                  _searchController.text = 'إدارة المشاريع';
                  _performSearch();
                },
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingLarge),

          // Popular Searches
          Text(
            'الأكثر بحثاً',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          _PopularSearchItem(
            icon: Iconsax.briefcase,
            label: 'مطور تطبيقات',
            count: '1,234 وظيفة',
            onTap: () {
              _searchController.text = 'مطور تطبيقات';
              _performSearch();
            },
          ),
          _PopularSearchItem(
            icon: Iconsax.book,
            label: 'البرمجة بلغة Python',
            count: '45 دورة',
            onTap: () {
              _searchController.text = 'Python';
              _performSearch();
            },
          ),
          _PopularSearchItem(
            icon: Iconsax.briefcase,
            label: 'التسويق الرقمي',
            count: '567 وظيفة',
            onTap: () {
              _searchController.text = 'التسويق الرقمي';
              _performSearch();
            },
          ),
          _PopularSearchItem(
            icon: Iconsax.book,
            label: 'تحليل البيانات',
            count: '32 دورة',
            onTap: () {
              _searchController.text = 'تحليل البيانات';
              _performSearch();
            },
          ),

          const SizedBox(height: AppConstants.spacingLarge),

          // Browse Categories
          Text(
            'تصفح حسب التصنيف',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppConstants.spacingMedium,
            mainAxisSpacing: AppConstants.spacingMedium,
            childAspectRatio: 2,
            children: [
              _CategoryCard(
                icon: Iconsax.code,
                label: 'التقنية والبرمجة',
                color: AppColors.primary,
                onTap: () {
                  _searchController.text = 'برمجة';
                  _performSearch();
                },
              ),
              _CategoryCard(
                icon: Iconsax.chart,
                label: 'الأعمال والإدارة',
                color: AppColors.success,
                onTap: () {
                  _searchController.text = 'إدارة';
                  _performSearch();
                },
              ),
              _CategoryCard(
                icon: Iconsax.brush_1,
                label: 'التصميم والإبداع',
                color: AppColors.warning,
                onTap: () {
                  _searchController.text = 'تصميم';
                  _performSearch();
                },
              ),
              _CategoryCard(
                icon: Iconsax.message,
                label: 'التسويق والمبيعات',
                color: AppColors.info,
                onTap: () {
                  _searchController.text = 'تسويق';
                  _performSearch();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentSearchChip extends StatelessWidget {
  const _RecentSearchChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Iconsax.clock, size: 16),
      onPressed: onTap,
    );
  }
}

class _PopularSearchItem extends StatelessWidget {
  const _PopularSearchItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingSmall,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              count,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            const Icon(
              Iconsax.arrow_left_2,
              size: 16,
              color: AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllResultsTab extends StatelessWidget {
  const _AllResultsTab({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      children: [
        // Jobs Section
        _SectionHeader(
          title: 'الوظائف',
          count: 12,
          onViewAll: () {},
        ),
        ...List.generate(2, (index) => _JobResultCard(index: index)),

        const SizedBox(height: AppConstants.spacingLarge),

        // Courses Section
        _SectionHeader(
          title: 'الدورات',
          count: 5,
          onViewAll: () {},
        ),
        ...List.generate(2, (index) => _CourseResultCard(index: index)),

        const SizedBox(height: AppConstants.spacingLarge),

        // People Section
        _SectionHeader(
          title: 'الأشخاص',
          count: 8,
          onViewAll: () {},
        ),
        ...List.generate(2, (index) => _PersonResultCard(index: index)),

        const SizedBox(height: AppConstants.spacingLarge),

        // Companies Section
        _SectionHeader(
          title: 'الشركات',
          count: 3,
          onViewAll: () {},
        ),
        ...List.generate(2, (index) => _CompanyResultCard(index: index)),
      ],
    );
  }
}

class _JobsResultsTab extends StatelessWidget {
  const _JobsResultsTab({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: 12,
      itemBuilder: (context, index) => _JobResultCard(index: index),
    );
  }
}

class _CoursesResultsTab extends StatelessWidget {
  const _CoursesResultsTab({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: 5,
      itemBuilder: (context, index) => _CourseResultCard(index: index),
    );
  }
}

class _PeopleResultsTab extends StatelessWidget {
  const _PeopleResultsTab({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: 8,
      itemBuilder: (context, index) => _PersonResultCard(index: index),
    );
  }
}

class _CompaniesResultsTab extends StatelessWidget {
  const _CompaniesResultsTab({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: 3,
      itemBuilder: (context, index) => _CompanyResultCard(index: index),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onViewAll,
  });

  final String title;
  final int count;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onViewAll,
            child: const Text('عرض الكل'),
          ),
        ],
      ),
    );
  }
}

class _JobResultCard extends StatelessWidget {
  const _JobResultCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.push('${RouteNames.jobs}/job_$index'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Center(
              child: Icon(Iconsax.briefcase, color: Colors.white),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مطور Flutter ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'شركة التقنية',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const CompanyVerifiedBadge(
                      isVerified: true,
                      size: VerifiedBadgeSize.small,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Iconsax.location, size: 12, color: AppColors.textTertiaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'الرياض',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'دوام كامل',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.successDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_left_2, size: 18, color: AppColors.textTertiaryLight),
        ],
      ),
    );
  }
}

class _CourseResultCard extends StatelessWidget {
  const _CourseResultCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.push('${RouteNames.courses}/course_$index'),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Center(
              child: Icon(Iconsax.book, color: Colors.white),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دورة تطوير التطبيقات ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'د. أحمد محمد',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Iconsax.star1, size: 12, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '4.${8 - index}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      '(${(index + 1) * 45} طالب)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(index + 1) * 99} ر.س',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonResultCard extends StatelessWidget {
  const _PersonResultCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.push('${RouteNames.userProfile}/user_$index'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLighter,
            child: Text(
              'م',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محمد أحمد ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'مطور تطبيقات موبايل',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Iconsax.location, size: 12, color: AppColors.textTertiaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'جدة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Text(
                      '${(index + 1) * 100} متابع',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }
}

class _CompanyResultCard extends StatelessWidget {
  const _CompanyResultCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.push('${RouteNames.companies}/company_$index'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Center(
              child: Icon(Iconsax.building, color: Colors.white),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'شركة التقنية ${index + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const CompanyVerifiedBadge(
                      isVerified: true,
                      size: VerifiedBadgeSize.small,
                    ),
                  ],
                ),
                Text(
                  'تكنولوجيا المعلومات',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Iconsax.people, size: 12, color: AppColors.textTertiaryLight),
                    const SizedBox(width: 4),
                    Text(
                      '${(index + 1) * 50}+ موظف',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Text(
                      '${(index + 1) * 5} وظيفة متاحة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }
}
