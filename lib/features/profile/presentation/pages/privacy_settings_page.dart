import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../config/routes/route_names.dart';

/// Privacy settings page for controlling who can see profile, message, etc.
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  // Privacy settings state
  bool _profilePublic = true;
  bool _showOnlineStatus = true;
  bool _allowMessages = true;
  bool _showActivityStatus = true;
  bool _showCourseProgress = false;
  String _whoCanSeeEmail = 'followers';
  String _whoCanSeePhone = 'nobody';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'إعدادات الخصوصية',
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        children: [
          // Profile Visibility Section
          _buildSectionHeader(theme, 'ظهور الملف الشخصي'),
          _buildSwitchTile(
            title: 'ملف شخصي عام',
            subtitle: 'السماح لأي شخص بمشاهدة ملفك الشخصي',
            icon: Iconsax.eye,
            value: _profilePublic,
            onChanged: (value) => setState(() => _profilePublic = value),
          ),
          _buildSwitchTile(
            title: 'إظهار حالة الاتصال',
            subtitle: 'عرض متى كنت نشطاً آخر مرة',
            icon: Iconsax.status,
            value: _showOnlineStatus,
            onChanged: (value) => setState(() => _showOnlineStatus = value),
          ),
          _buildSwitchTile(
            title: 'إظهار النشاط',
            subtitle: 'عرض نشاطك الأخير للآخرين',
            icon: Iconsax.activity,
            value: _showActivityStatus,
            onChanged: (value) => setState(() => _showActivityStatus = value),
          ),
          _buildSwitchTile(
            title: 'إظهار تقدم الدورات',
            subtitle: 'السماح للآخرين بمشاهدة تقدمك في الدورات',
            icon: Iconsax.book,
            value: _showCourseProgress,
            onChanged: (value) => setState(() => _showCourseProgress = value),
          ),

          const SizedBox(height: AppConstants.spacingLarge),

          // Contact Info Section
          _buildSectionHeader(theme, 'معلومات الاتصال'),
          _buildDropdownTile(
            title: 'من يمكنه رؤية البريد الإلكتروني',
            icon: Iconsax.sms,
            value: _whoCanSeeEmail,
            options: const [
              ('everyone', 'الجميع'),
              ('followers', 'المتابعون فقط'),
              ('nobody', 'لا أحد'),
            ],
            onChanged: (value) => setState(() => _whoCanSeeEmail = value),
          ),
          _buildDropdownTile(
            title: 'من يمكنه رؤية رقم الهاتف',
            icon: Iconsax.call,
            value: _whoCanSeePhone,
            options: const [
              ('everyone', 'الجميع'),
              ('followers', 'المتابعون فقط'),
              ('nobody', 'لا أحد'),
            ],
            onChanged: (value) => setState(() => _whoCanSeePhone = value),
          ),

          const SizedBox(height: AppConstants.spacingLarge),

          // Messaging Section
          _buildSectionHeader(theme, 'الرسائل'),
          _buildSwitchTile(
            title: 'السماح بالرسائل',
            subtitle: 'السماح للمستخدمين بإرسال رسائل إليك',
            icon: Iconsax.message,
            value: _allowMessages,
            onChanged: (value) => setState(() => _allowMessages = value),
          ),

          const SizedBox(height: AppConstants.spacingLarge),

          // Blocked Users Section
          _buildSectionHeader(theme, 'المستخدمون المحظورون'),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: const Icon(Iconsax.user_remove, color: AppColors.error),
            ),
            title: const Text('إدارة المحظورين'),
            subtitle: const Text('عرض وإدارة المستخدمين المحظورين'),
            trailing: const Icon(Iconsax.arrow_left_2),
            onTap: () => context.push(RouteNames.blockedUsers),
          ),

          const SizedBox(height: AppConstants.spacingExtraLarge),

          // Save Button
          FilledButton(
            onPressed: _saveSettings,
            child: const Text('حفظ الإعدادات'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppConstants.spacingSmall,
        top: AppConstants.spacingSmall,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required IconData icon,
    required String value,
    required List<(String, String)> options,
    required ValueChanged<String> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option.$1,
              child: Text(option.$2),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement saving to Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ إعدادات الخصوصية'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }
}
