import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/company_member_entity.dart';
import '../bloc/company_bloc.dart';

class CompanyTeamPage extends StatefulWidget {
  const CompanyTeamPage({
    super.key,
    required this.companyId,
  });

  final String companyId;

  @override
  State<CompanyTeamPage> createState() => _CompanyTeamPageState();
}

class _CompanyTeamPageState extends State<CompanyTeamPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<CompanyBloc>().add(LoadCompanyMembers(widget.companyId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInviteDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (context) => _InviteMemberSheet(companyId: widget.companyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'إدارة الفريق',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.user_add),
            onPressed: _showInviteDialog,
            tooltip: 'دعوة عضو',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الأعضاء'),
            Tab(text: 'المدربين'),
            Tab(text: 'الدعوات'),
          ],
        ),
      ),
      body: BlocBuilder<CompanyBloc, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _MembersTab(companyId: widget.companyId),
              _InstructorsTab(companyId: widget.companyId),
              _InvitationsTab(companyId: widget.companyId),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInviteDialog,
        icon: const Icon(Iconsax.user_add),
        label: const Text('دعوة عضو'),
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder data
    final members = [
      _MemberData(
        name: 'أحمد محمد',
        email: 'ahmed@company.com',
        role: CompanyMemberRole.owner,
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      _MemberData(
        name: 'سارة علي',
        email: 'sara@company.com',
        role: CompanyMemberRole.admin,
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      _MemberData(
        name: 'محمد خالد',
        email: 'mohammed@company.com',
        role: CompanyMemberRole.member,
        avatarUrl: null,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.people,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا يوجد أعضاء',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _MemberCard(member: member);
      },
    );
  }
}

class _InstructorsTab extends StatelessWidget {
  const _InstructorsTab({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder data
    final instructors = [
      _InstructorData(
        name: 'د. فاطمة أحمد',
        specialty: 'تطوير البرمجيات',
        coursesCount: 5,
        studentsCount: 234,
        rating: 4.8,
        avatarUrl: null,
      ),
      _InstructorData(
        name: 'م. عبدالله سعيد',
        specialty: 'التصميم والجرافيك',
        coursesCount: 3,
        studentsCount: 156,
        rating: 4.6,
        avatarUrl: null,
      ),
    ];

    if (instructors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.teacher,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا يوجد مدربين',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'قم بدعوة مدربين لإنشاء دورات للشركة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: instructors.length,
      itemBuilder: (context, index) {
        final instructor = instructors[index];
        return _InstructorCard(instructor: instructor);
      },
    );
  }
}

class _InvitationsTab extends StatelessWidget {
  const _InvitationsTab({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder data
    final invitations = [
      _InvitationData(
        email: 'newmember@email.com',
        role: CompanyMemberRole.member,
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'pending',
      ),
      _InvitationData(
        email: 'instructor@email.com',
        role: CompanyMemberRole.instructor,
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
      ),
    ];

    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.sms,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              'لا توجد دعوات معلقة',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return _InvitationCard(invitation: invitation);
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final _MemberData member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLighter,
            child: Text(
              member.name[0],
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
                  member.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  member.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          _RoleBadge(role: member.role),
          if (member.role != CompanyMemberRole.owner)
            PopupMenuButton<String>(
              icon: const Icon(Iconsax.more, size: 20),
              onSelected: (value) {
                // Handle action
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Iconsax.user_edit, size: 18),
                      SizedBox(width: AppConstants.spacingSmall),
                      Text('تغيير الدور'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Iconsax.user_remove, size: 18, color: AppColors.error),
                      SizedBox(width: AppConstants.spacingSmall),
                      Text('إزالة', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard({required this.instructor});

  final _InstructorData instructor;

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
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.secondary,
                child: Text(
                  instructor.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      instructor.specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.star1,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      instructor.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              _StatChip(
                icon: Iconsax.book,
                value: '${instructor.coursesCount}',
                label: 'دورات',
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              _StatChip(
                icon: Iconsax.people,
                value: '${instructor.studentsCount}',
                label: 'طالب',
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // View instructor profile
                },
                child: const Text('عرض الملف'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});

  final _InvitationData invitation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.sms,
              color: AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.email,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _RoleBadge(role: invitation.role),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      '• ${_formatTimeAgo(invitation.sentAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 20),
            onPressed: () {
              // Resend invitation
            },
            tooltip: 'إعادة الإرسال',
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, size: 20, color: AppColors.error),
            onPressed: () {
              // Cancel invitation
            },
            tooltip: 'إلغاء',
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inMinutes} دقيقة';
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final CompanyMemberRole role;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (role) {
      case CompanyMemberRole.owner:
        color = AppColors.primary;
        label = 'مالك';
        break;
      case CompanyMemberRole.admin:
        color = AppColors.secondary;
        label = 'مدير';
        break;
      case CompanyMemberRole.instructor:
        color = AppColors.success;
        label = 'مدرب';
        break;
      case CompanyMemberRole.member:
        color = AppColors.info;
        label = 'عضو';
        break;
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
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _InviteMemberSheet extends StatefulWidget {
  const _InviteMemberSheet({required this.companyId});

  final String companyId;

  @override
  State<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<_InviteMemberSheet> {
  final _emailController = TextEditingController();
  CompanyMemberRole _selectedRole = CompanyMemberRole.member;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvitation() {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // TODO: Send invitation
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الدعوة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.spacingMedium,
        right: AppConstants.spacingMedium,
        top: AppConstants.spacingMedium,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiaryLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text(
            'دعوة عضو جديد',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text(
            'البريد الإلكتروني',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'example@company.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Iconsax.sms),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'الدور',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Wrap(
            spacing: AppConstants.spacingSmall,
            children: [
              _RoleChip(
                role: CompanyMemberRole.member,
                isSelected: _selectedRole == CompanyMemberRole.member,
                onTap: () => setState(() => _selectedRole = CompanyMemberRole.member),
              ),
              _RoleChip(
                role: CompanyMemberRole.instructor,
                isSelected: _selectedRole == CompanyMemberRole.instructor,
                onTap: () => setState(() => _selectedRole = CompanyMemberRole.instructor),
              ),
              _RoleChip(
                role: CompanyMemberRole.admin,
                isSelected: _selectedRole == CompanyMemberRole.admin,
                onTap: () => setState(() => _selectedRole = CompanyMemberRole.admin),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _sendInvitation,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('إرسال الدعوة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final CompanyMemberRole role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String label;
    switch (role) {
      case CompanyMemberRole.member:
        label = 'عضو';
        break;
      case CompanyMemberRole.instructor:
        label = 'مدرب';
        break;
      case CompanyMemberRole.admin:
        label = 'مدير';
        break;
      default:
        label = '';
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

// Data classes
class _MemberData {
  const _MemberData({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.joinedAt,
  });

  final String name;
  final String email;
  final CompanyMemberRole role;
  final String? avatarUrl;
  final DateTime joinedAt;
}

class _InstructorData {
  const _InstructorData({
    required this.name,
    required this.specialty,
    required this.coursesCount,
    required this.studentsCount,
    required this.rating,
    this.avatarUrl,
  });

  final String name;
  final String specialty;
  final int coursesCount;
  final int studentsCount;
  final double rating;
  final String? avatarUrl;
}

class _InvitationData {
  const _InvitationData({
    required this.email,
    required this.role,
    required this.sentAt,
    required this.status,
  });

  final String email;
  final CompanyMemberRole role;
  final DateTime sentAt;
  final String status;
}
