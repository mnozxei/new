import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma,
    this.opacity,
    this.borderOpacity,
    this.borderWidth,
    this.gradient,
    this.onTap,
    this.onLongPress,
    this.elevation,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double? blurSigma;
  final double? opacity;
  final double? borderOpacity;
  final double? borderWidth;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? elevation;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? AppConstants.glassBlurSigma;
    final double effectiveOpacity = opacity ?? AppConstants.glassOpacity;
    final double effectiveBorderOpacity =
        borderOpacity ?? AppConstants.glassBorderOpacity;
    final BorderRadiusGeometry effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusLarge);

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: isDark
                      ? AppColors.shadowDark.withValues(alpha: elevation! * 0.1)
                      : AppColors.shadowLight.withValues(alpha: elevation! * 0.1),
                  blurRadius: elevation! * 2,
                  spreadRadius: elevation! * 0.5,
                  offset: Offset(0, elevation!),
                ),
              ]
            : AppColors.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius as BorderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.glassDark
                                .withValues(alpha: effectiveOpacity),
                            AppColors.glassDark
                                .withValues(alpha: effectiveOpacity * 0.5),
                          ]
                        : [
                            AppColors.glassLight
                                .withValues(alpha: effectiveOpacity + 0.1),
                            AppColors.glassLight
                                .withValues(alpha: effectiveOpacity * 0.5),
                          ],
                  ),
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: isDark
                    ? AppColors.glassBorderDark
                        .withValues(alpha: effectiveBorderOpacity)
                    : AppColors.glassBorderLight
                        .withValues(alpha: effectiveBorderOpacity),
                width: borderWidth ?? 1.0,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      container = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: container,
      );
    }

    return container;
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.intensity = GlassIntensity.medium,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GlassIntensity intensity;

  @override
  Widget build(BuildContext context) {
    final settings = intensity.settings;

    return GlassContainer(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingMedium),
      margin: margin,
      borderRadius:
          borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusLarge),
      blurSigma: settings.blur,
      opacity: settings.opacity,
      borderOpacity: settings.borderOpacity,
      elevation: settings.elevation,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.header,
    this.footer,
    this.title,
    this.trailing,
    this.onTap,
    this.intensity = GlassIntensity.medium,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? header;
  final Widget? footer;
  final String? title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final GlassIntensity intensity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.zero,
      onTap: onTap,
      intensity: intensity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null || title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMedium,
                AppConstants.spacingMedium,
                AppConstants.spacingMedium,
                AppConstants.spacingSmall,
              ),
              child: header ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      if (trailing != null) trailing!,
                    ],
                  ),
            ),
          Flexible(
            child: Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMedium,
                    vertical: AppConstants.spacingSmall,
                  ),
              child: child,
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMedium,
                AppConstants.spacingSmall,
                AppConstants.spacingMedium,
                AppConstants.spacingMedium,
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

class GlassButton extends StatefulWidget {
  const GlassButton({
    required this.onPressed,
    super.key,
    this.child,
    this.label,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.intensity = GlassIntensity.light,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final VoidCallback? onPressed;
  final Widget? child;
  final String? label;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final GlassIntensity intensity;
  final bool isLoading;
  final bool isDisabled;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final settings = widget.intensity.settings;

    final Widget content = widget.child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
              )
            else ...[
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: AppConstants.iconSizeMedium,
                  color: widget.isDisabled
                      ? (isDark
                          ? AppColors.textDisabledDark
                          : AppColors.textDisabledLight)
                      : (isDark ? AppColors.textPrimaryDark : AppColors.primary),
                ),
              if (widget.icon != null && widget.label != null)
                const SizedBox(width: AppConstants.spacingSmall),
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: widget.isDisabled
                        ? (isDark
                            ? AppColors.textDisabledDark
                            : AppColors.textDisabledLight)
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.primary),
                  ),
                ),
            ],
          ],
        );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              width: widget.width,
              height: widget.height ?? 48,
              padding: widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLarge,
                    vertical: AppConstants.spacingSmall,
                  ),
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
              blurSigma: settings.blur,
              opacity: _isPressed ? settings.opacity + 0.1 : settings.opacity,
              borderOpacity: _isPressed
                  ? settings.borderOpacity + 0.1
                  : settings.borderOpacity,
              child: Center(child: content),
            ),
          );
        },
      ),
    );
  }
}

class GlassIconButton extends StatefulWidget {
  const GlassIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.size,
    this.iconSize,
    this.iconColor,
    this.intensity = GlassIntensity.light,
    this.isLoading = false,
    this.isDisabled = false,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final double? iconSize;
  final Color? iconColor;
  final GlassIntensity intensity;
  final bool isLoading;
  final bool isDisabled;
  final String? badge;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveSize = widget.size ?? 44;
    final double effectiveIconSize =
        widget.iconSize ?? AppConstants.iconSizeMedium;
    final settings = widget.intensity.settings;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isDisabled && !widget.isLoading) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.isDisabled && !widget.isLoading) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        if (!widget.isDisabled && !widget.isLoading) {
          _controller.reverse();
        }
      },
      onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GlassContainer(
                  width: effectiveSize,
                  height: effectiveSize,
                  borderRadius: BorderRadius.circular(effectiveSize / 2),
                  blurSigma: settings.blur,
                  opacity: settings.opacity,
                  borderOpacity: settings.borderOpacity,
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: effectiveIconSize,
                            height: effectiveIconSize,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.primary,
                              ),
                            ),
                          )
                        : Icon(
                            widget.icon,
                            size: effectiveIconSize,
                            color: widget.iconColor ??
                                (widget.isDisabled
                                    ? (isDark
                                        ? AppColors.textDisabledDark
                                        : AppColors.textDisabledLight)
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight)),
                          ),
                  ),
                ),
                if (widget.badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum GlassIntensity {
  light,
  medium,
  heavy,
  ultraLight,
}

extension GlassIntensityExtension on GlassIntensity {
  GlassSettings get settings {
    switch (this) {
      case GlassIntensity.ultraLight:
        return const GlassSettings(
          blur: 5,
          opacity: 0.05,
          borderOpacity: 0.1,
          elevation: 0,
        );
      case GlassIntensity.light:
        return const GlassSettings(
          blur: 8,
          opacity: 0.08,
          borderOpacity: 0.15,
          elevation: 2,
        );
      case GlassIntensity.medium:
        return const GlassSettings(
          blur: 12,
          opacity: 0.12,
          borderOpacity: 0.2,
          elevation: 4,
        );
      case GlassIntensity.heavy:
        return const GlassSettings(
          blur: 20,
          opacity: 0.18,
          borderOpacity: 0.3,
          elevation: 8,
        );
    }
  }
}

class GlassSettings {
  const GlassSettings({
    required this.blur,
    required this.opacity,
    required this.borderOpacity,
    required this.elevation,
  });

  final double blur;
  final double opacity;
  final double borderOpacity;
  final double elevation;
}
