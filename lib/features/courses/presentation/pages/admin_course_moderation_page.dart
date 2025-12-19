import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_bloc.dart';

/// Admin page for moderating course submissions
class AdminCourseModerationPage extends StatefulWidget {
  const AdminCourseModerationPage({super.key});

  @override
  State<AdminCourseModerationPage> createState() =>
      _AdminCourseModerationPageState();
}

class _AdminCourseModerationPageState extends State<AdminCourseModerationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCourses() {
    context.read<CourseBloc>().add(const LoadPendingCourses());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الدورات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'قيد المراجعة'),
            Tab(text: 'المنشورة'),
            Tab(text: 'المرفوضة'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            _loadCourses();
          }
          if (state is CourseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CoursesLoaded) {
            final pendingCourses = state.courses
                .where((c) => c.publishState == CoursePublishState.pendingReview)
                .toList();
            final publishedCourses = state.courses
                .where((c) => c.publishState == CoursePublishState.published)
                .toList();
            final rejectedCourses = state.courses
                .where((c) => c.publishState == CoursePublishState.rejected)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _CourseList(
                  courses: pendingCourses,
                  emptyMessage: 'لا توجد دورات قيد المراجعة',
                  emptyIcon: Icons.inbox,
                  showActions: true,
                  onApprove: _approveCourse,
                  onReject: _showRejectDialog,
                  onView: _viewCourse,
                ),
                _CourseList(
                  courses: publishedCourses,
                  emptyMessage: 'لا توجد دورات منشورة',
                  emptyIcon: Icons.check_circle,
                  showActions: false,
                  onView: _viewCourse,
                  onUnpublish: _unpublishCourse,
                ),
                _CourseList(
                  courses: rejectedCourses,
                  emptyMessage: 'لا توجد دورات مرفوضة',
                  emptyIcon: Icons.cancel,
                  showActions: false,
                  onView: _viewCourse,
                ),
              ],
            );
          }

          return const Center(child: Text('خطأ في تحميل البيانات'));
        },
      ),
    );
  }

  void _approveCourse(CourseEntity course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الموافقة على الدورة'),
        content: Text('هل تريد الموافقة على نشر "${course.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CourseBloc>().add(ApproveCourse(course.id));
            },
            child: const Text('موافقة'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(CourseEntity course) async {
    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الدورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('سيتم رفض الدورة "${course.title}"'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض *',
                hintText: 'أدخل سبب الرفض...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال سبب الرفض')),
                );
                return;
              }
              Navigator.pop(context, reasonController.text.trim());
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      context.read<CourseBloc>().add(RejectCourse(course.id, result));
    }
  }

  void _viewCourse(CourseEntity course) {
    context.push('${RouteNames.courses}/${course.id}');
  }

  void _unpublishCourse(CourseEntity course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء نشر الدورة'),
        content: Text('هل تريد إلغاء نشر "${course.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CourseBloc>().add(UnpublishCourse(course.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('إلغاء النشر'),
          ),
        ],
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({
    required this.courses,
    required this.emptyMessage,
    required this.emptyIcon,
    this.showActions = false,
    this.onApprove,
    this.onReject,
    this.onView,
    this.onUnpublish,
  });

  final List<CourseEntity> courses;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool showActions;
  final void Function(CourseEntity)? onApprove;
  final void Function(CourseEntity)? onReject;
  final void Function(CourseEntity)? onView;
  final void Function(CourseEntity)? onUnpublish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _CourseCard(
          course: course,
          showActions: showActions,
          onApprove: onApprove != null ? () => onApprove!(course) : null,
          onReject: onReject != null ? () => onReject!(course) : null,
          onView: onView != null ? () => onView!(course) : null,
          onUnpublish: onUnpublish != null ? () => onUnpublish!(course) : null,
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    this.showActions = false,
    this.onApprove,
    this.onReject,
    this.onView,
    this.onUnpublish,
  });

  final CourseEntity course;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onView;
  final VoidCallback? onUnpublish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (course.thumbnailUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                course.thumbnailUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.school,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusBadge(context),
                    const Spacer(),
                    Text(
                      course.formattedPrice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (course.shortDescription != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    course.shortDescription!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (course.instructor != null) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: course.instructor!.avatarUrl != null
                            ? NetworkImage(course.instructor!.avatarUrl!)
                            : null,
                        child: course.instructor!.avatarUrl == null
                            ? Text(
                                course.instructor!.fullName.substring(0, 1),
                                style: const TextStyle(fontSize: 12),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course.instructor!.fullName,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.formattedDuration,
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.play_lesson,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.lessonCount} درس',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.level.label,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                if (course.rejectionReason != null &&
                    course.publishState == CoursePublishState.rejected) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سبب الرفض: ${course.rejectionReason}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onView != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onView,
                          icon: const Icon(Icons.visibility),
                          label: const Text('عرض'),
                        ),
                      ),
                    if (showActions && onApprove != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check),
                          label: const Text('قبول'),
                        ),
                      ),
                    ],
                    if (showActions && onReject != null) ...[
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        onPressed: onReject,
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    if (!showActions && onUnpublish != null) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: onUnpublish,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('إلغاء النشر'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String text;

    switch (course.publishState) {
      case CoursePublishState.pendingReview:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        text = 'قيد المراجعة';
        break;
      case CoursePublishState.published:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        text = 'منشور';
        break;
      case CoursePublishState.rejected:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        text = 'مرفوض';
        break;
      case CoursePublishState.draft:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurface;
        text = 'مسودة';
        break;
      case CoursePublishState.unpublished:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurface;
        text = 'غير منشور';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
