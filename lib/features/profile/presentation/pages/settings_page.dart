import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'Settings',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SettingsSection(
                  title: 'Account',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.user,
                      title: 'Account Information',
                      subtitle: 'Update your personal details',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.lock,
                      title: 'Password & Security',
                      subtitle: 'Manage your password and 2FA',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.shield_tick,
                      title: 'Privacy',
                      subtitle: 'Control who can see your profile',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'Preferences',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      subtitle: 'Manage your notification preferences',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.moon,
                      title: 'Appearance',
                      subtitle: 'Theme and display settings',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.language_square,
                      title: 'Language',
                      subtitle: 'Arabic',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'Support',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.message_question,
                      title: 'Help Center',
                      subtitle: 'Get help and support',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.document,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms and conditions',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.shield_security,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'Danger Zone',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.trash,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      isDestructive: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: AppConstants.spacingSmall,
            bottom: AppConstants.spacingSmall,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        GlassCard(
          intensity: GlassIntensity.light,
          padding: EdgeInsets.zero,
          child: Column(
            children: children.map((child) {
              final isLast = children.indexOf(child) == children.length - 1;
              return Column(
                children: [
                  child,
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isDestructive ? AppColors.error : AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          color: _isHovered
              ? color.withValues(alpha: 0.05)
              : Colors.transparent,
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
                child: Icon(
                  widget.icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: widget.isDestructive
                            ? AppColors.error
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_left_2,
                color: AppColors.textTertiaryLight,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
