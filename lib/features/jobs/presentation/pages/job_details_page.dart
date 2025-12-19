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
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({
    required this.jobId,
    super.key,
  });

  final String jobId;

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final ImpressionsService _impressionsService = ImpressionsService();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _recordImpression();
  }

  void _recordImpression() {
    _impressionsService.recordImpression(
      entityType: ImpressionEntityType.job,
      entityId: widget.jobId,
    );
  }

  bool get _isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  void _handleSave(BuildContext context) {
    if (_isAuthenticated) {
      setState(() => _isSaved = !_isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'تم حفظ الوظيفة' : 'تم إزالة الحفظ'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      LoginRequiredDialog.showForAction(context, 'save');
    }
  }

  void _handleShare() {
    Share.share(
      'تقدم لهذه الوظيفة على تماد هب\nhttps://tamadhub.com/jobs/${widget.jobId}',
      subject: 'فرصة عمل على تماد هب',
    );
  }

  void _handleApply(BuildContext context) {
    if (_isAuthenticated) {
      context.pushNamed(RouteNames.jobApply, pathParameters: {'id': widget.jobId});
    } else {
      LoginRequiredDialog.showForAction(context, 'apply');
    }
  }

  void _handleViewCompany(BuildContext context) {
    context.push('/companies/company-${widget.jobId}');
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileJobDetails(
        jobId: widget.jobId,
        isSaved: _isSaved,
        onSave: () => _handleSave(context),
        onShare: _handleShare,
        onApply: () => _handleApply(context),
        onViewCompany: () => _handleViewCompany(context),
      ),
      desktop: _DesktopJobDetails(
        jobId: widget.jobId,
        isSaved: _isSaved,
        onSave: () => _handleSave(context),
        onShare: _handleShare,
        onApply: () => _handleApply(context),
        onViewCompany: () => _handleViewCompany(context),
      ),
    );
  }
}

class _MobileJobDetails extends StatelessWidget {
  const _MobileJobDetails({
    required this.jobId,
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    required this.onApply,
    required this.onViewCompany,
  });

  final String jobId;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onApply;
  final VoidCallback onViewCompany;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(isSaved ? Iconsax.bookmark5 : Iconsax.bookmark),
            color: isSaved ? AppColors.primary : null,
            onPressed: onSave,
          ),
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: onShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _JobHeader(),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _JobInfoSection(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const _JobDescriptionSection(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const _JobRequirementsSection(),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _CompanySection(onViewCompany: onViewCompany),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _ApplyBottomSheet(onApply: onApply),
    );
  }
}

class _DesktopJobDetails extends StatelessWidget {
  const _DesktopJobDetails({
    required this.jobId,
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    required this.onApply,
    required this.onViewCompany,
  });

