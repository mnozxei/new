import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/impressions_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/verified_badge.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({
    required this.courseId,
    super.key,
  });

  final String courseId;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final ImpressionsService _impressionsService = ImpressionsService();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _recordImpression();
  }

  void _recordImpression() {
    _impressionsService.recordImpression(
      entityType: ImpressionEntityType.course,
      entityId: widget.courseId,
    );
  }

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _handleSave() {
    if (_isAuthenticated) {
      setState(() => _isSaved = !_isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'تم حفظ الدورة' : 'تم إزالة الحفظ'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'save');
    }
  }

  void _handleShare() {
    const shareService = ShareService();
    shareService.shareEntity(
      entityType: ShareEntityType.course,
      entityId: widget.courseId,
      title: 'تعلم معي في هذه الدورة على تماد هب',
    );
  }

  void _handleEnroll() {
    if (_isAuthenticated) {
      context.pushNamed(RouteNames.courseEnroll, pathParameters: {'id': widget.courseId});
    } else {
      LoginRequiredDialog.showForAction(context, 'enroll');
    }
  }

  void _handleViewInstructor() {
    context.push('/user/instructor-${widget.courseId}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                child: const Icon(Iconsax.arrow_right_1, color: AppColors.white),
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
                  child: Icon(
                    _isSaved ? Iconsax.bookmark5 : Iconsax.bookmark,
                    color: AppColors.white,
                  ),
                ),
                onPressed: _handleSave,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.share, color: AppColors.white),
                ),
                onPressed: _handleShare,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Icon(
                    Iconsax.book_1,
                    size: 64,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'دورة تطوير تطبيقات Flutter الشاملة',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 18, color: AppColors.warning),
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      Text('4.8', style: theme.textTheme.titleSmall),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        '(234 تقييم)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      const Icon(Iconsax.people, size: 18, color: AppColors.textSecondaryLight),
                      const SizedBox(width: AppConstants.spacingExtraSmall),
                      Text(
                        '1,234 طالب',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _InstructorCard(onViewProfile: _handleViewInstructor),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const _CourseStats(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'عن هذه الدورة',
                    intensity: GlassIntensity.light,
                    child: Text(
                      'تعلم Flutter من الصفر وقم ببناء تطبيقات جميلة ومترجمة محلياً للهاتف والويب وسطح المكتب من قاعدة كود واحدة. تغطي هذه الدورة الشاملة كل ما تحتاج معرفته لتصبح مطور Flutter محترف.',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  GlassPanel(
                    title: 'محتوى الدورة',
                    trailing: Text(
                      '12 قسم',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    intensity: GlassIntensity.light,
                    child: Column(
                      children: List.generate(
                        5,
                        (index) => _SectionItem(
                          index: index,
                          courseId: widget.courseId,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _EnrollBottomSheet(onEnroll: _handleEnroll),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard({required this.onViewProfile});

  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLighter,
            child: const Text(
              'م',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'أحمد المدرب',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingExtraSmall),
                    const VerifiedBadge(
                      size: VerifiedBadgeSize.small,
                      type: VerifiedBadgeType.instructor,
                    ),
                  ],
                ),
                Text(
                  'مطور Flutter أول',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onViewProfile,
            child: const Text('عرض الملف'),
          ),
        ],
      ),
    );
  }
}

class _CourseStats extends StatelessWidget {
  const _CourseStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Iconsax.clock,
            value: '12س 30د',
            label: 'المدة',
          ),
        ),
        SizedBox(width: AppConstants.spacingSmall),
        Expanded(
          child: _StatCard(
            icon: Iconsax.video_play,
            value: '85',
            label: 'درس',
          ),
        ),
        SizedBox(width: AppConstants.spacingSmall),
        Expanded(
          child: _StatCard(
            icon: Iconsax.medal_star,
            value: 'شهادة',
            label: 'معتمدة',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionItem extends StatelessWidget {
  const _SectionItem({
    required this.index,
    required this.courseId,
  });

  final int index;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        'القسم ${index + 1}: البداية',
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        '5 دروس',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      children: List.generate(
        3,
        (lessonIndex) => ListTile(
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: lessonIndex == 0
                ? AppColors.primary
                : AppColors.primaryLightest,
            child: Icon(
              lessonIndex == 0 ? Iconsax.tick_circle : Iconsax.play,
              size: 14,
              color: lessonIndex == 0 ? AppColors.white : AppColors.primary,
            ),
          ),
          title: Text(
            'الدرس ${lessonIndex + 1}: المقدمة',
            style: theme.textTheme.bodyMedium,
          ),
          subtitle: Text(
            '10 دقائق',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          onTap: () => context.push(
            '${RouteNames.courses}/$courseId/lesson/lesson-$lessonIndex',
          ),
        ),
      ),
    );
  }
}

class _EnrollBottomSheet extends StatelessWidget {
  const _EnrollBottomSheet({required this.onEnroll});

  final VoidCallback onEnroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مجاني',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'وصول مدى الحياة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppConstants.spacingLarge),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onEnroll,
                  child: const Text('سجل الآن'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
