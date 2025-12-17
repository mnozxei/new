import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.blurSigma,
    this.opacity,
    this.elevation,
    this.bottom,
    this.flexibleSpace,
    this.toolbarHeight,
    this.leadingWidth,
    this.titleSpacing,
    this.systemOverlayStyle,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double? blurSigma;
  final double? opacity;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final double? toolbarHeight;
  final double? leadingWidth;
  final double? titleSpacing;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight((toolbarHeight ?? kToolbarHeight) + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? AppConstants.glassBlurSigma;
    final double effectiveOpacity = opacity ?? 0.7;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      AppColors.backgroundDark.withValues(alpha: effectiveOpacity),
                      AppColors.backgroundDark
                          .withValues(alpha: effectiveOpacity * 0.8),
                    ]
                  : [
                      AppColors.backgroundLight
                          .withValues(alpha: effectiveOpacity),
                      AppColors.backgroundLight
                          .withValues(alpha: effectiveOpacity * 0.8),
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                width: 0.5,
              ),
            ),
          ),
          child: AppBar(
            title: titleWidget ??
                (title != null
                    ? Text(
                        title!,
                        style: theme.appBarTheme.titleTextStyle,
                      )
                    : null),
            leading: leading,
            actions: actions,
            centerTitle: centerTitle,
            automaticallyImplyLeading: automaticallyImplyLeading,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: elevation ?? 0,
            scrolledUnderElevation: 0,
            bottom: bottom,
            flexibleSpace: flexibleSpace,
            toolbarHeight: toolbarHeight,
            leadingWidth: leadingWidth,
            titleSpacing: titleSpacing,
            systemOverlayStyle: systemOverlayStyle ??
                (isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark),
          ),
        ),
      ),
    );
  }
}

class GlassSliverAppBar extends StatelessWidget {
  const GlassSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.blurSigma,
    this.opacity,
    this.expandedHeight,
    this.collapsedHeight,
    this.flexibleSpace,
    this.bottom,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.stretch = false,
    this.stretchTriggerOffset = 100.0,
    this.onStretchTrigger,
    this.toolbarHeight,
    this.leadingWidth,
    this.forceElevated = false,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double? blurSigma;
  final double? opacity;
  final double? expandedHeight;
  final double? collapsedHeight;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool stretch;
  final double stretchTriggerOffset;
  final Future<void> Function()? onStretchTrigger;
  final double? toolbarHeight;
  final double? leadingWidth;
  final bool forceElevated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? AppConstants.glassBlurSigma;
    final double effectiveOpacity = opacity ?? 0.8;

    return SliverAppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: theme.appBarTheme.titleTextStyle,
                )
              : null),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      stretch: stretch,
      stretchTriggerOffset: stretchTriggerOffset,
      onStretchTrigger: onStretchTrigger,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
      leadingWidth: leadingWidth,
      forceElevated: forceElevated,
      bottom: bottom,
      flexibleSpace: flexibleSpace ??
          FlexibleSpaceBar(
            background: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              AppColors.backgroundDark
                                  .withValues(alpha: effectiveOpacity),
                              AppColors.backgroundDark
                                  .withValues(alpha: effectiveOpacity * 0.6),
                            ]
                          : [
                              AppColors.backgroundLight
                                  .withValues(alpha: effectiveOpacity),
                              AppColors.backgroundLight
                                  .withValues(alpha: effectiveOpacity * 0.6),
                            ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class GlassTabBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassTabBar({
    required this.tabs,
    super.key,
    this.controller,
    this.isScrollable = false,
    this.padding,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.indicatorPadding = EdgeInsets.zero,
    this.indicator,
    this.indicatorSize,
    this.labelColor,
    this.labelStyle,
    this.labelPadding,
    this.unselectedLabelColor,
    this.unselectedLabelStyle,
    this.onTap,
    this.blurSigma,
    this.opacity,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final Color? indicatorColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry indicatorPadding;
  final Decoration? indicator;
  final TabBarIndicatorSize? indicatorSize;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? labelPadding;
  final Color? unselectedLabelColor;
  final TextStyle? unselectedLabelStyle;
  final void Function(int)? onTap;
  final double? blurSigma;
  final double? opacity;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? 8;
    final double effectiveOpacity = opacity ?? 0.5;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: effectiveOpacity)
                : AppColors.surfaceLight.withValues(alpha: effectiveOpacity),
          ),
          child: TabBar(
            tabs: tabs,
            controller: controller,
            isScrollable: isScrollable,
            padding: padding,
            indicatorColor: indicatorColor ?? AppColors.primary,
            indicatorWeight: indicatorWeight,
            indicatorPadding: indicatorPadding,
            indicator: indicator,
            indicatorSize: indicatorSize ?? TabBarIndicatorSize.label,
            labelColor:
                labelColor ?? (isDark ? AppColors.primaryLight : AppColors.primary),
            labelStyle: labelStyle ?? theme.textTheme.labelLarge,
            labelPadding: labelPadding,
            unselectedLabelColor: unselectedLabelColor ??
                (isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight),
            unselectedLabelStyle:
                unselectedLabelStyle ?? theme.textTheme.labelLarge,
            onTap: onTap,
            dividerColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
