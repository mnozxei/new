import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/services/profile_completion_service.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/certificates_preview_card.dart' as cert_widget;
import '../widgets/learning_summary_card.dart' as learning_widget;
import '../widgets/profile_completion_card.dart';
import '../widgets/work_history_preview_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              if (profileState is ProfileLoaded) {
                return ResponsiveLayout(
                  mobile: _MobileProfilePage(
                    profile: profileState.profile,
                    experiences: profileState.experiences,
                    learningStats: profileState.learningStats,
                    certificates: profileState.certificates,
                    completionResult: profileState.completionResult,
                  ),
                  desktop: _DesktopProfilePage(
                    profile: profileState.profile,
                    experiences: profileState.experiences,
                    learningStats: profileState.learningStats,
                    certificates: profileState.certificates,
                    completionResult: profileState.completionResult,
                  ),
                );
              }

              // Fallback to auth user data while loading
              return ResponsiveLayout(
                mobile: _MobileProfilePage(
                  profile: ProfileEntity(
                    id: state.user.id,
                    email: state.user.email,
                    role: state.user.role,
                    fullName: state.user.fullName,
                    avatarUrl: state.user.avatarUrl,
                    jobTitle: state.user.jobTitle,
                    location: state.user.location,
                    bio: state.user.bio,
                    isEmailVerified: state.user.isEmailVerified,
                    followersCount: state.user.followersCount,
                    followingCount: state.user.followingCount,
                    postsCount: state.user.postsCount,
                  ),
                  experiences: const [],
                  learningStats: const LearningStats(),
                  certificates: const [],
                  completionResult: null,
                ),
                desktop: _DesktopProfilePage(
                  profile: ProfileEntity(
                    id: state.user.id,
                    email: state.user.email,
                    role: state.user.role,
                    fullName: state.user.fullName,
                    avatarUrl: state.user.avatarUrl,
                    jobTitle: state.user.jobTitle,
                    location: state.user.location,
                    bio: state.user.bio,
                    isEmailVerified: state.user.isEmailVerified,
                    followersCount: state.user.followersCount,
                    followingCount: state.user.followingCount,
                    postsCount: state.user.postsCount,
                  ),
                  experiences: const [],
                  learningStats: const LearningStats(),
                  certificates: const [],
                  completionResult: null,
                ),
              );
            },
          );
        }

        return const Scaffold(
          body: Center(
            child: GlassLoadingIndicator(),
          ),
        );
      },
    );
  }
}

class _MobileProfilePage extends StatelessWidget {
  const _MobileProfilePage({
    required this.profile,
    required this.experiences,
    required this.learningStats,
    required this.certificates,
    this.completionResult,
  });

