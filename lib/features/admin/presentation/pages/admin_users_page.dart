import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';

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
        title: 'إدارة المستخدمين',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export_1),
            onPressed: () {
              // TODO: Export users
            },
            tooltip: 'تصدير',
          ),
          IconButton(
            icon: const Icon(Iconsax.user_add),
            onPressed: () => _showAddUserDialog(context),
            tooltip: 'إضافة مستخدم',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'المستخدمين'),
            Tab(text: 'المدربين'),
            Tab(text: 'المديرين'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'البحث عن مستخدم...',
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
                    onChanged: (value) {
                      // TODO: Filter users
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                PopupMenuButton<String>(
                  icon: const Icon(Iconsax.filter),
                  tooltip: 'فلترة',
                  onSelected: (value) {
                    setState(() => _selectedRole = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'all', child: Text('الكل')),
                    const PopupMenuItem(value: 'active', child: Text('نشط')),
                    const PopupMenuItem(
                      value: 'inactive',
                      child: Text('غير نشط'),
                    ),
                    const PopupMenuItem(
                      value: 'suspended',
                      child: Text('موقوف'),
                    ),
                  ],
                ),
              ],
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
                  value: '12,456',
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                _StatChip(
                  label: 'نشط',
                  value: '10,234',
                  color: AppColors.success,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                _StatChip(
                  label: 'موقوف',
                  value: '45',
                  color: AppColors.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Users List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UsersListView(roleFilter: null),
                _UsersListView(roleFilter: 'user'),
                _UsersListView(roleFilter: 'instructor'),
                _UsersListView(roleFilter: 'admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مستخدم جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Iconsax.sms),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الدور',
                  prefixIcon: Icon(Iconsax.user_tag),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('مستخدم')),
                  DropdownMenuItem(value: 'instructor', child: Text('مدرب')),
                  DropdownMenuItem(value: 'admin', child: Text('مدير')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Add user
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
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
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall,
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersListView extends StatelessWidget {
  const _UsersListView({this.roleFilter});

  final String? roleFilter;

  @override
  Widget build(BuildContext context) {
    // Placeholder data - will be replaced with BLoC
    final users = List.generate(
      20,
      (index) => _UserData(
        id: 'user_$index',
        name: 'مستخدم ${index + 1}',
        email: 'user${index + 1}@example.com',
        role: index % 4 == 0
            ? 'admin'
            : index % 3 == 0
                ? 'instructor'
                : 'user',
        status: index % 10 == 0
            ? 'suspended'
            : index % 5 == 0
                ? 'inactive'
                : 'active',
        joinDate: DateTime.now().subtract(Duration(days: index * 5)),
      ),
    );

    final filteredUsers = roleFilter == null
        ? users
        : users.where((u) => u.role == roleFilter).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _UserCard(user: filteredUsers[index]);
      },
    );
  }
}

class _UserData {
  const _UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime joinDate;
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final _UserData user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLighter,
            child: Text(
              user.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    _RoleBadge(role: user.role),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingExtraSmall),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingExtraSmall),
                Row(
                  children: [
                    _StatusBadge(status: user.status),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      'انضم ${_formatDate(user.joinDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more),
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Iconsax.eye, size: 18),
                    SizedBox(width: 8),
                    Text('عرض'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Iconsax.edit, size: 18),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              if (user.status == 'active')
                const PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      Icon(Iconsax.slash, size: 18, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text('إيقاف', style: TextStyle(color: AppColors.warning)),
                    ],
                  ),
                )
              else if (user.status == 'suspended')
                const PopupMenuItem(
                  value: 'activate',
                  child: Row(
                    children: [
                      Icon(Iconsax.tick_circle, size: 18, color: AppColors.success),
                      SizedBox(width: 8),
                      Text('تفعيل', style: TextStyle(color: AppColors.success)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        // TODO: Navigate to user profile
        break;
      case 'edit':
        // TODO: Show edit dialog
        break;
      case 'suspend':
        _showConfirmDialog(
          context,
          title: 'إيقاف المستخدم',
          message: 'هل أنت متأكد من إيقاف هذا المستخدم؟',
          onConfirm: () {
            // TODO: Suspend user
          },
        );
        break;
      case 'activate':
        // TODO: Activate user
        break;
      case 'delete':
        _showConfirmDialog(
          context,
          title: 'حذف المستخدم',
          message: 'هل أنت متأكد من حذف هذا المستخدم؟ لا يمكن التراجع عن هذا الإجراء.',
          onConfirm: () {
            // TODO: Delete user
          },
          isDestructive: true,
        );
        break;
    }
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'اليوم';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays ~/ 7} أسابيع';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (role) {
      case 'admin':
        label = 'مدير';
        color = AppColors.error;
        break;
      case 'instructor':
        label = 'مدرب';
        color = AppColors.primary;
        break;
      default:
        label = 'مستخدم';
        color = AppColors.info;
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status) {
      case 'active':
        label = 'نشط';
        color = AppColors.success;
        break;
      case 'inactive':
        label = 'غير نشط';
        color = AppColors.warning;
        break;
      case 'suspended':
        label = 'موقوف';
        color = AppColors.error;
        break;
      default:
        label = status;
        color = AppColors.textSecondaryLight;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}
