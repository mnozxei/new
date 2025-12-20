import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/post_entity.dart';
import '../bloc/post_bloc.dart';

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
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: GlassLoadingIndicator());
          }

          if (state is PostError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<PostBloc>().add(const LoadFeed()),
            );
          }

          if (state is FeedLoaded) {
            if (state.posts.isEmpty) {
              return const _EmptyFeedView();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(const LoadFeed());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.posts.length) {
                    // Load more trigger
                    context.read<PostBloc>().add(const LoadMoreFeed());
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _PostCard(post: state.posts[index]);
                },
              ),
            );
          }

          return const Center(child: GlassLoadingIndicator());
        },
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
                  child: BlocBuilder<PostBloc, PostState>(
                    builder: (context, state) {
                      if (state is PostLoading) {
                        return const Center(child: GlassLoadingIndicator());
                      }

                      if (state is PostError) {
                        return _ErrorView(
                          message: state.message,
                          onRetry: () => context.read<PostBloc>().add(const LoadFeed()),
                        );
                      }

                      if (state is FeedLoaded) {
                        if (state.posts.isEmpty) {
                          return const _EmptyFeedView();
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<PostBloc>().add(const LoadFeed());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
                            itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.posts.length) {
                                context.read<PostBloc>().add(const LoadMoreFeed());
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return _PostCard(post: state.posts[index]);
                            },
                          ),
                        );
                      }

                      return const Center(child: GlassLoadingIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: const _SidebarContent(),
          ),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassPanel(
          title: 'ابدأ هنا',
          intensity: GlassIntensity.light,
          child: Column(
            children: [
              _SidebarItem(
                icon: Iconsax.edit,
                label: 'أنشئ منشوراً جديداً',
                onTap: () => context.push(RouteNames.createPost),
              ),
              _SidebarItem(
                icon: Iconsax.briefcase,
                label: 'تصفح الوظائف',
                onTap: () => context.push(RouteNames.jobs),
              ),
              _SidebarItem(
                icon: Iconsax.book_1,
                label: 'استكشف الدورات',
                onTap: () => context.push(RouteNames.courses),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        GlassPanel(
          title: 'روابط سريعة',
          intensity: GlassIntensity.light,
          child: Column(
            children: [
              _SidebarItem(
                icon: Iconsax.building_4,
                label: 'الشركات',
                onTap: () => context.push(RouteNames.companies),
              ),
              _SidebarItem(
                icon: Iconsax.profile_2user,
                label: 'الملف الشخصي',
                onTap: () => context.push(RouteNames.profile),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
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
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            const Icon(Iconsax.arrow_left_2, size: 16, color: AppColors.textTertiaryLight),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeedView extends StatelessWidget {
  const _EmptyFeedView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.document, size: 64, color: AppColors.textTertiaryLight),
            const SizedBox(height: AppConstants.spacingMedium),
            Text('لا توجد منشورات حالياً', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'كن أول من ينشر محتوى!',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.createPost),
              icon: const Icon(Iconsax.add),
              label: const Text('إنشاء منشور'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, size: 64, color: AppColors.error),
            const SizedBox(height: AppConstants.spacingMedium),
            Text('حدث خطأ', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final PostEntity post;

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
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
                Navigator.pop(ctx);
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
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ الرابط')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.flag),
              title: const Text('الإبلاغ عن المنشور'),
              onTap: () {
                Navigator.pop(ctx);
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
      context.read<PostBloc>().add(TogglePostLike(postId: post.id));
    } else {
      LoginRequiredDialog.showForAction(context, 'like');
    }
  }

  void _handleComment(BuildContext context) {
    context.push('${RouteNames.posts}/${post.id}');
  }

  void _handleShare(BuildContext context) {
    Share.share(
      'شاهد هذا المنشور على تماد هب\nhttps://tamadhub.com/posts/${post.id}',
      subject: 'منشور من تماد هب',
    );
    if (_isAuthenticated) {
      context.read<PostBloc>().add(SharePost(postId: post.id));
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name[0];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = post.company?.name ?? post.author?.fullName ?? 'مستخدم';
    final isVerified = post.company?.isVerified ?? post.author?.isVerified ?? false;
    final avatarUrl = post.company?.logoUrl ?? post.author?.avatarUrl;

    return GlassCard(
      intensity: GlassIntensity.light,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      onTap: () => context.push('${RouteNames.posts}/${post.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLighter,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(_getInitials(displayName), style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        if (isVerified)
                          VerifiedBadge(
                            size: VerifiedBadgeSize.small,
                            type: post.company != null ? VerifiedBadgeType.company : VerifiedBadgeType.user,
                          ),
                      ],
                    ),
                    Text(_getTimeAgo(post.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
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
          Text(post.content, style: theme.textTheme.bodyMedium),
          if (post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Image.network(
                post.mediaUrls.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: AppColors.primaryExtraLight,
                  child: const Center(child: Icon(Iconsax.image, size: 48, color: AppColors.primaryLighter)),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              _PostAction(
                icon: post.isLiked ? Iconsax.like_15 : Iconsax.like_1,
                label: '${post.likeCount}',
                isActive: post.isLiked,
                onTap: () => _handleLike(context),
              ),
              const SizedBox(width: AppConstants.spacingLarge),
              _PostAction(icon: Iconsax.message, label: '${post.commentCount}', onTap: () => _handleComment(context)),
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
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? AppColors.primary : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppConstants.spacingExtraSmall),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
