import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // General settings
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;

  // Job notifications
  bool _newJobMatches = true;
  bool _applicationUpdates = true;
  bool _savedJobAlerts = true;

  // Course notifications
  bool _enrollmentConfirmation = true;
  bool _lessonReminders = true;
  bool _courseUpdates = true;
  bool _certificateReady = true;

  // Social notifications
  bool _newFollowers = true;
  bool _postLikes = true;
  bool _postComments = true;
  bool _mentions = true;

  // Company notifications
  bool _teamUpdates = true;
  bool _verificationStatus = true;
  bool _applicationsReceived = true;

  // Marketing
  bool _promotions = false;
  bool _newsletter = true;

  void _saveSettings() {
    // TODO: Save to backend via BLoC
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'إعدادات الإشعارات',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('حفظ'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Methods
            _SectionHeader(title: 'طرق التوصيل'),
            GlassCard(
              intensity: GlassIntensity.light,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingSwitch(
                    icon: Iconsax.notification,
                    title: 'إشعارات الدفع',
                    subtitle: 'تلقي الإشعارات على جهازك',
                    value: _pushEnabled,
                    onChanged: (value) => setState(() => _pushEnabled = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.sms,
                    title: 'البريد الإلكتروني',
                    subtitle: 'تلقي الإشعارات عبر البريد',
                    value: _emailEnabled,
                    onChanged: (value) => setState(() => _emailEnabled = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.message,
                    title: 'الرسائل النصية',
                    subtitle: 'تلقي الإشعارات عبر SMS',
                    value: _smsEnabled,
                    onChanged: (value) => setState(() => _smsEnabled = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Job Notifications
            _SectionHeader(title: 'إشعارات الوظائف'),
            GlassCard(
              intensity: GlassIntensity.light,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingSwitch(
                    icon: Iconsax.briefcase,
                    title: 'وظائف مطابقة',
                    subtitle: 'إشعار عند توفر وظائف تطابق ملفك',
                    value: _newJobMatches,
                    onChanged: (value) => setState(() => _newJobMatches = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.document,
                    title: 'تحديثات الطلبات',
                    subtitle: 'إشعار عند تغيير حالة طلباتك',
                    value: _applicationUpdates,
                    onChanged: (value) => setState(() => _applicationUpdates = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.bookmark,
                    title: 'الوظائف المحفوظة',
                    subtitle: 'إشعار عند تغير الوظائف المحفوظة',
                    value: _savedJobAlerts,
                    onChanged: (value) => setState(() => _savedJobAlerts = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Course Notifications
            _SectionHeader(title: 'إشعارات الدورات'),
            GlassCard(
              intensity: GlassIntensity.light,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingSwitch(
                    icon: Iconsax.book,
                    title: 'تأكيد التسجيل',
                    subtitle: 'إشعار عند التسجيل في دورة',
                    value: _enrollmentConfirmation,
                    onChanged: (value) => setState(() => _enrollmentConfirmation = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.clock,
                    title: 'تذكير الدروس',
                    subtitle: 'تذكير لمتابعة دروسك',
                    value: _lessonReminders,
                    onChanged: (value) => setState(() => _lessonReminders = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.refresh,
                    title: 'تحديثات الدورات',
                    subtitle: 'إشعار عند إضافة محتوى جديد',
                    value: _courseUpdates,
                    onChanged: (value) => setState(() => _courseUpdates = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.medal_star,
                    title: 'الشهادات',
                    subtitle: 'إشعار عند جاهزية شهادتك',
                    value: _certificateReady,
                    onChanged: (value) => setState(() => _certificateReady = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Social Notifications
            _SectionHeader(title: 'الإشعارات الاجتماعية'),
            GlassCard(
              intensity: GlassIntensity.light,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingSwitch(
                    icon: Iconsax.user_add,
                    title: 'متابعين جدد',
                    subtitle: 'إشعار عند متابعة أحد لك',
                    value: _newFollowers,
                    onChanged: (value) => setState(() => _newFollowers = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.heart,
                    title: 'الإعجابات',
                    subtitle: 'إشعار عند الإعجاب بمنشوراتك',
                    value: _postLikes,
                    onChanged: (value) => setState(() => _postLikes = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.message,
                    title: 'التعليقات',
                    subtitle: 'إشعار عند التعليق على منشوراتك',
                    value: _postComments,
                    onChanged: (value) => setState(() => _postComments = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.tag_user,
                    title: 'الإشارات',
                    subtitle: 'إشعار عند الإشارة إليك',
                    value: _mentions,
                    onChanged: (value) => setState(() => _mentions = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Company Notifications
            _SectionHeader(title: 'إشعارات الشركة'),
            GlassCard(
              intensity: GlassIntensity.light,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingSwitch(
                    icon: Iconsax.people,
                    title: 'تحديثات الفريق',
                    subtitle: 'إشعار عند تغييرات في فريق العمل',
                    value: _teamUpdates,
                    onChanged: (value) => setState(() => _teamUpdates = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.verify,
                    title: 'حالة التوثيق',
                    subtitle: 'إشعار عند تغير حالة توثيق الشركة',
                    value: _verificationStatus,
                    onChanged: (value) => setState(() => _verificationStatus = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.document_text,
                    title: 'طلبات التوظيف',
                    subtitle: 'إشعار عند استلام طلبات جديدة',
                    value: _applicationsReceived,
                    onChanged: (value) => setState(() => _applicationsReceived = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Marketing
            _SectionHeader(title: 'التسويق'),
            GlassCard(
              intensity: GlassIntensity.light,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingSwitch(
                    icon: Iconsax.discount_shape,
                    title: 'العروض والتخفيضات',
                    subtitle: 'إشعار بأحدث العروض',
                    value: _promotions,
                    onChanged: (value) => setState(() => _promotions = value),
                  ),
                  const Divider(height: 1),
                  _SettingSwitch(
                    icon: Iconsax.document,
                    title: 'النشرة الإخبارية',
                    subtitle: 'تلقي النشرة الأسبوعية',
                    value: _newsletter,
                    onChanged: (value) => setState(() => _newsletter = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Quiet Hours
            _SectionHeader(title: 'ساعات الهدوء'),
            GlassCard(
              intensity: GlassIntensity.light,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _showQuietHoursDialog(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingSmall,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.primaryExtraLight,
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall,
                              ),
                            ),
                            child: const Icon(
                              Iconsax.moon,
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
                                  'ساعات الهدوء',
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  'لا تزعجني من 11 مساءً إلى 7 صباحاً',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Iconsax.arrow_left_2,
                            size: 18,
                            color: AppColors.textTertiaryLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Reset
            Center(
              child: TextButton.icon(
                onPressed: () => _showResetDialog(),
                icon: const Icon(Iconsax.refresh, color: AppColors.error),
                label: const Text(
                  'إعادة تعيين الإعدادات الافتراضية',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),
          ],
        ),
      ),
    );
  }

  void _showQuietHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ساعات الهدوء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('وقت البدء'),
              trailing: TextButton(
                onPressed: () async {
                  // TODO: Time picker
                },
                child: const Text('11:00 مساءً'),
              ),
            ),
            ListTile(
              title: const Text('وقت الانتهاء'),
              trailing: TextButton(
                onPressed: () async {
                  // TODO: Time picker
                },
                child: const Text('7:00 صباحاً'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text('هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pushEnabled = true;
                _emailEnabled = true;
                _smsEnabled = false;
                _newJobMatches = true;
                _applicationUpdates = true;
                _savedJobAlerts = true;
                _enrollmentConfirmation = true;
                _lessonReminders = true;
                _courseUpdates = true;
                _certificateReady = true;
                _newFollowers = true;
                _postLikes = true;
                _postComments = true;
                _mentions = true;
                _teamUpdates = true;
                _verificationStatus = true;
                _applicationsReceived = true;
                _promotions = false;
                _newsletter = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إعادة تعيين الإعدادات')),
              );
            },
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppConstants.spacingMedium,
        right: AppConstants.spacingSmall,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
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

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSmall),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
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
