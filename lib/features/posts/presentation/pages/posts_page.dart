import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _MobilePostsPage(),
      desktop: const _DesktopPostsPage(),
    );
  }
}

class _MobilePostsPage extends StatelessWidget {
  const _MobilePostsPage();

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'المنشورات',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () => context.push(RouteNames.search),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification),
                onPressed: () {
                  if (_isAuthenticated) {
                    context.push(RouteNames.notifications);
                  } else {
                    LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول لعرض الإشعارات');
                  }
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isAuthenticated) {
            context.pushNamed(RouteNames.createPost);
          } else {
            LoginRequiredDialog.showForAction(context, 'create');
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: AppColors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        itemCount: 10,
        itemBuilder: (context, index) => _PostCard(index: index),
      ),
    );
  }
}

class _DesktopPostsPage extends StatelessWidget {
  const _DesktopPostsPage();

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  child: Row(
                    children: [
                      Text('المنشورات', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Iconsax.search_normal),
                        onPressed: () => context.push(RouteNames.search),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Iconsax.notification),
                            onPressed: () {
                              if (_isAuthenticated) {
                                context.push(RouteNames.notifications);
                              } else {
                                LoginRequiredDialog.show(context, message: 'يجب تسجيل الدخول لعرض الإشعارات');
                              }
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      GlassButton(
                        onPressed: () {
                          if (_isAuthenticated) {
                            context.pushNamed(RouteNames.createPost);
                          } else {
                            LoginRequiredDialog.showForAction(context, 'create');
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.add, size: 18),
                            const SizedBox(width: AppConstants.spacingSmall),
                            Text('منشور جديد', style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
                    itemCount: 10,
                    itemBuilder: (context, index) => _PostCard(index: index),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassPanel(
                  title: 'المواضيع الرائجة',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => InkWell(
                        onTap: () => context.push('${RouteNames.search}?q=موضوع_${index + 1}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
                          child: Row(
                            children: [
                              Text('#موضوع_${index + 1}', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                              const Spacer(),
                              Text('${(index + 1) * 123} منشور', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GlassPanel(
                  title: 'اقتراحات المتابعة',
                  intensity: GlassIntensity.light,
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => _SuggestedCompany(index: index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.index});

  final int index;

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _showMoreOptions(BuildContext context) {
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
              leading: const Icon(Iconsax.bookmark),
              title: const Text('حفظ المنشور'),
              onTap: () {
                Navigator.pop(context);
                if (_isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ المنشور')),
                  );
                } else {
                  LoginRequiredDialog.showForAction(context, 'save');
                }
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
              leading: const Icon(Iconsax.flag),
              title: const Text('الإبلاغ عن المنشور'),
              onTap: () {
                Navigator.pop(context);
                if (_isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لإبلاغك. سنراجع المنشور.')),
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

  void _handleLike(BuildContext context) {
    if (_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الإعجاب بالمنشور'), duration: Duration(seconds: 1)),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'like');
    }
  }

  void _handleComment(BuildContext context) {
    if (_isAuthenticated) {
      context.pushNamed(RouteNames.postDetails, pathParameters: {'id': '$index'});
    } else {
      LoginRequiredDialog.showForAction(context, 'comment');
    }
  }

  void _handleShare(BuildContext context) {
    const shareService = ShareService();
    shareService.shareEntity(
      entityType: ShareEntityType.post,
      entityId: '$index',
      title: 'شاهد هذا المنشور على تماد هب',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.pushNamed(RouteNames.postDetails, pathParameters: {'id': '$index'}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLighter,
                child: const Text('ش', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('شركة التقنية المتقدمة', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        if (index % 2 == 0) const VerifiedBadge(size: VerifiedBadgeSize.small, type: VerifiedBadgeType.company),
                      ],
                    ),
                    Text('منذ ${index + 1} ساعات', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.more, size: 20),
                onPressed: () => _showMoreOptions(context),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'هذا نص تجريبي للمنشور رقم ${index + 1}. يمكن أن يحتوي المنشور على نص طويل ومحتوى متنوع.',
            style: theme.textTheme.bodyMedium,
          ),
          if (index % 3 == 0) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.primaryExtraLight,
                child: const Center(child: Icon(Iconsax.image, size: 48, color: AppColors.primaryLighter)),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              _PostAction(icon: Iconsax.like_1, label: '${(index + 1) * 12}', onTap: () => _handleLike(context)),
              const SizedBox(width: AppConstants.spacingLarge),
              _PostAction(icon: Iconsax.message, label: '${(index + 1) * 3}', onTap: () => _handleComment(context)),
              const SizedBox(width: AppConstants.spacingLarge),
              _PostAction(icon: Iconsax.share, label: 'مشاركة', onTap: () => _handleShare(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondaryLight),
            const SizedBox(width: AppConstants.spacingExtraSmall),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}

class _SuggestedCompany extends StatelessWidget {
  const _SuggestedCompany({required this.index});

  final int index;

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/companies/company-$index'),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLighter,
              child: Text('${index + 1}', style: const TextStyle(color: AppColors.white)),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/companies/company-$index'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('شركة ${index + 1}', style: theme.textTheme.titleSmall),
                  Text('${(index + 1) * 1000} متابع', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت المتابعة بنجاح'), duration: Duration(seconds: 1)),
                );
              } else {
                LoginRequiredDialog.showForAction(context, 'follow');
              }
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }
}
