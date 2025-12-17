import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF786E8B);

  static const Color primaryLight = Color(0xFF9B92AC);
  static const Color primaryLighter = Color(0xFFBEB6CB);
  static const Color primaryLightest = Color(0xFFE1DBEA);
  static const Color primaryExtraLight = Color(0xFFF0EDF5);

  static const Color primaryDark = Color(0xFF5E566E);
  static const Color primaryDarker = Color(0xFF453F51);
  static const Color primaryDarkest = Color(0xFF2C2834);

  static const Color secondary = Color(0xFF8B7886);
  static const Color secondaryLight = Color(0xFFAC92A6);
  static const Color secondaryDark = Color(0xFF6E5668);

  static const Color accent = Color(0xFF6E8B78);
  static const Color accentLight = Color(0xFF92AC9B);
  static const Color accentDark = Color(0xFF566E5E);

  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successBackground = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningBackground = Color(0xFFFFF3E0);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color errorBackground = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoBackground = Color(0xFFE3F2FD);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  static const Color backgroundLight = Color(0xFFFAF9FC);
  static const Color backgroundDark = Color(0xFF1A1720);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF252131);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2839);

  static const Color textPrimaryLight = Color(0xFF1A1720);
  static const Color textSecondaryLight = Color(0xFF5E566E);
  static const Color textTertiaryLight = Color(0xFF9B92AC);
  static const Color textDisabledLight = Color(0xFFBEB6CB);

  static const Color textPrimaryDark = Color(0xFFF0EDF5);
  static const Color textSecondaryDark = Color(0xFFBEB6CB);
  static const Color textTertiaryDark = Color(0xFF9B92AC);
  static const Color textDisabledDark = Color(0xFF5E566E);

  static const Color dividerLight = Color(0xFFE1DBEA);
  static const Color dividerDark = Color(0xFF453F51);

  static const Color shadowLight = Color(0x1A786E8B);
  static const Color shadowDark = Color(0x40000000);

  static const Color shimmerBaseLight = Color(0xFFE1DBEA);
  static const Color shimmerHighlightLight = Color(0xFFF0EDF5);
  static const Color shimmerBaseDark = Color(0xFF453F51);
  static const Color shimmerHighlightDark = Color(0xFF5E566E);

  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x33786E8B);

  static const Color overlayLight = Color(0x80FFFFFF);
  static const Color overlayDark = Color(0x801A1720);

  static const Color verifiedBadge = Color(0xFF4FC3F7);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9B92AC),
      Color(0xFF786E8B),
      Color(0xFF5E566E),
    ],
  );

  static const LinearGradient primaryGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF786E8B),
      Color(0xFF9B92AC),
    ],
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF9B92AC),
      Color(0xFF786E8B),
    ],
  );

  static const LinearGradient glassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  static const LinearGradient glassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x20786E8B),
      Color(0x08786E8B),
    ],
  );

  static const LinearGradient surfaceGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAF9FC),
      Color(0xFFF0EDF5),
    ],
  );

  static const LinearGradient surfaceGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF252131),
      Color(0xFF1A1720),
    ],
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x40786E8B),
      Color(0x00786E8B),
    ],
  );

  static const List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Color(0x0D786E8B),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05786E8B),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> elevatedShadowLight = [
    BoxShadow(
      color: Color(0x1A786E8B),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D786E8B),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> elevatedShadowDark = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x1A786E8B),
      blurRadius: 20,
      spreadRadius: -5,
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x14786E8B),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A786E8B),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x1A786E8B),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0D786E8B),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];
}
