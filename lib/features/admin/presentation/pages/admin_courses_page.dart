import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({super.key});

  @override
  State<AdminCoursesPage> createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'إدارة الدورات',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export_1),
            onPressed: () {
              // TODO: Export courses
            },
            tooltip: 'تصدير',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'معلقة'),
            Tab(text: 'منشورة'),
            Tab(text: 'مرفوضة'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن دورة...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMedium,
                ),
              ),
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMedium,
            ),
            child: Row(
              children: [
                _StatChip(
                  label: 'إجمالي',
                  value: '89',
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                _StatChip(
                  label: 'معلقة',
                  value: '12',
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                _StatChip(
                  label: 'منشورة',
                  value: '72',
                  color: AppColors.success,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                _StatChip(
                  label: 'مرفوضة',
                  value: '5',
                  color: AppColors.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Courses List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CoursesListView(statusFilter: null),
                _CoursesListView(statusFilter: 'pending'),
                _CoursesListView(statusFilter: 'published'),
                _CoursesListView(statusFilter: 'rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursesListView extends StatelessWidget {
  const _CoursesListView({this.statusFilter});

  final String? statusFilter;

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final courses = List.generate(
      15,
      (index) => _CourseData(
        id: 'course_$index',
        title: 'دورة ${index + 1}: أساسيات البرمجة',
        instructor: 'د. أحمد محمد',
        instructorType: index % 3 == 0 ? 'company' : 'user',
        price: (index + 1) * 50.0,
        status: index % 5 == 0
            ? 'rejected'
            : index % 3 == 0
                ? 'pending'
                : 'published',
        submittedAt: DateTime.now().subtract(Duration(days: index * 2)),
        enrollmentCount: (index + 1) * 12,
        rating: 4.0 + (index % 10) / 10,
      ),
    );

    final filteredCourses = statusFilter == null
        ? courses
        : courses.where((c) => c.status == statusFilter).toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.book,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا توجد دورات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        return _CourseCard(course: filteredCourses[index]);
      },
    );
  }
}

class _CourseData {
  const _CourseData({
    required this.id,
    required this.title,
    required this.instructor,
    required this.instructorType,
    required this.price,
    required this.status,
    required this.submittedAt,
    required this.enrollmentCount,
    required this.rating,
  });

  final String id;
  final String title;
  final String instructor;
  final String instructorType;
  final double price;
  final String status;
  final DateTime submittedAt;
  final int enrollmentCount;
  final double rating;
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final _CourseData course;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: const Icon(Iconsax.book, color: Colors.white),
              ),
              const SizedBox(width: AppConstants.spacingMedium),

              // Course Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge(status: course.status),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Row(
                      children: [
                        Icon(
                          course.instructorType == 'company'
                              ? Iconsax.building
                              : Iconsax.user,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            course.instructor,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.star1,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                        const Icon(
                          Iconsax.people,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.enrollmentCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Text(
                          '${course.price.toStringAsFixed(0)} ر.س',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (course.status == 'pending') ...[
            const Divider(height: AppConstants.spacingLarge),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Iconsax.close_circle, size: 18),
                    label: const Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _approveCourse(context),
                    icon: const Icon(Iconsax.tick_circle, size: 18),
                    label: const Text('قبول'),
                  ),
                ),
              ],
            ),
          ],

          if (course.status != 'pending') ...[
            const Divider(height: AppConstants.spacingLarge),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: View course
                  },
                  icon: const Icon(Iconsax.eye, size: 18),
                  label: const Text('عرض'),
                ),
                const Spacer(),
                if (course.status == 'published')
                  TextButton.icon(
                    onPressed: () => _unpublishCourse(context),
                    icon: const Icon(Iconsax.eye_slash, size: 18),
                    label: const Text('إلغاء النشر'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                    ),
                  )
                else if (course.status == 'rejected')
                  TextButton.icon(
                    onPressed: () => _approveCourse(context),
                    icon: const Icon(Iconsax.refresh, size: 18),
                    label: const Text('إعادة المراجعة'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _approveCourse(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول الدورة'),
        content: const Text('هل أنت متأكد من قبول ونشر هذه الدورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Approve course
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم قبول الدورة بنجاح')),
              );
            },
            child: const Text('قبول'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الدورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('يرجى توضيح سبب الرفض للمدرب:'),
            const SizedBox(height: AppConstants.spacingMedium),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              // TODO: Reject course with reason
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم رفض الدورة')),
              );
            },
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }

  void _unpublishCourse(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء نشر الدورة'),
        content: const Text(
          'هل أنت متأكد من إلغاء نشر هذه الدورة؟ لن تظهر للمستخدمين.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              // TODO: Unpublish course
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إلغاء نشر الدورة')),
              );
            },
            child: const Text('إلغاء النشر'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status) {
      case 'pending':
        label = 'معلقة';
        color = AppColors.warning;
        break;
      case 'published':
        label = 'منشورة';
        color = AppColors.success;
        break;
      case 'rejected':
        label = 'مرفوضة';
        color = AppColors.error;
        break;
      default:
        label = status;
        color = AppColors.textSecondaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