  final ProfileEntity profile;
  final List<ExperienceEntity> experiences;
  final LearningStats learningStats;
  final List<CertificatePreview> certificates;
  final ProfileCompletionResult? completionResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (profile.coverImageUrl != null)
                    Image.network(
                      profile.coverImageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                            AppConstants.borderRadiusExtraLarge,
                          ),
                          topRight: Radius.circular(
                            AppConstants.borderRadiusExtraLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.setting_2, color: AppColors.white),
                onPressed: () => context.push(RouteNames.settings),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: Column(
                children: [
                  _buildAvatar(context),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _buildUserInfo(context),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildStats(context),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildActions(context),
                  const SizedBox(height: AppConstants.spacingLarge),
                  // Profile Completion Card
                  if (completionResult != null && completionResult!.percent < 100)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingLarge,
                      ),
                      child: ProfileCompletionCard(
                        completionResult: completionResult!,
                      ),
                    ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  // Learning Summary Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingLarge,
                    ),
                    child: learning_widget.LearningSummaryCard(
                      stats: learning_widget.LearningStats(
                        enrolledCount: learningStats.enrolledCount,
                        inProgressCount: learningStats.inProgressCount,
                        completedCount: learningStats.completedCount,
                        certificatesCount: learningStats.certificatesCount,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  // Certificates Preview Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingLarge,
                    ),
                    child: cert_widget.CertificatesPreviewCard(
                      certificates: certificates.map((c) => cert_widget.CertificatePreview(
                        id: c.id,
                        serialNumber: c.serialNumber,
                        courseName: c.courseName,
                        issuerName: c.issuerName,
                        issuedAt: c.issuedAt,
                        pdfUrl: c.pdfUrl,
                      )).toList(),
                      totalCount: learningStats.certificatesCount,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  // Work History Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingLarge,
                    ),
                    child: WorkHistoryPreviewCard(
                      experiences: experiences,
                      isOwner: true,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildMenuItems(context),
                  const SizedBox(height: AppConstants.spacingExtraLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.backgroundLight,
          width: 4,
        ),
        boxShadow: AppColors.elevatedShadowLight,
      ),
      child: CircleAvatar(
        radius: 56,
        backgroundColor: AppColors.primaryLighter,
        backgroundImage:
            profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
        child: profile.avatarUrl == null
            ? Text(
                profile.initials ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (profile.isEmailVerified) ...[
              const SizedBox(width: AppConstants.spacingSmall),
              const VerifiedBadge(size: VerifiedBadgeSize.medium),
            ],
          ],
        ),
        if (profile.headline != null || profile.jobTitle != null) ...[
          const SizedBox(height: AppConstants.spacingExtraSmall),
          Text(
            profile.headline ?? profile.jobTitle!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
        if (profile.city != null || profile.location != null) ...[
          const SizedBox(height: AppConstants.spacingExtraSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.location,
                size: 16,
                color: AppColors.textTertiaryLight,
              ),
              const SizedBox(width: AppConstants.spacingExtraSmall),
              Text(
                profile.city ?? profile.location!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ],
        if (profile.industry != null) ...[
          const SizedBox(height: AppConstants.spacingExtraSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              profile.industry!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
      ),
      child: GlassCard(
        intensity: GlassIntensity.light,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              label: 'المتابعون',
              value: _formatCount(profile.followersCount),
            ),
            _StatItem(
              label: 'المتابَعون',
              value: _formatCount(profile.followingCount),
            ),
            _StatItem(
              label: 'المنشورات',
              value: _formatCount(profile.postsCount),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.editProfile),
              icon: const Icon(Iconsax.edit),
              label: const Text('تعديل الملف الشخصي'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          GlassIconButton(
            icon: Iconsax.share,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ رابط الملف الشخصي')),
              );
            },
            intensity: GlassIntensity.light,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
      ),
      child: GlassCard(
        intensity: GlassIntensity.light,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _MenuItem(
              icon: Iconsax.briefcase,
              label: 'طلباتي',
              onTap: () => context.push(RouteNames.myApplications),
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.building,
              label: 'شركاتي',
              onTap: () => context.push(RouteNames.companies),
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.book,
              label: 'تعلمي',
              onTap: () => context.push(RouteNames.myLearning),
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.document_text,
              label: 'منشوراتي',
              onTap: () => context.push(RouteNames.posts),
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.bookmark,
              label: 'المحفوظات',
              onTap: () => context.push(RouteNames.savedItems),
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.logout,
              label: 'تسجيل الخروج',
              isDestructive: true,
              onTap: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopProfilePage extends StatelessWidget {
  const _DesktopProfilePage({
    required this.profile,
    required this.experiences,
    required this.learningStats,
    required this.certificates,
    this.completionResult,
  });

  final ProfileEntity profile;
  final List<ExperienceEntity> experiences;
  final LearningStats learningStats;
  final List<CertificatePreview> certificates;
  final ProfileCompletionResult? completionResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'الملف الشخصي',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: AppConstants.spacingMedium),
                      if (completionResult != null && completionResult!.percent < 100)
                        ProfileCompletionCard(
                          completionResult: completionResult!,
                          showDetails: false,
                        ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _buildQuickActions(context),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingLarge),
                Expanded(
                  child: Column(
                    children: [
                      _buildAboutSection(context),
                      const SizedBox(height: AppConstants.spacingMedium),
                      learning_widget.LearningSummaryCard(
                        stats: learning_widget.LearningStats(
                          enrolledCount: learningStats.enrolledCount,
                          inProgressCount: learningStats.inProgressCount,
                          completedCount: learningStats.completedCount,
                          certificatesCount: learningStats.certificatesCount,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      cert_widget.CertificatesPreviewCard(
                        certificates: certificates.map((c) => cert_widget.CertificatePreview(
                          id: c.id,
                          serialNumber: c.serialNumber,
                          courseName: c.courseName,
                          issuerName: c.issuerName,
                          issuedAt: c.issuedAt,
                          pdfUrl: c.pdfUrl,
                        )).toList(),
                        totalCount: learningStats.certificatesCount,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      WorkHistoryPreviewCard(
                        experiences: experiences,
                        isOwner: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel(
      intensity: GlassIntensity.medium,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primaryLighter,
              backgroundImage:
                  profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
              child: profile.avatarUrl == null
                  ? Text(
                      profile.initials ?? 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (profile.isEmailVerified) ...[
                const SizedBox(width: AppConstants.spacingSmall),
                const VerifiedBadge(size: VerifiedBadgeSize.small),
              ],
            ],
          ),
          if (profile.headline != null || profile.jobTitle != null) ...[
            const SizedBox(height: AppConstants.spacingExtraSmall),
            Text(
              profile.headline ?? profile.jobTitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          if (profile.industry != null) ...[
            const SizedBox(height: AppConstants.spacingSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                profile.industry!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: 'المتابعون',
                value: profile.followersCount.toString(),
                compact: true,
              ),
              _StatItem(
                label: 'المتابَعون',
                value: profile.followingCount.toString(),
                compact: true,
              ),
              _StatItem(
                label: 'المنشورات',
                value: profile.postsCount.toString(),
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.editProfile),
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('تعديل الملف الشخصي'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GlassPanel(
      title: 'إجراءات سريعة',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          _MenuItem(
            icon: Iconsax.briefcase,
            label: 'طلباتي',
            onTap: () => context.push(RouteNames.myApplications),
          ),
          _MenuItem(
            icon: Iconsax.building,
            label: 'شركاتي',
            onTap: () => context.push(RouteNames.companies),
          ),
          _MenuItem(
            icon: Iconsax.book,
            label: 'تعلمي',
            onTap: () => context.push(RouteNames.myLearning),
          ),
          _MenuItem(
            icon: Iconsax.logout,
            label: 'تسجيل الخروج',
            isDestructive: true,
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'نبذة عني',
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.bio ?? 'لم يتم إضافة نبذة بعد.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: profile.bio == null ? AppColors.textTertiaryLight : null,
            ),
          ),
          if (profile.skills.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    skill,
                    style: theme.textTheme.bodySmall,
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMedium),
          if (profile.city != null || profile.location != null)
            _InfoRow(icon: Iconsax.location, label: profile.city ?? profile.location!),
          if (profile.website != null)
            _InfoRow(icon: Iconsax.global, label: profile.website!),
          if (profile.createdAt != null)
            _InfoRow(
              icon: Iconsax.calendar,
              label: 'انضم في ${_formatDate(profile.createdAt!)}',
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 18 : 24,
          ),
        ),
        const SizedBox(height: AppConstants.spacingExtraSmall),
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

class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isDestructive
        ? AppColors.error
        : (_isHovered ? AppColors.primary : AppColors.textPrimaryLight);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingMedium,
          ),
          color: _isHovered
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          child: Row(
            children: [
              Icon(widget.icon, color: color, size: 22),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyLarge?.copyWith(color: color),
                ),
              ),
              Icon(
                Iconsax.arrow_left_2,
                color: color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
