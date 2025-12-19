import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_entity.dart';
import '../bloc/admin_bloc.dart';

/// Admin page for managing content reports
class AdminContentReportsPage extends StatefulWidget {
  const AdminContentReportsPage({super.key});

  @override
  State<AdminContentReportsPage> createState() => _AdminContentReportsPageState();
}

class _AdminContentReportsPageState extends State<AdminContentReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedContentType;
  List<ContentReport> _reports = [];

  final _contentTypes = [
    ('الكل', null),
    ('الدورات', 'course'),
    ('الوظائف', 'job'),
    ('المستخدمين', 'user'),
    ('الشركات', 'company'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadReports('pending');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final statuses = ['pending', 'resolved', 'dismissed'];
      _loadReports(statuses[_tabController.index]);
    }
  }

  void _loadReports(String status) {
    context.read<AdminBloc>().add(LoadContentReports(
          status: status,
          contentType: _selectedContentType,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة البلاغات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'قيد المراجعة', icon: Icon(Icons.pending_actions)),
            Tab(text: 'تم الحل', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'مرفوضة', icon: Icon(Icons.cancel_outlined)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Content type filter
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _contentTypes.map((type) {
                  final isSelected = _selectedContentType == type.$2;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(type.$1),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedContentType = selected ? type.$2 : null;
                        });
                        final statuses = ['pending', 'resolved', 'dismissed'];
                        _loadReports(statuses[_tabController.index]);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          // Reports list
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is ContentReportsLoaded) {
                  setState(() {
                    _reports = state.reports;
                  });
                }
                if (state is ReportResolved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حل البلاغ بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  final statuses = ['pending', 'resolved', 'dismissed'];
                  _loadReports(statuses[_tabController.index]);
                }
                if (state is ReportDismissed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم رفض البلاغ'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  final statuses = ['pending', 'resolved', 'dismissed'];
                  _loadReports(statuses[_tabController.index]);
                }
                if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد بلاغات',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportsList(_reports, isPending: true),
                    _buildReportsList(_reports, isPending: false),
                    _buildReportsList(_reports, isPending: false),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<ContentReport> reports, {required bool isPending}) {
    return RefreshIndicator(
      onRefresh: () async {
        final statuses = ['pending', 'resolved', 'dismissed'];
        _loadReports(statuses[_tabController.index]);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(report, isPending: isPending);
        },
      ),
    );
  }

  Widget _buildReportCard(ContentReport report, {required bool isPending}) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with content type badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getContentTypeColor(report.contentType).withOpacity(0.1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getContentTypeColor(report.contentType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getContentTypeIcon(report.contentType),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getContentTypeLabel(report.contentType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(report.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.contentTitle != null) ...[
                  Text(
                    report.contentTitle!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Report reason
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.reason,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (report.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    report.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                // Reporter info
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مُبلِّغ: ${report.reporterName ?? 'مجهول'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                if (report.resolution != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'القرار: ${report.resolution}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions (only for pending reports)
          if (isPending) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showViewContentDialog(report),
                    icon: const Icon(Icons.visibility),
                    label: const Text('عرض المحتوى'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDismissDialog(report),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('رفض البلاغ'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _showResolveDialog(report),
                    icon: const Icon(Icons.check),
                    label: const Text('اتخاذ إجراء'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getContentTypeColor(String contentType) {
    switch (contentType) {
      case 'course':
        return Colors.blue;
      case 'job':
        return Colors.green;
      case 'user':
        return Colors.orange;
      case 'company':
        return Colors.purple;
      case 'post':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'course':
        return Icons.school;
      case 'job':
        return Icons.work;
      case 'user':
        return Icons.person;
      case 'company':
        return Icons.business;
      case 'post':
        return Icons.article;
      default:
        return Icons.flag;
    }
  }

  String _getContentTypeLabel(String contentType) {
    switch (contentType) {
      case 'course':
        return 'دورة';
      case 'job':
        return 'وظيفة';
      case 'user':
        return 'مستخدم';
      case 'company':
        return 'شركة';
      case 'post':
        return 'منشور';
      default:
        return 'محتوى';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'منذ ${diff.inMinutes} دقيقة';
      }
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showViewContentDialog(ContentReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل المحتوى المُبلَّغ عنه'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('نوع المحتوى', _getContentTypeLabel(report.contentType)),
              _buildDetailRow('معرف المحتوى', report.contentId),
              if (report.contentTitle != null)
                _buildDetailRow('عنوان المحتوى', report.contentTitle!),
              const Divider(height: 24),
              _buildDetailRow('سبب البلاغ', report.reason),
              if (report.description != null)
                _buildDetailRow('التفاصيل', report.description!),
              const Divider(height: 24),
              _buildDetailRow('المُبلِّغ', report.reporterName ?? 'مجهول'),
              _buildDetailRow('تاريخ البلاغ', _formatDate(report.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to content based on type
              _navigateToContent(report);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('فتح المحتوى'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _navigateToContent(ContentReport report) {
    // Navigate based on content type
    // For now, show a snackbar - integration depends on routing setup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الانتقال إلى ${_getContentTypeLabel(report.contentType)}: ${report.contentId}'),
      ),
    );
  }

  void _showDismissDialog(ContentReport report) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض البلاغ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سيتم إغلاق هذا البلاغ دون اتخاذ أي إجراء على المحتوى.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                hintText: 'أدخل سبب رفض البلاغ...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الرجاء إدخال سبب الرفض'),
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              context.read<AdminBloc>().add(
                    DismissReport(report.id, reasonController.text.trim()),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('رفض البلاغ'),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(ContentReport report) {
    final resolutionController = TextEditingController();
    String? selectedAction;

    final actions = _getAvailableActions(report.contentType);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('اتخاذ إجراء'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المحتوى: ${report.contentTitle ?? report.contentId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                const Text('اختر الإجراء:'),
                const SizedBox(height: 8),
                ...actions.map((action) => RadioListTile<String>(
                      title: Text(action.$1),
                      subtitle: Text(action.$2),
                      value: action.$3,
                      groupValue: selectedAction,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedAction = value;
                        });
                      },
                    )),
                const SizedBox(height: 16),
                TextField(
                  controller: resolutionController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات إضافية',
                    hintText: 'أدخل أي ملاحظات حول القرار...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: selectedAction == null
                  ? null
                  : () {
                      final resolution =
                          '$selectedAction${resolutionController.text.isNotEmpty ? ': ${resolutionController.text}' : ''}';
                      Navigator.of(context).pop();
                      context.read<AdminBloc>().add(
                            ResolveReport(report.id, resolution),
                          );
                    },
              child: const Text('تنفيذ الإجراء'),
            ),
          ],
        ),
      ),
    );
  }

  List<(String, String, String)> _getAvailableActions(String contentType) {
    switch (contentType) {
      case 'course':
        return [
          ('إلغاء نشر الدورة', 'سيتم إخفاء الدورة من المنصة', 'unpublish_course'),
          ('حذف الدورة', 'سيتم حذف الدورة نهائياً', 'delete_course'),
          ('تحذير المدرب', 'إرسال تحذير للمدرب', 'warn_instructor'),
        ];
      case 'job':
        return [
          ('إلغاء نشر الوظيفة', 'سيتم إخفاء الوظيفة من المنصة', 'unpublish_job'),
          ('حذف الوظيفة', 'سيتم حذف الوظيفة نهائياً', 'delete_job'),
          ('تحذير الشركة', 'إرسال تحذير للشركة', 'warn_company'),
        ];
      case 'user':
        return [
          ('تحذير المستخدم', 'إرسال تحذير للمستخدم', 'warn_user'),
          ('تعليق الحساب مؤقتاً', 'تعليق الحساب لمدة 7 أيام', 'suspend_user_7d'),
          ('تعليق الحساب', 'تعليق الحساب لمدة 30 يوم', 'suspend_user_30d'),
          ('إيقاف الحساب نهائياً', 'حظر المستخدم من المنصة', 'ban_user'),
        ];
      case 'company':
        return [
          ('تحذير الشركة', 'إرسال تحذير للشركة', 'warn_company'),
          ('تعليق الشركة', 'تعليق حساب الشركة مؤقتاً', 'suspend_company'),
          ('إلغاء التحقق', 'إلغاء تحقق الشركة', 'revoke_verification'),
        ];
      default:
        return [
          ('حذف المحتوى', 'سيتم حذف المحتوى المخالف', 'delete_content'),
          ('تحذير المستخدم', 'إرسال تحذير لصاحب المحتوى', 'warn_owner'),
        ];
    }
  }
}
