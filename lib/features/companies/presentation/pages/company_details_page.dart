import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/verified_badge.dart';

class CompanyDetailsPage extends StatelessWidget {
  const CompanyDetailsPage({
    required this.companyId,
    super.key,
  });

  final String companyId;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileCompanyDetailsPage(companyId: companyId),
      desktop: _DesktopCompanyDetailsPage(companyId: companyId),
    );
  }
}

class _MobileCompanyDetailsPage extends StatelessWidget {
  const _MobileCompanyDetailsPage({required this.companyId});

  final String companyId;

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
                  color: AppColors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.arrow_right_1, color: AppColors.textPrimaryLight),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.share, color: AppColors.textPrimaryLight),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          boxShadow: AppColors.shadowMedium,
                        ),
                        child: Center(
                          child: Text('ت م', style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('شركة التقنية المتقدمة', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(width: AppConstants.spacingExtraSmall),
                                const VerifiedBadge(size: VerifiedBadgeSize.medium, type: VerifiedBadgeType.company),
                              ],
                            ),
                            Text('تقنية المعلومات • الرياض', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.add, size: 18),
                              const SizedBox(width: AppConstants.spacingSmall),
                              Text('متابعة', style: theme.textTheme.labelLarge),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      GlassIconButton(
                        icon: Iconsax.message,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _CompanyStats(),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _AboutSection(),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _JobsSection(companyId: companyId),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _PostsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopCompanyDetailsPage extends StatelessWidget {
  const _DesktopCompanyDetailsPage({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: AppConstants.spacingMedium,
                    right: AppConstants.spacingMedium,
                    child: Row(
                      children: [
                        GlassIconButton(
                          icon: Iconsax.arrow_right_1,
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    right: 40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        boxShadow: AppColors.shadowLarge,
                      ),
                      child: Center(
                        child: Text('ت م', style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('شركة التقنية المتقدمة', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: AppConstants.spacingSmall),
                            const VerifiedBadge(size: VerifiedBadgeSize.medium, type: VerifiedBadgeType.company),
                          ],
                        ),
                        Text('تقنية المعلومات • الرياض، المملكة العربية السعودية', style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondaryLight)),
                        const SizedBox(height: AppConstants.spacingLarge),
                        _AboutSection(),
                        const SizedBox(height: AppConstants.spacingLarge),
                        _JobsSection(companyId: companyId),
                        const SizedBox(height: AppConstants.spacingLarge),
                        _PostsSection(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingLarge),
                  SizedBox(
                    width: 320,
                    child: Column(
                      children: [
                        GlassCard(
                          intensity: GlassIntensity.light,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GlassButton(
                                      onPressed: () {},
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Iconsax.add, size: 18),
                                          const SizedBox(width: AppConstants.spacingSmall),
                                          Text('متابعة', style: theme.textTheme.labelLarge),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacingSmall),
                                  GlassIconButton(icon: Iconsax.message, onPressed: () {}),
                                  const SizedBox(width: AppConstants.spacingSmall),
                                  GlassIconButton(icon: Iconsax.share, onPressed: () {}),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spacingLarge),
                              _CompanyStats(),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        GlassPanel(
                          title: 'معلومات التواصل',
                          intensity: GlassIntensity.light,
                          child: Column(
                            children: [
                              _ContactItem(icon: Iconsax.global, label: 'www.techadvanced.sa'),
                              _ContactItem(icon: Iconsax.call, label: '+966 11 123 4567'),
                              _ContactItem(icon: Iconsax.sms, label: 'info@techadvanced.sa'),
                              _ContactItem(icon: Iconsax.location, label: 'الرياض، حي العليا'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingExtraLarge),
          ],
        ),
      ),
    );
  }
}

class _CompanyStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: '5,234', label: 'متابع'),
        _StatItem(value: '12', label: 'وظيفة'),
        _StatItem(value: '150', label: 'موظف'),
        _StatItem(value: '45', label: 'منشور'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'نبذة عن الشركة',
      intensity: GlassIntensity.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'شركة التقنية المتقدمة هي شركة رائدة في مجال تقنية المعلومات والحلول الرقمية. نقدم خدمات متكاملة في تطوير البرمجيات، الحوسبة السحابية، والذكاء الاصطناعي.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Wrap(
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingSmall,
            children: [
              _Tag(label: 'تقنية المعلومات'),
              _Tag(label: 'تطوير البرمجيات'),
              _Tag(label: 'الذكاء الاصطناعي'),
              _Tag(label: 'الحوسبة السحابية'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

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
      child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary)),
    );
  }
}

class _JobsSection extends StatelessWidget {
  const _JobsSection({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'الوظائف المتاحة',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('عرض الكل'),
      ),
      intensity: GlassIntensity.light,
      child: Column(
        children: List.generate(
          3,
          (index) => _JobItem(index: index),
        ),
      ),
    );
  }
}

class _JobItem extends StatelessWidget {
  const _JobItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobs = ['مطور Flutter', 'مهندس DevOps', 'محلل بيانات'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: const Icon(Iconsax.briefcase, color: AppColors.white),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jobs[index % jobs.length], style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('دوام كامل • الرياض', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_left_2, size: 20, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }
}

class _PostsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      title: 'آخر المنشورات',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('عرض الكل'),
      ),
      intensity: GlassIntensity.light,
      child: Column(
        children: List.generate(
          2,
          (index) => _PostItem(index: index),
        ),
      ),
    );
  }
}

class _PostItem extends StatelessWidget {
  const _PostItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نحن سعداء بالإعلان عن إطلاق منتجنا الجديد الذي سيغير مفهوم التقنية في المنطقة...',
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Row(
            children: [
              Icon(Iconsax.like_1, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text('${(index + 1) * 45}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(width: AppConstants.spacingMedium),
              Icon(Iconsax.message, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text('${(index + 1) * 12}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
              const Spacer(),
              Text('منذ ${index + 1} يوم', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryLight)),
            ],
          ),
          if (index < 1) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            const Divider(),
          ],
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
