import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class GlassBottomNavigation extends StatelessWidget {
  const GlassBottomNavigation({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.blurSigma,
    this.opacity,
    this.height,
    this.showLabels = true,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.backgroundColor,
  });

  final List<GlassBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double? blurSigma;
  final double? opacity;
  final double? height;
  final bool showLabels;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? 20.0;
    final double effectiveOpacity = opacity ?? 0.7;
    final double effectiveHeight = height ?? 80;

    final Color effectiveSelectedColor = selectedItemColor ??
        (isDark ? AppColors.primaryLight : AppColors.primary);
    final Color effectiveUnselectedColor = unselectedItemColor ??
        (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            height: effectiveHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ]
                    : [
                        Colors.white.withValues(alpha: effectiveOpacity),
                        Colors.white.withValues(alpha: effectiveOpacity * 0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final bool isSelected = index == currentIndex;

                return Expanded(
                  child: GlassBottomNavigationItemWidget(
                    item: item,
                    isSelected: isSelected,
                    showLabel: showLabels,
                    selectedColor: effectiveSelectedColor,
                    unselectedColor: effectiveUnselectedColor,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBottomNavigationItem {
  const GlassBottomNavigationItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? badge;
}

class GlassBottomNavigationItemWidget extends StatefulWidget {
  const GlassBottomNavigationItemWidget({
    required this.item,
    required this.isSelected,
    required this.showLabel,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
    super.key,
  });

  final GlassBottomNavigationItem item;
  final bool isSelected;
  final bool showLabel;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  State<GlassBottomNavigationItemWidget> createState() =>
      _GlassBottomNavigationItemWidgetState();
}

class _GlassBottomNavigationItemWidgetState
    extends State<GlassBottomNavigationItemWidget>
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
    final color =
        widget.isSelected ? widget.selectedColor : widget.unselectedColor;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: AppConstants.animationDuration,
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.isSelected ? 20 : 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: widget.isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.selectedColor.withValues(alpha: 0.2),
                                  widget.selectedColor.withValues(alpha: 0.1),
                                ],
                              )
                            : null,
                        color: widget.isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: widget.selectedColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.isSelected
                            ? (widget.item.selectedIcon ?? widget.item.icon)
                            : widget.item.icon,
                        color: color,
                        size: widget.isSelected ? 26 : 24,
                      ),
                    ),
                    if (widget.item.badge != null)
                      Positioned(
                        top: -2,
                        right: widget.isSelected ? 4 : -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.error, Color(0xFFFF6B6B)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.item.badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.showLabel) ...[
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: AppConstants.animationDurationFast,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: color,
                      fontWeight:
                          widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: widget.isSelected ? 11 : 10,
                    ),
                    child: Text(
                      widget.item.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class GlassNavigationRail extends StatelessWidget {
  const GlassNavigationRail({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.leading,
    this.trailing,
    this.blurSigma,
    this.opacity,
    this.width,
    this.extended = false,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.backgroundColor,
    this.minWidth,
    this.minExtendedWidth,
    this.groupAlignment,
    this.labelType,
  });

  final List<GlassBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? leading;
  final Widget? trailing;
  final double? blurSigma;
  final double? opacity;
  final double? width;
  final bool extended;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;
  final double? minWidth;
  final double? minExtendedWidth;
  final double? groupAlignment;
  final NavigationRailLabelType? labelType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? AppConstants.glassBlurSigma;
    final double effectiveOpacity = opacity ?? 0.9;

    final Color effectiveSelectedColor = selectedItemColor ??
        (isDark ? AppColors.primaryLight : AppColors.primary);
    final Color effectiveUnselectedColor = unselectedItemColor ??
        (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: Container(
          width: width ?? (extended ? (minExtendedWidth ?? 256) : (minWidth ?? 72)),
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark
                    ? AppColors.surfaceDark.withValues(alpha: effectiveOpacity)
                    : AppColors.surfaceLight
                        .withValues(alpha: effectiveOpacity)),
            border: Border(
              left: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                width: 0.5,
              ),
            ),
          ),
          child: NavigationRail(
            destinations: items
                .map(
                  (item) => NavigationRailDestination(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          item.icon,
                          color: effectiveUnselectedColor,
                        ),
                        if (item.badge != null)
                          Positioned(
                            top: -4,
                            right: -8,
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
                                item.badge!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    selectedIcon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          item.selectedIcon ?? item.icon,
                          color: effectiveSelectedColor,
                        ),
                        if (item.badge != null)
                          Positioned(
                            top: -4,
                            right: -8,
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
                                item.badge!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: Text(item.label),
                  ),
                )
                .toList(),
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            leading: leading,
            trailing: trailing != null
                ? Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppConstants.spacingLarge),
                        child: trailing,
                      ),
                    ),
                  )
                : null,
            backgroundColor: Colors.transparent,
            indicatorColor: effectiveSelectedColor.withValues(alpha: 0.1),
            extended: extended,
            minWidth: minWidth ?? 72,
            minExtendedWidth: minExtendedWidth ?? 256,
            groupAlignment: groupAlignment ?? -1,
            labelType: labelType ??
                (extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all),
            useIndicator: true,
          ),
        ),
      ),
    );
  }
}
