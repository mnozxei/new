abstract final class AppConstants {
  static const String appName = 'TAMAD HUB';
  static const String appNameArabic = 'تماد هب';
  static const String appVersion = '1.0.0';
  static const String appWebUrl = 'https://tamadhub.com';
  static const String appBundleId = 'com.tamadhub.app';
  static const String appPlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.tamadhub.app';
  static const String appAppStoreUrl = 'https://apps.apple.com/app/tamad-hub/id000000000';

  static const String supabaseUrl = 'https://xvbabumutaihzqwnlnzt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2YmFidW11dGFpaHpxd25sbnp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwMTY5NzMsImV4cCI6MjA4MTU5Mjk3M30.cd5dI8G5_hmeWtgp_KQbAampxGHzmwfTTVfnnx2-jR8';
  static const String supabaseStorageUrl = '$supabaseUrl/storage/v1/object/public';

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 24.0;

  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
  static const double spacingHuge = 48.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double largeDesktopBreakpoint = 1800.0;

  static const double glassBlurSigma = 10.0;
  static const double glassOpacity = 0.1;
  static const double glassBorderOpacity = 0.2;

  static const int maxFileUploadSizeMB = 10;
  static const int maxImageUploadSizeMB = 5;

  static const int paginationLimit = 20;
  static const int searchDebounceMilliseconds = 500;

  static const String dateFormatShort = 'dd/MM/yyyy';
  static const String dateFormatLong = 'EEEE, d MMMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}
