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
        title: 'الإعدادات',
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
                  title: 'الحساب',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.user,
                      title: 'معلومات الحساب',
                      subtitle: 'تحديث بياناتك الشخصية',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.lock,
                      title: 'كلمة المرور والأمان',
                      subtitle: 'إدارة كلمة المرور والمصادقة الثنائية',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.shield_tick,
                      title: 'الخصوصية',
                      subtitle: 'التحكم في من يمكنه رؤية ملفك الشخصي',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'التفضيلات',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.notification,
                      title: 'الإشعارات',
                      subtitle: 'إدارة تفضيلات الإشعارات',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.moon,
                      title: 'المظهر',
                      subtitle: 'إعدادات السمة والعرض',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.language_square,
                      title: 'اللغة',
                      subtitle: 'العربية',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'الدعم',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.message_question,
                      title: 'مركز المساعدة',
                      subtitle: 'احصل على المساعدة والدعم',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.document,
                      title: 'شروط الخدمة',
                      subtitle: 'اقرأ الشروط والأحكام',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Iconsax.shield_security,
                      title: 'سياسة الخصوصية',
                      subtitle: 'اقرأ سياسة الخصوصية',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'منطقة الخطر',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.trash,
                      title: 'حذف الحساب',
                      subtitle: 'حذف حسابك نهائياً',
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
