import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryLighter,
        onPrimaryContainer: AppColors.primaryDarkest,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        onTertiary: AppColors.white,
        tertiaryContainer: AppColors.accentLight,
        onTertiaryContainer: AppColors.accentDark,
        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: AppColors.errorBackground,
        onErrorContainer: AppColors.errorDark,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.cardLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: AppColors.dividerLight,
        outlineVariant: AppColors.primaryLightest,
        shadow: AppColors.shadowLight,
        scrim: AppColors.overlayLight,
        inverseSurface: AppColors.surfaceDark,
        onInverseSurface: AppColors.textPrimaryDark,
        inversePrimary: AppColors.primaryLight,
      ),
      textTheme: _buildTextTheme(isLight: true),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryLight,
          size: AppConstants.iconSizeMedium,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryLight,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLightest,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppConstants.iconSizeMedium,
            );
          }
          return const IconThemeData(
            color: AppColors.textTertiaryLight,
            size: AppConstants.iconSizeMedium,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryLightest,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: AppConstants.iconSizeMedium,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textTertiaryLight,
          size: AppConstants.iconSizeMedium,
        ),
        selectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiaryLight,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primaryLighter,
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.primaryLighter,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.primaryLighter,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primaryLighter,
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          disabledForegroundColor: AppColors.textDisabledLight,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryExtraLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight,
        ),
        hintStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiaryLight,
        ),
        errorStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.textSecondaryLight,
        suffixIconColor: AppColors.textSecondaryLight,
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        backgroundColor: AppColors.primaryExtraLight,
        disabledColor: AppColors.primaryLightest,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingSmall,
          vertical: AppConstants.spacingExtraSmall,
        ),
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        secondaryLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
      ),
      tabBarTheme: TabBarTheme(
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiaryLight,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      dialogTheme: DialogTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.borderRadiusExtraLarge),
            topRight: Radius.circular(AppConstants.borderRadiusExtraLarge),
          ),
        ),
        dragHandleColor: AppColors.dividerLight,
        dragHandleSize: const Size(40, 4),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.primaryDarkest,
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppConstants.spacingMedium),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLightest,
        circularTrackColor: AppColors.primaryLightest,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryLightest,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLighter;
          }
          return AppColors.primaryLightest;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(
          color: AppColors.textTertiaryLight,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiaryLight;
        }),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.primaryDarkest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 8,
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryLight,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        subtitleTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight,
        ),
        iconColor: AppColors.textSecondaryLight,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: AppColors.textSecondaryLight,
        collapsedIconColor: AppColors.textSecondaryLight,
        textColor: AppColors.primary,
        collapsedTextColor: AppColors.textPrimaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(AppColors.primaryExtraLight),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimaryLight,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiaryLight,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.textPrimaryLight;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayBorder: const BorderSide(color: AppColors.primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surfaceLight,
        hourMinuteColor: AppColors.primaryExtraLight,
        hourMinuteTextColor: AppColors.textPrimaryLight,
        dialBackgroundColor: AppColors.primaryExtraLight,
        dialHandColor: AppColors.primary,
        dialTextColor: AppColors.textPrimaryLight,
        entryModeIconColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
        textStyle: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }
            return AppColors.primary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.primary),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.primaryDarkest,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryLightest,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.secondaryDark,
        secondaryContainer: AppColors.secondary,
        onSecondaryContainer: AppColors.white,
        tertiary: AppColors.accentLight,
        onTertiary: AppColors.accentDark,
        tertiaryContainer: AppColors.accent,
        onTertiaryContainer: AppColors.white,
        error: AppColors.errorLight,
        onError: AppColors.errorDark,
        errorContainer: AppColors.error,
        onErrorContainer: AppColors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.cardDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.dividerDark,
        outlineVariant: AppColors.primaryDark,
        shadow: AppColors.shadowDark,
        scrim: AppColors.overlayDark,
        inverseSurface: AppColors.surfaceLight,
        onInverseSurface: AppColors.textPrimaryLight,
        inversePrimary: AppColors.primaryDark,
      ),
      textTheme: _buildTextTheme(isLight: false),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: AppConstants.iconSizeMedium,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryDark,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            );
          }
          return GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primaryLight,
              size: AppConstants.iconSizeMedium,
            );
          }
          return const IconThemeData(
            color: AppColors.textTertiaryDark,
            size: AppConstants.iconSizeMedium,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryDark,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primaryLight,
          size: AppConstants.iconSizeMedium,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textTertiaryDark,
          size: AppConstants.iconSizeMedium,
        ),
        selectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryLight,
        ),
        unselectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiaryDark,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDarkest,
          disabledBackgroundColor: AppColors.primaryDark,
          disabledForegroundColor: AppColors.primaryDarkest.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDarkest,
          disabledBackgroundColor: AppColors.primaryDark,
          disabledForegroundColor: AppColors.primaryDarkest.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          disabledForegroundColor: AppColors.textDisabledDark,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primaryDarkest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryDark.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(
            color: AppColors.errorLight,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(
            color: AppColors.errorLight,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryDark,
        ),
        hintStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiaryDark,
        ),
        errorStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.errorLight,
        ),
        prefixIconColor: AppColors.textSecondaryDark,
        suffixIconColor: AppColors.textSecondaryDark,
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        backgroundColor: AppColors.primaryDark.withValues(alpha: 0.3),
        disabledColor: AppColors.primaryDarkest,
        selectedColor: AppColors.primaryLight,
        secondarySelectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingSmall,
          vertical: AppConstants.spacingExtraSmall,
        ),
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        secondaryLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDarkest,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
      ),
      tabBarTheme: TabBarTheme(
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.textTertiaryDark,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      dialogTheme: DialogTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryDark,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.borderRadiusExtraLarge),
            topRight: Radius.circular(AppConstants.borderRadiusExtraLarge),
          ),
        ),
        dragHandleColor: AppColors.dividerDark,
        dragHandleSize: const Size(40, 4),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.cardDark,
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppConstants.spacingMedium),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.primaryDark,
        circularTrackColor: AppColors.primaryDark,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.primaryDark,
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primaryLight,
        valueIndicatorTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDarkest,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.textTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.primaryDark;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.primaryDarkest),
        side: const BorderSide(
          color: AppColors.textTertiaryDark,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.textTertiaryDark;
        }),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryDark,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 8,
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryDark,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        subtitleTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryDark,
        ),
        iconColor: AppColors.textSecondaryDark,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: AppColors.textSecondaryDark,
        collapsedIconColor: AppColors.textSecondaryDark,
        textColor: AppColors.primaryLight,
        collapsedTextColor: AppColors.textPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(
          AppColors.primaryDark.withValues(alpha: 0.3),
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimaryDark,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiaryDark,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primaryDark,
        headerForegroundColor: AppColors.textPrimaryDark,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkest;
          }
          return AppColors.textPrimaryDark;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.primaryLight),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayBorder: const BorderSide(color: AppColors.primaryLight, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surfaceDark,
        hourMinuteColor: AppColors.primaryDark,
        hourMinuteTextColor: AppColors.textPrimaryDark,
        dialBackgroundColor: AppColors.primaryDark,
        dialHandColor: AppColors.primaryLight,
        dialTextColor: AppColors.textPrimaryDark,
        entryModeIconColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.errorLight,
        textColor: AppColors.white,
        textStyle: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryDarkest;
            }
            return AppColors.primaryLight;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.primaryLight),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color primaryColor =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final Color secondaryColor =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.4,
      ),
    );
  }
}
