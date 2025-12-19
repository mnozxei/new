import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/impressions_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/verified_badge.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ImpressionsService _impressionsService = ImpressionsService();
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _recordImpression();
  }

  void _recordImpression() {
    _impressionsService.recordImpression(
      entityType: ImpressionEntityType.profile,
      entityId: widget.userId,
    );
  }

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _handleFollow() {
    if (_isAuthenticated) {
      setState(() => _isFollowing = !_isFollowing);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFollowing ? 'تمت المتابعة بنجاح' : 'تم إلغاء المتابعة'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'follow');
    }
  }

  void _handleMessage() {
    if (_isAuthenticated) {
      context.pushNamed(RouteNames.chatRoom, pathParameters: {'id': widget.userId});
    } else {
      LoginRequiredDialog.showForAction(context, 'chat');
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Iconsax.share),
              title: const Text('مشاركة الملف الشخصي'),
              onTap: () {
                Navigator.pop(context);
                Share.share(
                  'تعرف على هذا الملف الشخصي على تماد هب\nhttps://tamadhub.com/user/${widget.userId}',
                  subject: 'ملف شخصي على تماد هب',
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.link),
              title: const Text('نسخ الرابط'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ الرابط')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.slash),
              title: const Text('حظر المستخدم'),
              onTap: () {
                Navigator.pop(context);
                if (_isAuthenticated) {
                  _showBlockConfirmation();
                } else {
                  LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول لحظر المستخدم');
                }
              },
            ),
            ListTile(
              leading: Icon(Iconsax.flag, color: AppColors.error),
              title: Text('الإبلاغ عن المستخدم', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                if (_isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لإبلاغك. سنراجع هذا الحساب.')),
                  );
                } else {
                  LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول للإبلاغ');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حظر المستخدم'),
        content: const Text('هل أنت متأكد من حظر هذا المستخدم؟ لن يتمكن من رؤية ملفك الشخصي أو التواصل معك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حظر المستخدم')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حظر'),
          ),
        ],
      ),
    );
  }

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
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.arrow_right_1,
                  color: AppColors.white,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.more,
                    color: AppColors.white,
                  ),
                ),
                onPressed: _showMoreOptions,
              ),
            ],
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
                          topLeft:
                              Radius.circular(AppConstants.borderRadiusExtraLarge),
                          topRight:
                              Radius.circular(AppConstants.borderRadiusExtraLarge),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.backgroundDark
                              : AppColors.backgroundLight,
                          width: 4,
                        ),
                        boxShadow: AppColors.elevatedShadowLight,
                      ),
                      child: const CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primaryLighter,
                        child: Icon(
                          Iconsax.user,
                          size: 48,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'اسم المستخدم',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        const VerifiedBadge(size: VerifiedBadgeSize.medium),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Text(
                      'مهندس برمجيات',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(label: 'متابع', value: '1.2K'),
                          _StatItem(label: 'متابَع', value: '345'),
                          _StatItem(label: 'منشور', value: '42'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleFollow,
                            child: Text(_isFollowing ? 'إلغاء المتابعة' : 'متابعة'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        GlassIconButton(
                          icon: Iconsax.message,
                          onPressed: _handleMessage,
                          intensity: GlassIntensity.light,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    GlassPanel(
                      title: 'نبذة',
                      intensity: GlassIntensity.light,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مهندس برمجيات شغوف بخبرة تزيد عن 5 سنوات في تطوير تطبيقات الهاتف المحمول.',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.location,
                                size: 16,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: AppConstants.spacingSmall),
                              Text(
                                'الرياض، المملكة العربية السعودية',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    GlassPanel(
                      title: 'آخر المنشورات',
                      intensity: GlassIntensity.light,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacingLarge),
                          child: Column(
                            children: [
                              const Icon(
                                Iconsax.document_text,
                                size: 48,
                                color: AppColors.textTertiaryLight,
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),
                              Text(
                                'لا توجد منشورات بعد',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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
