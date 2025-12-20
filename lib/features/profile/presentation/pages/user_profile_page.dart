import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/impressions_service.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_loading.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../domain/entities/profile_entity.dart';
import '../widgets/certificates_preview_card.dart';
import '../widgets/learning_summary_card.dart';
import '../widgets/work_history_preview_card.dart';

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
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _profileData;
  List<ExperienceEntity> _experiences = [];
  LearningStats _learningStats = const LearningStats();
  List<CertificatePreview> _certificates = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _recordImpression();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final supabase = Supabase.instance.client;

      // Fetch profile data
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .single();

      // Fetch experiences
      final experiencesResponse = await supabase
          .from('profile_experiences')
          .select()
          .eq('user_id', widget.userId)
          .order('is_current', ascending: false)
          .order('start_date', ascending: false);

      // Fetch learning stats
      final statsResponse = await supabase
          .rpc('get_user_learning_stats', params: {'p_user_id': widget.userId});

      // Fetch certificates
      final certificatesResponse = await supabase
          .rpc('get_user_certificates', params: {
        'p_user_id': widget.userId,
        'p_limit': 3,
      });

      setState(() {
        _profileData = profileResponse;
        _experiences = (experiencesResponse as List)
            .map((e) => ExperienceEntity.fromJson(e))
            .toList();
        if (statsResponse != null && (statsResponse as List).isNotEmpty) {
          _learningStats = LearningStats.fromJson(statsResponse[0]);
        }
        _certificates = (certificatesResponse as List)
            .map((e) => CertificatePreview.fromJson(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _recordImpression() {
    _impressionsService.recordImpression(
      entityType: ImpressionEntityType.profile,
      entityId: widget.userId,
    );
  }

  bool get _isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;

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
            if (_isAuthenticated) ...[
              ListTile(
                leading: const Icon(Iconsax.slash),
                title: const Text('حظر المستخدم'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirmation();
                },
              ),
              ListTile(
                leading: Icon(Iconsax.flag, color: AppColors.error),
                title: Text('الإبلاغ عن المستخدم',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('شكراً لإبلاغك. سنراجع هذا الحساب.')),
                  );
                },
              ),
            ],
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
        content: const Text(
            'هل أنت متأكد من حظر هذا المستخدم؟ لن يتمكن من رؤية ملفك الشخصي أو التواصل معك.'),
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

    if (_isLoading) {
      return Scaffold(
        appBar: const GlassAppBar(title: 'الملف الشخصي'),
        body: const Center(child: GlassLoadingIndicator()),
      );
    }

    if (_error != null || _profileData == null) {
      return Scaffold(
        appBar: const GlassAppBar(title: 'الملف الشخصي'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.user_remove,
                size: 64,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                'تعذر تحميل الملف الشخصي',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              TextButton.icon(
                onPressed: _loadUserProfile,
                icon: const Icon(Iconsax.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profileData!;
    final fullName = profile['full_name'] as String? ?? 'مستخدم';
    final headline = profile['headline'] as String? ??
        profile['job_title'] as String? ??
        '';
    final bio = profile['bio'] as String?;
    final avatarUrl = profile['avatar_url'] as String?;
    final location = profile['location'] as String? ?? profile['city'] as String?;
    final skills = (profile['skills'] as List<dynamic>?)?.cast<String>() ?? [];
    final industry = profile['industry'] as String?;
    final isVerified = profile['is_verified'] as bool? ?? false;
    final followersCount = profile['followers_count'] as int? ?? 0;
    final followingCount = profile['following_count'] as int? ?? 0;
    final postsCount = profile['posts_count'] as int? ?? 0;

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
                    // Profile Avatar
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
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primaryLighter,
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? const Icon(
                                Iconsax.user,
                                size: 48,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Name and Verification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: AppConstants.spacingSmall),
                          const VerifiedBadge(size: VerifiedBadgeSize.medium),
                        ],
                      ],
                    ),
                    if (headline.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      Text(
                        headline,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (industry != null) ...[
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          industry,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.spacingLarge),
                    // Stats Card
                    GlassCard(
                      intensity: GlassIntensity.light,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            label: 'متابع',
                            value: _formatNumber(followersCount),
                          ),
                          _StatItem(
                            label: 'متابَع',
                            value: _formatNumber(followingCount),
                          ),
                          _StatItem(
                            label: 'منشور',
                            value: _formatNumber(postsCount),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Action Buttons
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
                    // Bio Section
                    if (bio != null && bio.isNotEmpty) ...[
                      GlassPanel(
                        title: 'نبذة',
                        intensity: GlassIntensity.light,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bio,
                              style: theme.textTheme.bodyLarge,
                            ),
                            if (location != null) ...[
                              const SizedBox(height: AppConstants.spacingMedium),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: AppConstants.spacingSmall),
                                  Text(
                                    location,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                    ],
                    // Skills Section
                    if (skills.isNotEmpty) ...[
                      GlassCard(
                        intensity: GlassIntensity.light,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Iconsax.cpu,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacingSmall),
                                Text(
                                  'المهارات',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: skills.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                    ],
                    // Work History Section (read-only)
                    WorkHistoryPreviewCard(
                      experiences: _experiences,
                      isOwner: false,
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Learning Summary Section (read-only)
                    LearningSummaryCard(
                      stats: _learningStats,
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Certificates Section (read-only)
                    CertificatesPreviewCard(
                      certificates: _certificates,
                      totalCount: _certificates.length,
                    ),
                    const SizedBox(height: AppConstants.spacingExtraLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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
    final isDark = theme.brightness == Brightness.dark;

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
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
