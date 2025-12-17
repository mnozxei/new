import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.tabletBreakpoint &&
        width < AppConstants.largeDesktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.largeDesktopBreakpoint;

  static bool isDesktopOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

  static bool isTabletOrSmaller(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint;

  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.desktopBreakpoint;

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= AppConstants.largeDesktopBreakpoint) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
    if (width >= AppConstants.tabletBreakpoint) {
      return desktop ?? tablet ?? mobile;
    }
    if (width >= AppConstants.mobileBreakpoint) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.largeDesktopBreakpoint) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= AppConstants.mobileBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(
    BuildContext context,
    ScreenSize screenSize,
    BoxConstraints constraints,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ScreenSize.fromWidth(constraints.maxWidth);
        return builder(context, screenSize, constraints);
      },
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  const ResponsiveGridView({
    required this.children,
    super.key,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    this.mainAxisSpacing = AppConstants.spacingMedium,
    this.crossAxisSpacing = AppConstants.spacingMedium,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeDesktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = ResponsiveLayout.value(
          context: context,
          mobile: mobileColumns,
          tablet: tabletColumns,
          desktop: desktopColumns,
          largeDesktop: largeDesktopColumns,
        );

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
            mainAxisExtent: mainAxisExtent,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class ResponsiveSliverGridView extends StatelessWidget {
  const ResponsiveSliverGridView({
    required this.children,
    super.key,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    this.mainAxisSpacing = AppConstants.spacingMedium,
    this.crossAxisSpacing = AppConstants.spacingMedium,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeDesktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    final int columns = ResponsiveLayout.value(
      context: context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      largeDesktop: largeDesktopColumns,
    );

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => children[index],
        childCount: children.length,
      ),
    );
  }
}

class ResponsiveConstrainedBox extends StatelessWidget {
  const ResponsiveConstrainedBox({
    required this.child,
    super.key,
    this.maxWidth,
    this.alignment = Alignment.center,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final Alignment alignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppConstants.desktopBreakpoint,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    required this.child,
    super.key,
    this.mobilePadding = const EdgeInsets.all(AppConstants.spacingMedium),
    this.tabletPadding,
    this.desktopPadding,
    this.largeDesktopPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;
  final EdgeInsetsGeometry? largeDesktopPadding;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveLayout.value(
      context: context,
      mobile: mobilePadding,
      tablet: tabletPadding,
      desktop: desktopPadding,
      largeDesktop: largeDesktopPadding,
    );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    required this.children,
    super.key,
    this.breakToColumnAt = AppConstants.mobileBreakpoint,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = AppConstants.spacingMedium,
  });

  final List<Widget> children;
  final double breakToColumnAt;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakToColumnAt) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: children
                .expand(
                  (child) => [
                    child,
                    if (child != children.last) SizedBox(height: spacing),
                  ],
                )
                .toList(),
          );
        }

        return Row(
          mainAxisAlignment: rowMainAxisAlignment,
          crossAxisAlignment: rowCrossAxisAlignment,
          children: children
              .expand(
                (child) => [
                  Flexible(child: child),
                  if (child != children.last) SizedBox(width: spacing),
                ],
              )
              .toList(),
        );
      },
    );
  }
}

enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop;

  static ScreenSize fromWidth(double width) {
    if (width >= AppConstants.largeDesktopBreakpoint) {
      return ScreenSize.largeDesktop;
    }
    if (width >= AppConstants.tabletBreakpoint) {
      return ScreenSize.desktop;
    }
    if (width >= AppConstants.mobileBreakpoint) {
      return ScreenSize.tablet;
    }
    return ScreenSize.mobile;
  }

  bool get isMobile => this == ScreenSize.mobile;
  bool get isTablet => this == ScreenSize.tablet;
  bool get isDesktop => this == ScreenSize.desktop;
  bool get isLargeDesktop => this == ScreenSize.largeDesktop;
  bool get isDesktopOrLarger =>
      this == ScreenSize.desktop || this == ScreenSize.largeDesktop;
  bool get isTabletOrSmaller =>
      this == ScreenSize.mobile || this == ScreenSize.tablet;
}
