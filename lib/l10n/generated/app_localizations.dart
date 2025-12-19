import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'تماد هب'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'منصة مهنية متكاملة'**
  String get appTagline;

  /// No description provided for @common_ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get common_edit;

  /// No description provided for @common_close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get common_close;

  /// No description provided for @common_search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get common_search;

  /// No description provided for @common_filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get common_filter;

  /// No description provided for @common_apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get common_apply;

  /// No description provided for @common_clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get common_clear;

  /// No description provided for @common_clearAll.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get common_clearAll;

  /// No description provided for @common_loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In ar, this message translates to:
  /// **'نجاح'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get common_retry;

  /// No description provided for @common_back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get common_next;

  /// No description provided for @common_previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get common_previous;

  /// No description provided for @common_submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get common_submit;

  /// No description provided for @common_share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get common_share;

  /// No description provided for @common_follow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get common_follow;

  /// No description provided for @common_following.
  ///
  /// In ar, this message translates to:
  /// **'متابَع'**
  String get common_following;

  /// No description provided for @common_unfollow.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المتابعة'**
  String get common_unfollow;

  /// No description provided for @common_like.
  ///
  /// In ar, this message translates to:
  /// **'إعجاب'**
  String get common_like;

  /// No description provided for @common_comment.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get common_comment;

  /// No description provided for @common_more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get common_more;

  /// No description provided for @common_seeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get common_seeAll;

  /// No description provided for @common_noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get common_noResults;

  /// No description provided for @common_underDevelopment.
  ///
  /// In ar, this message translates to:
  /// **'قيد التطوير'**
  String get common_underDevelopment;

  /// No description provided for @common_comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get common_comingSoon;

  /// No description provided for @nav_home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get nav_home;

  /// No description provided for @nav_jobs.
  ///
  /// In ar, this message translates to:
  /// **'وظائف'**
  String get nav_jobs;

  /// No description provided for @nav_courses.
  ///
  /// In ar, this message translates to:
  /// **'دورات'**
  String get nav_courses;

  /// No description provided for @nav_chat.
  ///
  /// In ar, this message translates to:
  /// **'محادثات'**
  String get nav_chat;

  /// No description provided for @nav_profile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get nav_profile;

  /// No description provided for @auth_welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get auth_welcomeBack;

  /// No description provided for @auth_loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل دخولك للمتابعة إلى TAMAD HUB'**
  String get auth_loginSubtitle;

  /// No description provided for @auth_createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get auth_createAccount;

  /// No description provided for @auth_createAccountSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى TAMAD HUB اليوم'**
  String get auth_createAccountSubtitle;

  /// No description provided for @auth_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get auth_email;

  /// No description provided for @auth_emailHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني'**
  String get auth_emailHint;

  /// No description provided for @auth_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get auth_password;

  /// No description provided for @auth_passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get auth_passwordHint;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get auth_confirmPassword;

  /// No description provided for @auth_confirmPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال كلمة المرور'**
  String get auth_confirmPasswordHint;

  /// No description provided for @auth_fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get auth_fullName;

  /// No description provided for @auth_fullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الكامل'**
  String get auth_fullNameHint;

  /// No description provided for @auth_accountType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحساب'**
  String get auth_accountType;

  /// No description provided for @auth_user.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get auth_user;

  /// No description provided for @auth_instructor.
  ///
  /// In ar, this message translates to:
  /// **'مدرب'**
  String get auth_instructor;

  /// No description provided for @auth_login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get auth_register;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get auth_forgotPassword;

  /// No description provided for @auth_noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get auth_noAccount;

  /// No description provided for @auth_haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get auth_haveAccount;

  /// No description provided for @auth_logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get auth_logout;

  /// No description provided for @auth_logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get auth_logoutConfirm;

  /// No description provided for @auth_emailRequired.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال البريد الإلكتروني'**
  String get auth_emailRequired;

  /// No description provided for @auth_emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال بريد إلكتروني صحيح'**
  String get auth_emailInvalid;

  /// No description provided for @auth_passwordRequired.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال كلمة المرور'**
  String get auth_passwordRequired;

  /// No description provided for @auth_passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get auth_passwordTooShort;

  /// No description provided for @auth_confirmPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء تأكيد كلمة المرور'**
  String get auth_confirmPasswordRequired;

  /// No description provided for @auth_passwordsNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get auth_passwordsNotMatch;

  /// No description provided for @auth_nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال اسمك الكامل'**
  String get auth_nameRequired;

  /// No description provided for @auth_nameTooShort.
  ///
  /// In ar, this message translates to:
  /// **'الاسم يجب أن يكون حرفين على الأقل'**
  String get auth_nameTooShort;

  /// No description provided for @auth_resetPasswordSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'**
  String get auth_resetPasswordSent;

  /// No description provided for @auth_enterEmailForReset.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور'**
  String get auth_enterEmailForReset;

  /// No description provided for @auth_sendResetLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط إعادة التعيين'**
  String get auth_sendResetLink;

  /// No description provided for @profile_title.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile_title;

  /// No description provided for @profile_editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get profile_editProfile;

  /// No description provided for @profile_followers.
  ///
  /// In ar, this message translates to:
  /// **'المتابعون'**
  String get profile_followers;

  /// No description provided for @profile_following.
  ///
  /// In ar, this message translates to:
  /// **'المتابَعون'**
  String get profile_following;

  /// No description provided for @profile_posts.
  ///
  /// In ar, this message translates to:
  /// **'المنشورات'**
  String get profile_posts;

  /// No description provided for @profile_aboutMe.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عني'**
  String get profile_aboutMe;

  /// No description provided for @profile_noAbout.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم إضافة نبذة بعد.'**
  String get profile_noAbout;

  /// No description provided for @profile_recentActivity.
  ///
  /// In ar, this message translates to:
  /// **'النشاط الأخير'**
  String get profile_recentActivity;

  /// No description provided for @profile_noActivity.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد نشاط حديث'**
  String get profile_noActivity;

  /// No description provided for @profile_joinedOn.
  ///
  /// In ar, this message translates to:
  /// **'انضم في {date}'**
  String profile_joinedOn(String date);

  /// No description provided for @profile_myApplications.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get profile_myApplications;

  /// No description provided for @profile_myCompanies.
  ///
  /// In ar, this message translates to:
  /// **'شركاتي'**
  String get profile_myCompanies;

  /// No description provided for @profile_myCourses.
  ///
  /// In ar, this message translates to:
  /// **'دوراتي'**
  String get profile_myCourses;

  /// No description provided for @profile_myPosts.
  ///
  /// In ar, this message translates to:
  /// **'منشوراتي'**
  String get profile_myPosts;

  /// No description provided for @profile_savedItems.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get profile_savedItems;

  /// No description provided for @profile_quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get profile_quickActions;

  /// No description provided for @profile_profileLinkCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ رابط الملف الشخصي'**
  String get profile_profileLinkCopied;

  /// No description provided for @settings_title.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings_title;

  /// No description provided for @settings_account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get settings_account;

  /// No description provided for @settings_accountInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الحساب'**
  String get settings_accountInfo;

  /// No description provided for @settings_accountInfoSub.
  ///
  /// In ar, this message translates to:
  /// **'تحديث بياناتك الشخصية'**
  String get settings_accountInfoSub;

  /// No description provided for @settings_security.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور والأمان'**
  String get settings_security;

  /// No description provided for @settings_securitySub.
  ///
  /// In ar, this message translates to:
  /// **'إدارة كلمة المرور والمصادقة الثنائية'**
  String get settings_securitySub;

  /// No description provided for @settings_privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get settings_privacy;

  /// No description provided for @settings_privacySub.
  ///
  /// In ar, this message translates to:
  /// **'التحكم في من يمكنه رؤية ملفك الشخصي'**
  String get settings_privacySub;

  /// No description provided for @settings_preferences.
  ///
  /// In ar, this message translates to:
  /// **'التفضيلات'**
  String get settings_preferences;

  /// No description provided for @settings_notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get settings_notifications;

  /// No description provided for @settings_notificationsEnabled.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات مفعلة'**
  String get settings_notificationsEnabled;

  /// No description provided for @settings_notificationsDisabled.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات معطلة'**
  String get settings_notificationsDisabled;

  /// No description provided for @settings_notificationsToggled.
  ///
  /// In ar, this message translates to:
  /// **'تم {status} الإشعارات'**
  String settings_notificationsToggled(String status);

  /// No description provided for @settings_theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settings_theme;

  /// No description provided for @settings_themeLight.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get settings_themeDark;

  /// No description provided for @settings_themeSwitched.
  ///
  /// In ar, this message translates to:
  /// **'تم التبديل إلى {mode}'**
  String settings_themeSwitched(String mode);

  /// No description provided for @settings_language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settings_language;

  /// No description provided for @settings_languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settings_languageArabic;

  /// No description provided for @settings_languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settings_languageEnglish;

  /// No description provided for @settings_languageChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة إلى {language}'**
  String settings_languageChanged(String language);

  /// No description provided for @settings_selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get settings_selectLanguage;

  /// No description provided for @settings_support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get settings_support;

  /// No description provided for @settings_helpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get settings_helpCenter;

  /// No description provided for @settings_helpCenterSub.
  ///
  /// In ar, this message translates to:
  /// **'احصل على المساعدة والدعم'**
  String get settings_helpCenterSub;

  /// No description provided for @settings_termsOfService.
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get settings_termsOfService;

  /// No description provided for @settings_termsOfServiceSub.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ الشروط والأحكام'**
  String get settings_termsOfServiceSub;

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_privacyPolicySub.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ سياسة الخصوصية'**
  String get settings_privacyPolicySub;

  /// No description provided for @settings_aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get settings_aboutApp;

  /// No description provided for @settings_version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String settings_version(String version);

  /// No description provided for @settings_session.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة'**
  String get settings_session;

  /// No description provided for @settings_logoutSub.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من حسابك'**
  String get settings_logoutSub;

  /// No description provided for @settings_dangerZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الخطر'**
  String get settings_dangerZone;

  /// No description provided for @settings_deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get settings_deleteAccount;

  /// No description provided for @settings_deleteAccountSub.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابك نهائياً'**
  String get settings_deleteAccountSub;

  /// No description provided for @settings_deleteAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get settings_deleteAccountTitle;

  /// No description provided for @settings_deleteAccountConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف حسابك نهائياً؟\n\nهذا الإجراء لا يمكن التراجع عنه وسيتم حذف جميع بياناتك.'**
  String get settings_deleteAccountConfirm;

  /// No description provided for @settings_deleteAccountRequested.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب حذف الحساب. سيتم مراجعته خلال 24 ساعة.'**
  String get settings_deleteAccountRequested;

  /// No description provided for @settings_passwordResetSent.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني'**
  String get settings_passwordResetSent;

  /// No description provided for @settings_privacyUnderDev.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخصوصية قيد التطوير'**
  String get settings_privacyUnderDev;

  /// No description provided for @settings_helpCenterUnderDev.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة قيد التطوير'**
  String get settings_helpCenterUnderDev;

  /// No description provided for @settings_couldNotOpenLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الرابط'**
  String get settings_couldNotOpenLink;

  /// No description provided for @settings_allRightsReserved.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحقوق محفوظة.'**
  String get settings_allRightsReserved;

  /// No description provided for @jobs_title.
  ///
  /// In ar, this message translates to:
  /// **'الوظائف'**
  String get jobs_title;

  /// No description provided for @jobs_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن وظائف...'**
  String get jobs_searchHint;

  /// No description provided for @jobs_postJob.
  ///
  /// In ar, this message translates to:
  /// **'نشر وظيفة'**
  String get jobs_postJob;

  /// No description provided for @jobs_filter.
  ///
  /// In ar, this message translates to:
  /// **'التصفية'**
  String get jobs_filter;

  /// No description provided for @jobs_sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get jobs_sort;

  /// No description provided for @jobs_sortNewest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get jobs_sortNewest;

  /// No description provided for @jobs_sortRelevant.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر صلة'**
  String get jobs_sortRelevant;

  /// No description provided for @jobs_sortHighestSalary.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى راتباً'**
  String get jobs_sortHighestSalary;

  /// No description provided for @jobs_sortNearest.
  ///
  /// In ar, this message translates to:
  /// **'الأقرب'**
  String get jobs_sortNearest;

  /// No description provided for @jobs_jobType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العمل'**
  String get jobs_jobType;

  /// No description provided for @jobs_fullTime.
  ///
  /// In ar, this message translates to:
  /// **'دوام كامل'**
  String get jobs_fullTime;

  /// No description provided for @jobs_partTime.
  ///
  /// In ar, this message translates to:
  /// **'دوام جزئي'**
  String get jobs_partTime;

  /// No description provided for @jobs_contract.
  ///
  /// In ar, this message translates to:
  /// **'عقد'**
  String get jobs_contract;

  /// No description provided for @jobs_remote.
  ///
  /// In ar, this message translates to:
  /// **'عن بعد'**
  String get jobs_remote;

  /// No description provided for @jobs_internship.
  ///
  /// In ar, this message translates to:
  /// **'تدريب'**
  String get jobs_internship;

  /// No description provided for @jobs_experienceLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الخبرة'**
  String get jobs_experienceLevel;

  /// No description provided for @jobs_entryLevel.
  ///
  /// In ar, this message translates to:
  /// **'مبتدئ'**
  String get jobs_entryLevel;

  /// No description provided for @jobs_midLevel.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get jobs_midLevel;

  /// No description provided for @jobs_seniorLevel.
  ///
  /// In ar, this message translates to:
  /// **'خبير'**
  String get jobs_seniorLevel;

  /// No description provided for @jobs_manager.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get jobs_manager;

  /// No description provided for @jobs_executive.
  ///
  /// In ar, this message translates to:
  /// **'تنفيذي'**
  String get jobs_executive;

  /// No description provided for @jobs_salaryRange.
  ///
  /// In ar, this message translates to:
  /// **'نطاق الراتب'**
  String get jobs_salaryRange;

  /// No description provided for @jobs_applyFilter.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق التصفية'**
  String get jobs_applyFilter;

  /// No description provided for @jobs_filterApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيق التصفية'**
  String get jobs_filterApplied;

  /// No description provided for @jobs_filtersCleared.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح جميع الفلاتر'**
  String get jobs_filtersCleared;

  /// No description provided for @jobs_companyName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشركة'**
  String get jobs_companyName;

  /// No description provided for @jobs_location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get jobs_location;

  /// No description provided for @jobs_salary.
  ///
  /// In ar, this message translates to:
  /// **'الراتب'**
  String get jobs_salary;

  /// No description provided for @jobs_postedAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {time}'**
  String jobs_postedAgo(String time);

  /// No description provided for @jobs_positionsLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count} وظائف متبقية'**
  String jobs_positionsLeft(int count);

  /// No description provided for @jobs_savedToBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى المحفوظات'**
  String get jobs_savedToBookmarks;

  /// No description provided for @jobs_removedFromBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإزالة من المحفوظات'**
  String get jobs_removedFromBookmarks;

  /// No description provided for @jobs_applyNow.
  ///
  /// In ar, this message translates to:
  /// **'تقدم الآن'**
  String get jobs_applyNow;

  /// No description provided for @jobs_jobDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف الوظيفة'**
  String get jobs_jobDescription;

  /// No description provided for @jobs_requirements.
  ///
  /// In ar, this message translates to:
  /// **'المتطلبات'**
  String get jobs_requirements;

  /// No description provided for @jobs_benefits.
  ///
  /// In ar, this message translates to:
  /// **'المزايا'**
  String get jobs_benefits;

  /// No description provided for @jobs_aboutCompany.
  ///
  /// In ar, this message translates to:
  /// **'عن الشركة'**
  String get jobs_aboutCompany;

  /// No description provided for @jobs_softwareEngineer.
  ///
  /// In ar, this message translates to:
  /// **'مهندس برمجيات'**
  String get jobs_softwareEngineer;

  /// No description provided for @jobs_lookingFor.
  ///
  /// In ar, this message translates to:
  /// **'نبحث عن مهندس برمجيات متميز للانضمام إلى فريقنا والمساعدة في بناء حلول مبتكرة...'**
  String get jobs_lookingFor;

  /// No description provided for @courses_title.
  ///
  /// In ar, this message translates to:
  /// **'الدورات'**
  String get courses_title;

  /// No description provided for @courses_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن دورات...'**
  String get courses_searchHint;

  /// No description provided for @courses_filterUnderDev.
  ///
  /// In ar, this message translates to:
  /// **'التصفية قيد التطوير'**
  String get courses_filterUnderDev;

  /// No description provided for @courses_categorySelected.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار: {category}'**
  String courses_categorySelected(String category);

  /// No description provided for @courses_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get courses_all;

  /// No description provided for @courses_programming.
  ///
  /// In ar, this message translates to:
  /// **'البرمجة'**
  String get courses_programming;

  /// No description provided for @courses_design.
  ///
  /// In ar, this message translates to:
  /// **'التصميم'**
  String get courses_design;

  /// No description provided for @courses_marketing.
  ///
  /// In ar, this message translates to:
  /// **'التسويق'**
  String get courses_marketing;

  /// No description provided for @courses_business.
  ///
  /// In ar, this message translates to:
  /// **'الأعمال'**
  String get courses_business;

  /// No description provided for @courses_finance.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get courses_finance;

  /// No description provided for @courses_flutterDev.
  ///
  /// In ar, this message translates to:
  /// **'دورة تطوير تطبيقات Flutter'**
  String get courses_flutterDev;

  /// No description provided for @courses_instructorName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدرب'**
  String get courses_instructorName;

  /// No description provided for @courses_rating.
  ///
  /// In ar, this message translates to:
  /// **'{rating}'**
  String courses_rating(String rating);

  /// No description provided for @courses_reviews.
  ///
  /// In ar, this message translates to:
  /// **'({count} تقييم)'**
  String courses_reviews(int count);

  /// No description provided for @courses_hours.
  ///
  /// In ar, this message translates to:
  /// **'{count} ساعة'**
  String courses_hours(int count);

  /// No description provided for @courses_completed.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% مكتمل'**
  String courses_completed(int percent);

  /// No description provided for @courses_startCourse.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الدورة'**
  String get courses_startCourse;

  /// No description provided for @courses_continueCourse.
  ///
  /// In ar, this message translates to:
  /// **'استمر في الدورة'**
  String get courses_continueCourse;

  /// No description provided for @posts_title.
  ///
  /// In ar, this message translates to:
  /// **'المنشورات'**
  String get posts_title;

  /// No description provided for @posts_newPost.
  ///
  /// In ar, this message translates to:
  /// **'منشور جديد'**
  String get posts_newPost;

  /// No description provided for @posts_createPost.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء منشور'**
  String get posts_createPost;

  /// No description provided for @posts_whatsOnYourMind.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يدور في ذهنك؟'**
  String get posts_whatsOnYourMind;

  /// No description provided for @posts_post.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get posts_post;

  /// No description provided for @posts_addImage.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get posts_addImage;

  /// No description provided for @posts_addVideo.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فيديو'**
  String get posts_addVideo;

  /// No description provided for @posts_trendingTopics.
  ///
  /// In ar, this message translates to:
  /// **'المواضيع الرائجة'**
  String get posts_trendingTopics;

  /// No description provided for @posts_topicPosts.
  ///
  /// In ar, this message translates to:
  /// **'{count} منشور'**
  String posts_topicPosts(int count);

  /// No description provided for @posts_suggestedFollows.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات المتابعة'**
  String get posts_suggestedFollows;

  /// No description provided for @posts_companyFollowers.
  ///
  /// In ar, this message translates to:
  /// **'{count} متابع'**
  String posts_companyFollowers(int count);

  /// No description provided for @posts_samplePost.
  ///
  /// In ar, this message translates to:
  /// **'هذا نص تجريبي للمنشور رقم {index}. يمكن أن يحتوي المنشور على نص طويل ومحتوى متنوع.'**
  String posts_samplePost(int index);

  /// No description provided for @posts_hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {hours} ساعات'**
  String posts_hoursAgo(int hours);

  /// No description provided for @posts_companyName.
  ///
  /// In ar, this message translates to:
  /// **'شركة التقنية المتقدمة'**
  String get posts_companyName;

  /// No description provided for @posts_liked.
  ///
  /// In ar, this message translates to:
  /// **'تم الإعجاب'**
  String get posts_liked;

  /// No description provided for @posts_unliked.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الإعجاب'**
  String get posts_unliked;

  /// No description provided for @posts_shared.
  ///
  /// In ar, this message translates to:
  /// **'تمت المشاركة'**
  String get posts_shared;

  /// No description provided for @posts_commentAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة التعليق'**
  String get posts_commentAdded;

  /// No description provided for @chat_title.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات'**
  String get chat_title;

  /// No description provided for @chat_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في المحادثات...'**
  String get chat_searchHint;

  /// No description provided for @chat_newChat.
  ///
  /// In ar, this message translates to:
  /// **'محادثة جديدة'**
  String get chat_newChat;

  /// No description provided for @chat_startNewChat.
  ///
  /// In ar, this message translates to:
  /// **'بدء محادثة جديدة'**
  String get chat_startNewChat;

  /// No description provided for @chat_selectConversation.
  ///
  /// In ar, this message translates to:
  /// **'اختر محادثة للبدء'**
  String get chat_selectConversation;

  /// No description provided for @chat_typeMessage.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة...'**
  String get chat_typeMessage;

  /// No description provided for @chat_send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get chat_send;

  /// No description provided for @chat_online.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get chat_online;

  /// No description provided for @chat_offline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get chat_offline;

  /// No description provided for @chat_now.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get chat_now;

  /// No description provided for @chat_minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count} د'**
  String chat_minutesAgo(int count);

  /// No description provided for @chat_hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count} س'**
  String chat_hoursAgo(int count);

  /// No description provided for @chat_yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get chat_yesterday;

  /// No description provided for @chat_sampleMessages_1.
  ///
  /// In ar, this message translates to:
  /// **'شكراً جزيلاً لك!'**
  String get chat_sampleMessages_1;

  /// No description provided for @chat_sampleMessages_2.
  ///
  /// In ar, this message translates to:
  /// **'هل يمكنك إرسال الملفات؟'**
  String get chat_sampleMessages_2;

  /// No description provided for @chat_sampleMessages_3.
  ///
  /// In ar, this message translates to:
  /// **'موعدنا غداً إن شاء الله'**
  String get chat_sampleMessages_3;

  /// No description provided for @chat_sampleMessages_4.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الطلب'**
  String get chat_sampleMessages_4;

  /// No description provided for @chat_sampleMessages_5.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، كيف حالك؟'**
  String get chat_sampleMessages_5;

  /// No description provided for @notifications_title.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications_title;

  /// No description provided for @notifications_markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get notifications_markAllRead;

  /// No description provided for @notifications_allMarkedRead.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد جميع الإشعارات كمقروءة'**
  String get notifications_allMarkedRead;

  /// No description provided for @notifications_opened.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح: {title}'**
  String notifications_opened(String title);

  /// No description provided for @notifications_noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات جديدة'**
  String get notifications_noNotifications;

  /// No description provided for @notifications_jobAccepted_title.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول طلبك'**
  String get notifications_jobAccepted_title;

  /// No description provided for @notifications_jobAccepted_message.
  ///
  /// In ar, this message translates to:
  /// **'تهانينا! تم قبول طلبك لوظيفة مطور Flutter في شركة التقنية المتقدمة'**
  String get notifications_jobAccepted_message;

  /// No description provided for @notifications_newMessage_title.
  ///
  /// In ar, this message translates to:
  /// **'رسالة جديدة'**
  String get notifications_newMessage_title;

  /// No description provided for @notifications_newMessage_message.
  ///
  /// In ar, this message translates to:
  /// **'لديك رسالة جديدة من أحمد محمد'**
  String get notifications_newMessage_message;

  /// No description provided for @notifications_newCourse_title.
  ///
  /// In ar, this message translates to:
  /// **'دورة جديدة متاحة'**
  String get notifications_newCourse_title;

  /// No description provided for @notifications_newCourse_message.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة دورة جديدة في تطوير تطبيقات الموبايل'**
  String get notifications_newCourse_message;

  /// No description provided for @notifications_companyVerified_title.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من شركتك'**
  String get notifications_companyVerified_title;

  /// No description provided for @notifications_companyVerified_message.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من بيانات شركتك بنجاح'**
  String get notifications_companyVerified_message;

  /// No description provided for @notifications_postLiked_title.
  ///
  /// In ar, this message translates to:
  /// **'إعجاب بمنشورك'**
  String get notifications_postLiked_title;

  /// No description provided for @notifications_postLiked_message.
  ///
  /// In ar, this message translates to:
  /// **'أعجب {count} شخص بمنشورك الأخير'**
  String notifications_postLiked_message(int count);

  /// No description provided for @notifications_newComment_title.
  ///
  /// In ar, this message translates to:
  /// **'تعليق جديد'**
  String get notifications_newComment_title;

  /// No description provided for @notifications_newComment_message.
  ///
  /// In ar, this message translates to:
  /// **'علق سعود على منشورك: \"محتوى رائع!\"'**
  String get notifications_newComment_message;

  /// No description provided for @notifications_newFollower_title.
  ///
  /// In ar, this message translates to:
  /// **'متابع جديد'**
  String get notifications_newFollower_title;

  /// No description provided for @notifications_newFollower_message.
  ///
  /// In ar, this message translates to:
  /// **'بدأ خالد العتيبي بمتابعتك'**
  String get notifications_newFollower_message;

  /// No description provided for @notifications_appUpdate_title.
  ///
  /// In ar, this message translates to:
  /// **'تحديث التطبيق'**
  String get notifications_appUpdate_title;

  /// No description provided for @notifications_appUpdate_message.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة ميزات جديدة للتطبيق'**
  String get notifications_appUpdate_message;

  /// No description provided for @notifications_minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقائق'**
  String notifications_minutesAgo(int count);

  /// No description provided for @notifications_hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعات'**
  String notifications_hoursAgo(int count);

  /// No description provided for @notifications_daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} أيام'**
  String notifications_daysAgo(int count);

  /// No description provided for @companies_title.
  ///
  /// In ar, this message translates to:
  /// **'شركاتي'**
  String get companies_title;

  /// No description provided for @companies_createCompany.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء شركة'**
  String get companies_createCompany;

  /// No description provided for @companies_verification.
  ///
  /// In ar, this message translates to:
  /// **'التحقق'**
  String get companies_verification;

  /// No description provided for @companies_verified.
  ///
  /// In ar, this message translates to:
  /// **'موثقة'**
  String get companies_verified;

  /// No description provided for @companies_pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get companies_pending;

  /// No description provided for @admin_dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get admin_dashboard;

  /// No description provided for @savedItems_title.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get savedItems_title;

  /// No description provided for @savedItems_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر محفوظة'**
  String get savedItems_empty;

  /// No description provided for @savedItems_emptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا العناصر التي تقوم بحفظها'**
  String get savedItems_emptyMessage;

  /// No description provided for @savedItems_jobs.
  ///
  /// In ar, this message translates to:
  /// **'الوظائف المحفوظة'**
  String get savedItems_jobs;

  /// No description provided for @savedItems_posts.
  ///
  /// In ar, this message translates to:
  /// **'المنشورات المحفوظة'**
  String get savedItems_posts;

  /// No description provided for @savedItems_courses.
  ///
  /// In ar, this message translates to:
  /// **'الدورات المحفوظة'**
  String get savedItems_courses;

  /// No description provided for @forgotPassword_title.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور'**
  String get forgotPassword_title;

  /// No description provided for @forgotPassword_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور'**
  String get forgotPassword_subtitle;

  /// No description provided for @forgotPassword_sendLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرابط'**
  String get forgotPassword_sendLink;

  /// No description provided for @forgotPassword_backToLogin.
  ///
  /// In ar, this message translates to:
  /// **'العودة لتسجيل الدخول'**
  String get forgotPassword_backToLogin;

  /// No description provided for @forgotPassword_emailSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني'**
  String get forgotPassword_emailSent;

  /// No description provided for @forgotPassword_checkEmail.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني'**
  String get forgotPassword_checkEmail;

  /// No description provided for @error_pageNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة'**
  String get error_pageNotFound;

  /// No description provided for @error_goHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get error_goHome;

  /// No description provided for @error_unknown.
  ///
  /// In ar, this message translates to:
  /// **'خطأ غير معروف'**
  String get error_unknown;

  /// No description provided for @error_networkError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال'**
  String get error_networkError;

  /// No description provided for @error_tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get error_tryAgain;

  /// No description provided for @desktop_sidebar_collapse.
  ///
  /// In ar, this message translates to:
  /// **'طي القائمة'**
  String get desktop_sidebar_collapse;

  /// No description provided for @desktop_sidebar_expand.
  ///
  /// In ar, this message translates to:
  /// **'توسيع'**
  String get desktop_sidebar_expand;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
