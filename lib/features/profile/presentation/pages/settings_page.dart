import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppConstants.spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final localeService = Provider.of<LocaleService>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settings_selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.settings_languageArabic),
              trailing: localeService.isArabic
                  ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                localeService.setLocale(const Locale('ar'));
                Navigator.pop(ctx);
                _showSnackBar(l10n.settings_languageChanged(l10n.settings_languageArabic));
              },
            ),
            ListTile(
              title: Text(l10n.settings_languageEnglish),
              trailing: localeService.isEnglish
                  ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                localeService.setLocale(const Locale('en'));
                Navigator.pop(ctx);
                _showSnackBar(l10n.settings_languageChanged(l10n.settings_languageEnglish));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.sun_1),
              title: const Text('الوضع الفاتح'),
              trailing: !_isDarkMode
                  ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _isDarkMode = false);
                Navigator.pop(ctx);
                _showSnackBar('تم التبديل إلى الوضع الفاتح');
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.moon),
              title: const Text('الوضع الداكن'),
              trailing: _isDarkMode
                  ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _isDarkMode = true);
                Navigator.pop(ctx);
                _showSnackBar('تم التبديل إلى الوضع الداكن');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك نهائياً؟\n\nهذا الإجراء لا يمكن التراجع عنه وسيتم حذف جميع بياناتك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar(
                  'تم إرسال طلب حذف الحساب. سيتم مراجعته خلال 24 ساعة.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('تعذر فتح الرابط', isError: true);
    }
  }

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
                      onTap: () => context.push('${RouteNames.profile}/edit'),
                    ),
                    _SettingsTile(
                      icon: Iconsax.lock,
                      title: 'كلمة المرور والأمان',
                      subtitle: 'إدارة كلمة المرور والمصادقة الثنائية',
                      onTap: () => _showSnackBar(
                          'سيتم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني'),
                    ),
                    _SettingsTile(
                      icon: Iconsax.shield_tick,
                      title: 'الخصوصية',
                      subtitle: 'التحكم في من يمكنه رؤية ملفك الشخصي',
                      onTap: () => context.push(RouteNames.privacySettings),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'التفضيلات',
                  children: [
                    _SettingsTileWithSwitch(
                      icon: Iconsax.notification,
                      title: 'الإشعارات',
                      subtitle: _notificationsEnabled
                          ? 'الإشعارات مفعلة'
                          : 'الإشعارات معطلة',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _showSnackBar(value
                            ? 'تم تفعيل الإشعارات'
                            : 'تم تعطيل الإشعارات');
                      },
                    ),
                    _SettingsTile(
                      icon: Iconsax.moon,
                      title: 'المظهر',
                      subtitle: _isDarkMode ? 'الوضع الداكن' : 'الوضع الفاتح',
                      onTap: _showThemeDialog,
                    ),
                    _SettingsTile(
                      icon: Iconsax.language_square,
                      title: 'اللغة',
                      subtitle: Provider.of<LocaleService>(context).isArabic ? 'العربية' : 'English',
                      onTap: _showLanguageDialog,
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
                      onTap: () => _showSnackBar('مركز المساعدة قيد التطوير'),
                    ),
                    _SettingsTile(
                      icon: Iconsax.document,
                      title: 'شروط الخدمة',
                      subtitle: 'اقرأ الشروط والأحكام',
                      onTap: () => _launchUrl('https://tamadhub.com/terms'),
                    ),
                    _SettingsTile(
                      icon: Iconsax.shield_security,
                      title: 'سياسة الخصوصية',
                      subtitle: 'اقرأ سياسة الخصوصية',
                      onTap: () => _launchUrl('https://tamadhub.com/privacy'),
                    ),
                    _SettingsTile(
                      icon: Iconsax.info_circle,
                      title: 'عن التطبيق',
                      subtitle: 'الإصدار 1.0.0',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'تماد هب',
                          applicationVersion: '1.0.0',
                          applicationLegalese:
                              '© 2025 TAMAD HUB. جميع الحقوق محفوظة.',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                _SettingsSection(
                  title: 'الجلسة',
                  children: [
                    _SettingsTile(
                      icon: Iconsax.logout,
                      title: 'تسجيل الخروج',
                      subtitle: 'تسجيل الخروج من حسابك',
                      isDestructive: true,
                      onTap: _showLogoutDialog,
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
                      onTap: _showDeleteAccountDialog,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLarge),
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
          color: _isHovered ? color.withValues(alpha: 0.05) : Colors.transparent,
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

class _SettingsTileWithSwitch extends StatelessWidget {
  const _SettingsTileWithSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
