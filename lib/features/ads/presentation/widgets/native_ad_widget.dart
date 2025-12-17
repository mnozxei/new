import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/ad_entity.dart';

class NativeAdWidget extends StatelessWidget {
  const NativeAdWidget({
    super.key,
    required this.ad,
    required this.placement,
    this.onImpression,
    this.onClick,
    this.isCompact = false,
  });

  final AdEntity ad;
  final AdPlacement placement;
  final VoidCallback? onImpression;
  final VoidCallback? onClick;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onImpression?.call();
    });

    return isCompact
        ? _CompactNativeAd(ad: ad, onClick: _handleClick)
        : _FullNativeAd(ad: ad, onClick: _handleClick);
  }

  Future<void> _handleClick() async {
    onClick?.call();

    if (ad.ctaUrl != null && ad.ctaUrl!.isNotEmpty) {
      final uri = Uri.tryParse(ad.ctaUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

class _FullNativeAd extends StatelessWidget {
  const _FullNativeAd({
    required this.ad,
    required this.onClick,
  });

  final AdEntity ad;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingSmall,
      ),
      child: GlassCard(
        intensity: GlassIntensity.light,
        child: InkWell(
          onTap: onClick,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (ad.companyLogo != null || ad.advertiserLogo != null) ...[
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryExtraLight,
                        backgroundImage: ad.companyLogo != null || ad.advertiserLogo != null
                            ? NetworkImage(ad.companyLogo ?? ad.advertiserLogo!)
                            : null,
                        child: ad.companyLogo == null && ad.advertiserLogo == null
                            ? const Icon(Iconsax.building, color: AppColors.primary, size: 20)
                            : null,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ad.companyName ?? ad.advertiserName ?? 'إعلان',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiaryLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'إعلان مدعوم',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.textTertiaryLight,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.more, size: 20),
                      onPressed: () => _showAdOptions(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  ad.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ad.description != null) ...[
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    ad.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (ad.imageUrl != null) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        ad.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryExtraLight,
                          child: const Center(
                            child: Icon(Iconsax.image, size: 48, color: AppColors.primaryLighter),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (ad.ctaText != null) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      onPressed: onClick,
                      child: Text(
                        ad.ctaText!,
                        style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAdOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.eye_slash),
              title: const Text('إخفاء هذا الإعلان'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.info_circle),
              title: const Text('لماذا أرى هذا الإعلان؟'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.flag),
              title: const Text('الإبلاغ عن هذا الإعلان'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactNativeAd extends StatelessWidget {
  const _CompactNativeAd({
    required this.ad,
    required this.onClick,
  });

  final AdEntity ad;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Row(
            children: [
              if (ad.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      ad.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryExtraLight,
                        child: const Icon(Iconsax.image, color: AppColors.primaryLighter),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'إعلان',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiaryLight,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (ad.companyName != null)
                          Text(
                            ad.companyName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingExtraSmall),
                    Text(
                      ad.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ad.ctaText != null) ...[
                      const SizedBox(height: AppConstants.spacingSmall),
                      Text(
                        ad.ctaText!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              const Icon(
                Iconsax.arrow_left_2,
                size: 20,
                color: AppColors.textTertiaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SponsoredJobAd extends StatelessWidget {
  const SponsoredJobAd({
    super.key,
    required this.ad,
    required this.onImpression,
    required this.onClick,
  });

  final AdEntity ad;
  final VoidCallback onImpression;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onImpression();
    });

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.star1, size: 12, color: AppColors.white),
                        const SizedBox(width: 4),
                        Text(
                          'وظيفة مميزة',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (ad.companyLogo != null)
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(ad.companyLogo!),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                ad.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              if (ad.companyName != null)
                Text(
                  ad.companyName!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              if (ad.description != null) ...[
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  ad.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppConstants.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: onClick,
                      child: Text(
                        ad.ctaText ?? 'تقدم الآن',
                        style: theme.textTheme.labelLarge?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
