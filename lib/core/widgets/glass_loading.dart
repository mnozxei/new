import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Alias for [GlassLoadingIndicator] for backward compatibility
typedef GlassLoading = GlassLoadingIndicator;

class GlassLoadingIndicator extends StatelessWidget {
  const GlassLoadingIndicator({
    super.key,
    this.size = 48,
    this.strokeWidth = 3,
    this.color,
    this.backgroundColor,
    this.showGlass = true,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showGlass;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? (isDark ? AppColors.primaryLight : AppColors.primary),
        ),
        backgroundColor: backgroundColor ??
            (isDark ? AppColors.primaryDark : AppColors.primaryLightest),
      ),
    );

    if (!showGlass) {
      return indicator;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.glassDark.withValues(alpha: 0.2)
                : AppColors.glassLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorderDark.withValues(alpha: 0.3)
                  : AppColors.glassBorderLight.withValues(alpha: 0.3),
            ),
          ),
          child: indicator,
        ),
      ),
    );
  }
}

class GlassLoadingOverlay extends StatelessWidget {
  const GlassLoadingOverlay({
    super.key,
    this.isLoading = true,
    this.child,
    this.message,
    this.blurSigma,
  });

  final bool isLoading;
  final Widget? child;
  final String? message;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? 5;

    return Stack(
      children: [
        if (child != null) child!,
        if (isLoading)
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: Container(
                  color: isDark
                      ? AppColors.overlayDark.withValues(alpha: 0.5)
                      : AppColors.overlayLight.withValues(alpha: 0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GlassLoadingIndicator(),
                        if (message != null) ...[
                          const SizedBox(height: AppConstants.spacingMedium),
                          Text(
                            message!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class GlassShimmer extends StatelessWidget {
  const GlassShimmer({
    required this.child,
    super.key,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (!enabled) {
      return child;
    }

    return Shimmer.fromColors(
      baseColor:
          baseColor ?? (isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight),
      highlightColor: highlightColor ??
          (isDark
              ? AppColors.shimmerHighlightDark
              : AppColors.shimmerHighlightLight),
      child: child,
    );
  }
}

class GlassShimmerCard extends StatelessWidget {
  const GlassShimmerCard({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius,
    this.margin,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassShimmer(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
    );
  }
}

class GlassShimmerList extends StatelessWidget {
  const GlassShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = AppConstants.spacingMedium,
    this.padding,
    this.scrollDirection = Axis.vertical,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      scrollDirection: scrollDirection,
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingMedium),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(
        width: scrollDirection == Axis.horizontal ? spacing : 0,
        height: scrollDirection == Axis.vertical ? spacing : 0,
      ),
      itemBuilder: (context, index) {
        return GlassShimmer(
          child: Container(
            height: scrollDirection == Axis.vertical ? itemHeight : null,
            width: scrollDirection == Axis.horizontal ? itemHeight * 1.5 : null,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: scrollDirection == Axis.vertical
                  ? Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.shimmerBaseDark
                                : AppColors.shimmerBaseLight,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.shimmerBaseDark
                                      : AppColors.shimmerBaseLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              Container(
                                height: 12,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.shimmerBaseDark
                                      : AppColors.shimmerBaseLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.shimmerBaseDark
                                  : AppColors.shimmerBaseLight,
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.shimmerBaseDark
                                : AppColors.shimmerBaseLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingExtraSmall),
                        Container(
                          height: 10,
                          width: 80,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.shimmerBaseDark
                                : AppColors.shimmerBaseLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class GlassShimmerProfile extends StatelessWidget {
  const GlassShimmerProfile({
    super.key,
    this.avatarSize = 80,
    this.showCoverImage = true,
    this.coverHeight = 150,
  });

  final double avatarSize;
  final bool showCoverImage;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCoverImage)
            Container(
              height: coverHeight,
              width: double.infinity,
              color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
            ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: showCoverImage
                      ? Offset(0, -avatarSize / 2 - AppConstants.spacingMedium)
                      : Offset.zero,
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.shimmerBaseDark
                          : AppColors.shimmerBaseLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        width: 4,
                      ),
                    ),
                  ),
                ),
                if (showCoverImage)
                  SizedBox(height: -avatarSize / 2 + AppConstants.spacingSmall),
                Container(
                  height: 20,
                  width: 180,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.shimmerBaseDark
                        : AppColors.shimmerBaseLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.shimmerBaseDark
                        : AppColors.shimmerBaseLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.shimmerBaseDark
                        : AppColors.shimmerBaseLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Container(
                  height: 12,
                  width: 250,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.shimmerBaseDark
                        : AppColors.shimmerBaseLight,
                    borderRadius: BorderRadius.circular(4),
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

class GlassPulseLoader extends StatefulWidget {
  const GlassPulseLoader({
    super.key,
    this.size = 12,
    this.color,
    this.count = 3,
    this.spacing = 8,
  });

  final double size;
  final Color? color;
  final int count;
  final double spacing;

  @override
  State<GlassPulseLoader> createState() => _GlassPulseLoaderState();
}

class _GlassPulseLoaderState extends State<GlassPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        widget.color ?? (isDark ? AppColors.primaryLight : AppColors.primary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.count, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double delay = index * 0.2;
            final double value =
                ((_controller.value + delay) % 1.0 * 2 - 1).abs();
            final double scale = 0.5 + value * 0.5;
            final double opacity = 0.3 + value * 0.7;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class GlassSkeletonLine extends StatelessWidget {
  const GlassSkeletonLine({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class GlassSkeletonCircle extends StatelessWidget {
  const GlassSkeletonCircle({
    super.key,
    this.size = 48,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