  final String jobId;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onApply;
  final VoidCallback onViewCompany;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_1),
          onPressed: () => context.pop(),
        ),
        title: 'تفاصيل الوظيفة',
        actions: [
          IconButton(
            icon: Icon(isSaved ? Iconsax.bookmark5 : Iconsax.bookmark),
            color: isSaved ? AppColors.primary : null,
            onPressed: onSave,
          ),
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: onShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const _JobHeader(),
                      const SizedBox(height: AppConstants.spacingMedium),
                      const _JobDescriptionSection(),
                      const SizedBox(height: AppConstants.spacingMedium),
                      const _JobRequirementsSection(),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingLarge),
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      _ApplyCard(onApply: onApply, onSave: onSave, isSaved: isSaved),
                      const SizedBox(height: AppConstants.spacingMedium),
                      const _JobInfoSection(),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _CompanySection(onViewCompany: onViewCompany),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobHeader extends StatelessWidget {
  const _JobHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: const Center(
                  child: Text(
                    'C',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
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
                          'اسم الشركة',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        const CompanyVerifiedBadge(
                          isVerified: true,
                          size: VerifiedBadgeSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Text(
                      'مهندس برمجيات أول',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Wrap(
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingSmall,
            children: const [
              _Tag(icon: Iconsax.location, label: 'الرياض، السعودية'),
              _Tag(icon: Iconsax.briefcase, label: 'دوام كامل'),
              _Tag(icon: Iconsax.money, label: '20-35 ألف ريال'),
              _Tag(icon: Iconsax.chart, label: 'مستوى كبير'),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobInfoSection extends StatelessWidget {
  const _JobInfoSection();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      title: 'معلومات الوظيفة',
      intensity: GlassIntensity.light,
      child: const Column(
        children: [
          _InfoRow(label: 'تاريخ النشر', value: 'منذ يومين'),
          _InfoRow(label: 'عدد المتقدمين', value: '45 متقدم'),
          _InfoRow(label: 'الشواغر', value: '3 مناصب'),
          _InfoRow(label: 'الحالة', value: 'مفتوح', isHighlighted: true),
          _InfoRow(label: 'آخر موعد', value: '15 يناير 2026'),
        ],
      ),
    );
  }
}

class _JobDescriptionSection extends StatelessWidget {
  const _JobDescriptionSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'وصف الوظيفة',
      intensity: GlassIntensity.light,
      child: Text(
        '''نبحث عن مهندس برمجيات أول موهوب للانضمام إلى فريقنا المتنامي. في هذا الدور، ستكون مسؤولاً عن تصميم وتطوير وصيانة حلول برمجية عالية الجودة.

ستعمل بشكل وثيق مع فرق متعددة الوظائف لتقديم منتجات مبتكرة تلبي احتياجات عملائنا. المرشح المثالي لديه خلفية قوية في تطوير البرمجيات، ومهارات ممتازة في حل المشكلات، وشغف بتعلم تقنيات جديدة.

هذه فرصة مثيرة لإحداث تأثير كبير في بيئة سريعة وديناميكية.''',
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    );
  }
}

class _JobRequirementsSection extends StatelessWidget {
  const _JobRequirementsSection();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      title: 'المتطلبات',
      intensity: GlassIntensity.light,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementItem('5+ سنوات خبرة في تطوير البرمجيات'),
          _RequirementItem('إتقان Flutter و Dart'),
          _RequirementItem('خبرة في RESTful APIs والخدمات المصغرة'),
          _RequirementItem('مهارات تواصل ممتازة بالعربية والإنجليزية'),
          _RequirementItem('بكالوريوس في علوم الحاسب أو مجال ذي صلة'),
          _RequirementItem('خبرة في منهجيات التطوير الرشيقة'),
        ],
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  const _CompanySection({required this.onViewCompany});

  final VoidCallback onViewCompany;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'عن الشركة',
      intensity: GlassIntensity.light,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: const Center(
                  child: Text(
                    'C',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
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
                          'اسم الشركة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingExtraSmall),
                        const CompanyVerifiedBadge(
                          isVerified: true,
                          size: VerifiedBadgeSize.small,
                        ),
                      ],
                    ),
                    Text(
                      'شركة تقنية',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'شركة تقنية رائدة متخصصة في حلول برمجية مبتكرة للشركات حول العالم.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          OutlinedButton(
            onPressed: onViewCompany,
            child: const Text('عرض ملف الشركة'),
          ),
        ],
      ),
    );
  }
}

class _ApplyBottomSheet extends StatelessWidget {
  const _ApplyBottomSheet({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onApply,
            child: const Text('تقدم الآن'),
          ),
        ),
      ),
    );
  }
}

class _ApplyCard extends StatelessWidget {
  const _ApplyCard({
    required this.onApply,
    required this.onSave,
    required this.isSaved,
  });

  final VoidCallback onApply;
  final VoidCallback onSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      intensity: GlassIntensity.medium,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onApply,
              child: const Text('تقدم الآن'),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSave,
              icon: Icon(isSaved ? Iconsax.bookmark5 : Iconsax.bookmark),
              label: Text(isSaved ? 'تم الحفظ' : 'حفظ الوظيفة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingExtraSmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isHighlighted ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
