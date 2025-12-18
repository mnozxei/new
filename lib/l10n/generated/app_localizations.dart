import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  // App Info
  String get appName;
  String get appTagline;

  // Common
  String get common_ok;
  String get common_cancel;
  String get common_save;
  String get common_delete;
  String get common_edit;
  String get common_close;
  String get common_search;
  String get common_filter;
  String get common_apply;
  String get common_clear;
  String get common_clearAll;
  String get common_loading;
  String get common_error;
  String get common_success;
  String get common_retry;
  String get common_back;
  String get common_next;
  String get common_previous;
  String get common_submit;
  String get common_share;
  String get common_follow;
  String get common_following;
  String get common_unfollow;
  String get common_like;
  String get common_comment;
  String get common_more;
  String get common_seeAll;
  String get common_noResults;
  String get common_underDevelopment;
  String get common_comingSoon;

  // Navigation
  String get nav_home;
  String get nav_jobs;
  String get nav_courses;
  String get nav_chat;
  String get nav_profile;

  // Auth
  String get auth_welcomeBack;
  String get auth_loginSubtitle;
  String get auth_createAccount;
  String get auth_createAccountSubtitle;
  String get auth_email;
  String get auth_emailHint;
  String get auth_password;
  String get auth_passwordHint;
  String get auth_confirmPassword;
  String get auth_confirmPasswordHint;
  String get auth_fullName;
  String get auth_fullNameHint;
  String get auth_accountType;
  String get auth_user;
  String get auth_instructor;
  String get auth_login;
  String get auth_register;
  String get auth_forgotPassword;
  String get auth_noAccount;
  String get auth_haveAccount;
  String get auth_logout;
  String get auth_logoutConfirm;
  String get auth_emailRequired;
  String get auth_emailInvalid;
  String get auth_passwordRequired;
  String get auth_passwordTooShort;
  String get auth_confirmPasswordRequired;
  String get auth_passwordsNotMatch;
  String get auth_nameRequired;
  String get auth_nameTooShort;
  String get auth_resetPasswordSent;
  String get auth_enterEmailForReset;
  String get auth_sendResetLink;

  // Profile
  String get profile_title;
  String get profile_editProfile;
  String get profile_followers;
  String get profile_following;
  String get profile_posts;
  String get profile_aboutMe;
  String get profile_noAbout;
  String get profile_recentActivity;
  String get profile_noActivity;
  String profile_joinedOn(String date);
  String get profile_myApplications;
  String get profile_myCompanies;
  String get profile_myCourses;
  String get profile_myPosts;
  String get profile_savedItems;
  String get profile_quickActions;
  String get profile_profileLinkCopied;

  // Settings
  String get settings_title;
  String get settings_account;
  String get settings_accountInfo;
  String get settings_accountInfoSub;
  String get settings_security;
  String get settings_securitySub;
  String get settings_privacy;
  String get settings_privacySub;
  String get settings_preferences;
  String get settings_notifications;
  String get settings_notificationsEnabled;
  String get settings_notificationsDisabled;
  String settings_notificationsToggled(String status);
  String get settings_theme;
  String get settings_themeLight;
  String get settings_themeDark;
  String settings_themeSwitched(String mode);
  String get settings_language;
  String get settings_languageArabic;
  String get settings_languageEnglish;
  String settings_languageChanged(String language);
  String get settings_selectLanguage;
  String get settings_support;
  String get settings_helpCenter;
  String get settings_helpCenterSub;
  String get settings_termsOfService;
  String get settings_termsOfServiceSub;
  String get settings_privacyPolicy;
  String get settings_privacyPolicySub;
  String get settings_aboutApp;
  String settings_version(String version);
  String get settings_session;
  String get settings_logoutSub;
  String get settings_dangerZone;
  String get settings_deleteAccount;
  String get settings_deleteAccountSub;
  String get settings_deleteAccountTitle;
  String get settings_deleteAccountConfirm;
  String get settings_deleteAccountRequested;
  String get settings_passwordResetSent;
  String get settings_privacyUnderDev;
  String get settings_helpCenterUnderDev;
  String get settings_couldNotOpenLink;
  String get settings_allRightsReserved;

  // Jobs
  String get jobs_title;
  String get jobs_searchHint;
  String get jobs_postJob;
  String get jobs_filter;
  String get jobs_sort;
  String get jobs_sortNewest;
  String get jobs_sortRelevant;
  String get jobs_sortHighestSalary;
  String get jobs_sortNearest;
  String get jobs_jobType;
  String get jobs_fullTime;
  String get jobs_partTime;
  String get jobs_contract;
  String get jobs_remote;
  String get jobs_internship;
  String get jobs_experienceLevel;
  String get jobs_entryLevel;
  String get jobs_midLevel;
  String get jobs_seniorLevel;
  String get jobs_manager;
  String get jobs_executive;
  String get jobs_salaryRange;
  String get jobs_applyFilter;
  String get jobs_filterApplied;
  String get jobs_filtersCleared;
  String get jobs_companyName;
  String get jobs_location;
  String get jobs_salary;
  String jobs_postedAgo(String time);
  String jobs_positionsLeft(int count);
  String get jobs_savedToBookmarks;
  String get jobs_removedFromBookmarks;
  String get jobs_applyNow;
  String get jobs_jobDescription;
  String get jobs_requirements;
  String get jobs_benefits;
  String get jobs_aboutCompany;
  String get jobs_softwareEngineer;
  String get jobs_lookingFor;

  // Courses
  String get courses_title;
  String get courses_searchHint;
  String get courses_filterUnderDev;
  String courses_categorySelected(String category);
  String get courses_all;
  String get courses_programming;
  String get courses_design;
  String get courses_marketing;
  String get courses_business;
  String get courses_finance;
  String get courses_flutterDev;
  String get courses_instructorName;
  String courses_rating(String rating);
  String courses_reviews(int count);
  String courses_hours(int count);
  String courses_completed(int percent);
  String get courses_startCourse;
  String get courses_continueCourse;

  // Posts
  String get posts_title;
  String get posts_newPost;
  String get posts_createPost;
  String get posts_whatsOnYourMind;
  String get posts_post;
  String get posts_addImage;
  String get posts_addVideo;
  String get posts_trendingTopics;
  String posts_topicPosts(int count);
  String get posts_suggestedFollows;
  String posts_companyFollowers(int count);
  String posts_samplePost(int index);
  String posts_hoursAgo(int hours);
  String get posts_companyName;
  String get posts_liked;
  String get posts_unliked;
  String get posts_shared;
  String get posts_commentAdded;

  // Chat
  String get chat_title;
  String get chat_searchHint;
  String get chat_newChat;
  String get chat_startNewChat;
  String get chat_selectConversation;
  String get chat_typeMessage;
  String get chat_send;
  String get chat_online;
  String get chat_offline;
  String get chat_now;
  String chat_minutesAgo(int count);
  String chat_hoursAgo(int count);
  String get chat_yesterday;

  // Notifications
  String get notifications_title;
  String get notifications_markAllRead;
  String get notifications_allMarkedRead;
  String notifications_opened(String title);
  String get notifications_noNotifications;
  String get notifications_jobAccepted_title;
  String get notifications_jobAccepted_message;
  String get notifications_newMessage_title;
  String get notifications_newMessage_message;
  String get notifications_newCourse_title;
  String get notifications_newCourse_message;
  String get notifications_companyVerified_title;
  String get notifications_companyVerified_message;
  String get notifications_postLiked_title;
  String notifications_postLiked_message(int count);
  String get notifications_newComment_title;
  String get notifications_newComment_message;
  String get notifications_newFollower_title;
  String get notifications_newFollower_message;
  String get notifications_appUpdate_title;
  String get notifications_appUpdate_message;
  String notifications_minutesAgo(int count);
  String notifications_hoursAgo(int count);
  String notifications_daysAgo(int count);

  // Companies
  String get companies_title;
  String get companies_createCompany;
  String get companies_verification;
  String get companies_verified;
  String get companies_pending;

  // Admin
  String get admin_dashboard;

  // Saved Items
  String get savedItems_title;
  String get savedItems_empty;
  String get savedItems_emptyMessage;
  String get savedItems_jobs;
  String get savedItems_posts;
  String get savedItems_courses;

  // Forgot Password
  String get forgotPassword_title;
  String get forgotPassword_subtitle;
  String get forgotPassword_sendLink;
  String get forgotPassword_backToLogin;
  String get forgotPassword_emailSent;
  String get forgotPassword_checkEmail;

  // Errors
  String get error_pageNotFound;
  String get error_goHome;
  String get error_unknown;
  String get error_networkError;
  String get error_tryAgain;

  // Desktop
  String get desktop_sidebar_collapse;
  String get desktop_sidebar_expand;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }
  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely an issue with the localizations generation tool. '
    'Please file an issue on GitHub with a reproducible sample app and the gen-l10n configuration that was used.'
  );
}
