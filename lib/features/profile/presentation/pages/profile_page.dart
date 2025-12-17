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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return ResponsiveLayout(
            mobile: _MobileProfilePage(user: state.user),
            desktop: _DesktopProfilePage(user: state.user),
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
  const _MobileProfilePage({required this.user});

  final dynamic user;

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
                onPressed: () => context.push('${RouteNames.profile}/settings'),
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
                  _buildMenuItems(context),
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
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                user.initials ?? 'U',
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
              user.displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.isEmailVerified) ...[
              const SizedBox(width: AppConstants.spacingSmall),
              const VerifiedBadge(size: VerifiedBadgeSize.medium),
            ],
          ],
        ),
        if (user.jobTitle != null) ...[
          const SizedBox(height: AppConstants.spacingExtraSmall),
          Text(
            user.jobTitle!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
        if (user.location != null) ...[
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
                user.location!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
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
            _StatItem(label: 'Followers', value: '0'),
            _StatItem(label: 'Following', value: '0'),
            _StatItem(label: 'Posts', value: '0'),
          ],
        ),
      ),
    );
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
              onPressed: () => context.push('${RouteNames.profile}/edit'),
              icon: const Icon(Iconsax.edit),
              label: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          GlassIconButton(
            icon: Iconsax.share,
            onPressed: () {},
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
              label: 'My Applications',
              onTap: () => context.push(RouteNames.myApplications),
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.building,
              label: 'My Companies',
              onTap: () => context.push(RouteNames.companies),
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.book,
              label: 'My Courses',
              onTap: () {},
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.document_text,
              label: 'My Posts',
              onTap: () {},
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.bookmark,
              label: 'Saved Items',
              onTap: () {},
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Iconsax.logout,
              label: 'Sign Out',
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
  const _DesktopProfilePage({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () => context.push('${RouteNames.profile}/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      _buildProfileCard(context),
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
                      _buildActivitySection(context),
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
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.initials ?? 'U',
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
                user.displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.isEmailVerified) ...[
                const SizedBox(width: AppConstants.spacingSmall),
                const VerifiedBadge(size: VerifiedBadgeSize.small),
              ],
            ],
          ),
          if (user.jobTitle != null) ...[
            const SizedBox(height: AppConstants.spacingExtraSmall),
            Text(
              user.jobTitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(label: 'Followers', value: '0', compact: true),
              _StatItem(label: 'Following', value: '0', compact: true),
              _StatItem(label: 'Posts', value: '0', compact: true),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('${RouteNames.profile}/edit'),
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GlassPanel(
      title: 'Quick Actions',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          _MenuItem(
            icon: Iconsax.briefcase,
            label: 'My Applications',
            onTap: () => context.push(RouteNames.myApplications),
          ),
          _MenuItem(
            icon: Iconsax.building,
            label: 'My Companies',
            onTap: () => context.push(RouteNames.companies),
          ),
          _MenuItem(
            icon: Iconsax.book,
            label: 'My Courses',
            onTap: () {},
          ),
          _MenuItem(
            icon: Iconsax.logout,
            label: 'Sign Out',
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
      title: 'About',
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.bio ?? 'No bio added yet.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: user.bio == null ? AppColors.textTertiaryLight : null,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          if (user.location != null)
            _InfoRow(icon: Iconsax.location, label: user.location!),
          if (user.website != null)
            _InfoRow(icon: Iconsax.global, label: user.website!),
          _InfoRow(icon: Iconsax.calendar, label: 'Joined December 2025'),
        ],
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'Recent Activity',
      intensity: GlassIntensity.light,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Column(
            children: [
              Icon(
                Iconsax.activity,
                size: 48,
                color: AppColors.textTertiaryLight,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                'No recent activity',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
