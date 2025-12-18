import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TAMAD HUB';
  @override
  String get appTagline => 'Integrated Professional Platform';

  @override
  String get common_ok => 'OK';
  @override
  String get common_cancel => 'Cancel';
  @override
  String get common_save => 'Save';
  @override
  String get common_delete => 'Delete';
  @override
  String get common_edit => 'Edit';
  @override
  String get common_close => 'Close';
  @override
  String get common_search => 'Search';
  @override
  String get common_filter => 'Filter';
  @override
  String get common_apply => 'Apply';
  @override
  String get common_clear => 'Clear';
  @override
  String get common_clearAll => 'Clear All';
  @override
  String get common_loading => 'Loading...';
  @override
  String get common_error => 'Error';
  @override
  String get common_success => 'Success';
  @override
  String get common_retry => 'Retry';
  @override
  String get common_back => 'Back';
  @override
  String get common_next => 'Next';
  @override
  String get common_previous => 'Previous';
  @override
  String get common_submit => 'Submit';
  @override
  String get common_share => 'Share';
  @override
  String get common_follow => 'Follow';
  @override
  String get common_following => 'Following';
  @override
  String get common_unfollow => 'Unfollow';
  @override
  String get common_like => 'Like';
  @override
  String get common_comment => 'Comment';
  @override
  String get common_more => 'More';
  @override
  String get common_seeAll => 'See All';
  @override
  String get common_noResults => 'No results found';
  @override
  String get common_underDevelopment => 'Under Development';
  @override
  String get common_comingSoon => 'Coming Soon';

  @override
  String get nav_home => 'Home';
  @override
  String get nav_jobs => 'Jobs';
  @override
  String get nav_courses => 'Courses';
  @override
  String get nav_chat => 'Chat';
  @override
  String get nav_profile => 'Profile';

  @override
  String get auth_welcomeBack => 'Welcome Back';
  @override
  String get auth_loginSubtitle => 'Sign in to continue to TAMAD HUB';
  @override
  String get auth_createAccount => 'Create Account';
  @override
  String get auth_createAccountSubtitle => 'Join TAMAD HUB today';
  @override
  String get auth_email => 'Email';
  @override
  String get auth_emailHint => 'Enter your email';
  @override
  String get auth_password => 'Password';
  @override
  String get auth_passwordHint => 'Enter your password';
  @override
  String get auth_confirmPassword => 'Confirm Password';
  @override
  String get auth_confirmPasswordHint => 'Re-enter your password';
  @override
  String get auth_fullName => 'Full Name';
  @override
  String get auth_fullNameHint => 'Enter your full name';
  @override
  String get auth_accountType => 'Account Type';
  @override
  String get auth_user => 'User';
  @override
  String get auth_instructor => 'Instructor';
  @override
  String get auth_login => 'Login';
  @override
  String get auth_register => 'Create Account';
  @override
  String get auth_forgotPassword => 'Forgot Password?';
  @override
  String get auth_noAccount => 'Don\'t have an account?';
  @override
  String get auth_haveAccount => 'Already have an account?';
  @override
  String get auth_logout => 'Logout';
  @override
  String get auth_logoutConfirm => 'Are you sure you want to logout?';
  @override
  String get auth_emailRequired => 'Please enter your email';
  @override
  String get auth_emailInvalid => 'Please enter a valid email';
  @override
  String get auth_passwordRequired => 'Please enter your password';
  @override
  String get auth_passwordTooShort => 'Password must be at least 6 characters';
  @override
  String get auth_confirmPasswordRequired => 'Please confirm your password';
  @override
  String get auth_passwordsNotMatch => 'Passwords do not match';
  @override
  String get auth_nameRequired => 'Please enter your full name';
  @override
  String get auth_nameTooShort => 'Name must be at least 2 characters';
  @override
  String get auth_resetPasswordSent => 'Password reset link has been sent to your email';
  @override
  String get auth_enterEmailForReset => 'Enter your email to reset password';
  @override
  String get auth_sendResetLink => 'Send Reset Link';

  @override
  String get profile_title => 'Profile';
  @override
  String get profile_editProfile => 'Edit Profile';
  @override
  String get profile_followers => 'Followers';
  @override
  String get profile_following => 'Following';
  @override
  String get profile_posts => 'Posts';
  @override
  String get profile_aboutMe => 'About Me';
  @override
  String get profile_noAbout => 'No bio added yet.';
  @override
  String get profile_recentActivity => 'Recent Activity';
  @override
  String get profile_noActivity => 'No recent activity';
  @override
  String profile_joinedOn(String date) => 'Joined $date';
  @override
  String get profile_myApplications => 'My Applications';
  @override
  String get profile_myCompanies => 'My Companies';
  @override
  String get profile_myCourses => 'My Courses';
  @override
  String get profile_myPosts => 'My Posts';
  @override
  String get profile_savedItems => 'Saved Items';
  @override
  String get profile_quickActions => 'Quick Actions';
  @override
  String get profile_profileLinkCopied => 'Profile link copied';

  @override
  String get settings_title => 'Settings';
  @override
  String get settings_account => 'Account';
  @override
  String get settings_accountInfo => 'Account Information';
  @override
  String get settings_accountInfoSub => 'Update your personal information';
  @override
  String get settings_security => 'Password & Security';
  @override
  String get settings_securitySub => 'Manage password and two-factor authentication';
  @override
  String get settings_privacy => 'Privacy';
  @override
  String get settings_privacySub => 'Control who can see your profile';
  @override
  String get settings_preferences => 'Preferences';
  @override
  String get settings_notifications => 'Notifications';
  @override
  String get settings_notificationsEnabled => 'Notifications enabled';
  @override
  String get settings_notificationsDisabled => 'Notifications disabled';
  @override
  String settings_notificationsToggled(String status) => 'Notifications $status';
  @override
  String get settings_theme => 'Theme';
  @override
  String get settings_themeLight => 'Light Mode';
  @override
  String get settings_themeDark => 'Dark Mode';
  @override
  String settings_themeSwitched(String mode) => 'Switched to $mode';
  @override
  String get settings_language => 'Language';
  @override
  String get settings_languageArabic => 'Arabic';
  @override
  String get settings_languageEnglish => 'English';
  @override
  String settings_languageChanged(String language) => 'Language changed to $language';
  @override
  String get settings_selectLanguage => 'Select Language';
  @override
  String get settings_support => 'Support';
  @override
  String get settings_helpCenter => 'Help Center';
  @override
  String get settings_helpCenterSub => 'Get help and support';
  @override
  String get settings_termsOfService => 'Terms of Service';
  @override
  String get settings_termsOfServiceSub => 'Read terms and conditions';
  @override
  String get settings_privacyPolicy => 'Privacy Policy';
  @override
  String get settings_privacyPolicySub => 'Read privacy policy';
  @override
  String get settings_aboutApp => 'About App';
  @override
  String settings_version(String version) => 'Version $version';
  @override
  String get settings_session => 'Session';
  @override
  String get settings_logoutSub => 'Sign out of your account';
  @override
  String get settings_dangerZone => 'Danger Zone';
  @override
  String get settings_deleteAccount => 'Delete Account';
  @override
  String get settings_deleteAccountSub => 'Permanently delete your account';
  @override
  String get settings_deleteAccountTitle => 'Delete Account';
  @override
  String get settings_deleteAccountConfirm => 'Are you sure you want to permanently delete your account?\n\nThis action cannot be undone and all your data will be deleted.';
  @override
  String get settings_deleteAccountRequested => 'Account deletion request submitted. It will be reviewed within 24 hours.';
  @override
  String get settings_passwordResetSent => 'Password reset link will be sent to your email';
  @override
  String get settings_privacyUnderDev => 'Privacy settings under development';
  @override
  String get settings_helpCenterUnderDev => 'Help center under development';
  @override
  String get settings_couldNotOpenLink => 'Could not open link';
  @override
  String get settings_allRightsReserved => 'All rights reserved.';

  @override
  String get jobs_title => 'Jobs';
  @override
  String get jobs_searchHint => 'Search for jobs...';
  @override
  String get jobs_postJob => 'Post Job';
  @override
  String get jobs_filter => 'Filter';
  @override
  String get jobs_sort => 'Sort';
  @override
  String get jobs_sortNewest => 'Newest';
  @override
  String get jobs_sortRelevant => 'Most Relevant';
  @override
  String get jobs_sortHighestSalary => 'Highest Salary';
  @override
  String get jobs_sortNearest => 'Nearest';
  @override
  String get jobs_jobType => 'Job Type';
  @override
  String get jobs_fullTime => 'Full Time';
  @override
  String get jobs_partTime => 'Part Time';
  @override
  String get jobs_contract => 'Contract';
  @override
  String get jobs_remote => 'Remote';
  @override
  String get jobs_internship => 'Internship';
  @override
  String get jobs_experienceLevel => 'Experience Level';
  @override
  String get jobs_entryLevel => 'Entry Level';
  @override
  String get jobs_midLevel => 'Mid Level';
  @override
  String get jobs_seniorLevel => 'Senior';
  @override
  String get jobs_manager => 'Manager';
  @override
  String get jobs_executive => 'Executive';
  @override
  String get jobs_salaryRange => 'Salary Range';
  @override
  String get jobs_applyFilter => 'Apply Filter';
  @override
  String get jobs_filterApplied => 'Filter applied';
  @override
  String get jobs_filtersCleared => 'All filters cleared';
  @override
  String get jobs_companyName => 'Company Name';
  @override
  String get jobs_location => 'Location';
  @override
  String get jobs_salary => 'Salary';
  @override
  String jobs_postedAgo(String time) => '$time ago';
  @override
  String jobs_positionsLeft(int count) => '$count positions left';
  @override
  String get jobs_savedToBookmarks => 'Added to bookmarks';
  @override
  String get jobs_removedFromBookmarks => 'Removed from bookmarks';
  @override
  String get jobs_applyNow => 'Apply Now';
  @override
  String get jobs_jobDescription => 'Job Description';
  @override
  String get jobs_requirements => 'Requirements';
  @override
  String get jobs_benefits => 'Benefits';
  @override
  String get jobs_aboutCompany => 'About Company';
  @override
  String get jobs_softwareEngineer => 'Software Engineer';
  @override
  String get jobs_lookingFor => 'We are looking for a talented software engineer to join our team and help build innovative solutions...';

  @override
  String get courses_title => 'Courses';
  @override
  String get courses_searchHint => 'Search for courses...';
  @override
  String get courses_filterUnderDev => 'Filter under development';
  @override
  String courses_categorySelected(String category) => 'Selected: $category';
  @override
  String get courses_all => 'All';
  @override
  String get courses_programming => 'Programming';
  @override
  String get courses_design => 'Design';
  @override
  String get courses_marketing => 'Marketing';
  @override
  String get courses_business => 'Business';
  @override
  String get courses_finance => 'Finance';
  @override
  String get courses_flutterDev => 'Flutter App Development Course';
  @override
  String get courses_instructorName => 'Instructor Name';
  @override
  String courses_rating(String rating) => rating;
  @override
  String courses_reviews(int count) => '($count reviews)';
  @override
  String courses_hours(int count) => '$count hours';
  @override
  String courses_completed(int percent) => '$percent% completed';
  @override
  String get courses_startCourse => 'Start Course';
  @override
  String get courses_continueCourse => 'Continue Course';

  @override
  String get posts_title => 'Posts';
  @override
  String get posts_newPost => 'New Post';
  @override
  String get posts_createPost => 'Create Post';
  @override
  String get posts_whatsOnYourMind => 'What\'s on your mind?';
  @override
  String get posts_post => 'Post';
  @override
  String get posts_addImage => 'Add Image';
  @override
  String get posts_addVideo => 'Add Video';
  @override
  String get posts_trendingTopics => 'Trending Topics';
  @override
  String posts_topicPosts(int count) => '$count posts';
  @override
  String get posts_suggestedFollows => 'Suggested Follows';
  @override
  String posts_companyFollowers(int count) => '$count followers';
  @override
  String posts_samplePost(int index) => 'This is a sample post number $index. Posts can contain long text and varied content.';
  @override
  String posts_hoursAgo(int hours) => '$hours hours ago';
  @override
  String get posts_companyName => 'Advanced Technology Company';
  @override
  String get posts_liked => 'Liked';
  @override
  String get posts_unliked => 'Unliked';
  @override
  String get posts_shared => 'Shared';
  @override
  String get posts_commentAdded => 'Comment added';

  @override
  String get chat_title => 'Chat';
  @override
  String get chat_searchHint => 'Search conversations...';
  @override
  String get chat_newChat => 'New Chat';
  @override
  String get chat_startNewChat => 'Start new conversation';
  @override
  String get chat_selectConversation => 'Select a conversation to start';
  @override
  String get chat_typeMessage => 'Type a message...';
  @override
  String get chat_send => 'Send';
  @override
  String get chat_online => 'Online';
  @override
  String get chat_offline => 'Offline';
  @override
  String get chat_now => 'Now';
  @override
  String chat_minutesAgo(int count) => '${count}m';
  @override
  String chat_hoursAgo(int count) => '${count}h';
  @override
  String get chat_yesterday => 'Yesterday';

  @override
  String get notifications_title => 'Notifications';
  @override
  String get notifications_markAllRead => 'Mark all as read';
  @override
  String get notifications_allMarkedRead => 'All notifications marked as read';
  @override
  String notifications_opened(String title) => 'Opened: $title';
  @override
  String get notifications_noNotifications => 'No new notifications';
  @override
  String get notifications_jobAccepted_title => 'Application Accepted';
  @override
  String get notifications_jobAccepted_message => 'Congratulations! Your application for Flutter Developer at Advanced Tech Company has been accepted';
  @override
  String get notifications_newMessage_title => 'New Message';
  @override
  String get notifications_newMessage_message => 'You have a new message from Ahmed Mohamed';
  @override
  String get notifications_newCourse_title => 'New Course Available';
  @override
  String get notifications_newCourse_message => 'A new course in mobile app development has been added';
  @override
  String get notifications_companyVerified_title => 'Company Verified';
  @override
  String get notifications_companyVerified_message => 'Your company data has been verified successfully';
  @override
  String get notifications_postLiked_title => 'Post Liked';
  @override
  String notifications_postLiked_message(int count) => '$count people liked your latest post';
  @override
  String get notifications_newComment_title => 'New Comment';
  @override
  String get notifications_newComment_message => 'Saud commented on your post: "Great content!"';
  @override
  String get notifications_newFollower_title => 'New Follower';
  @override
  String get notifications_newFollower_message => 'Khaled Al-Otaibi started following you';
  @override
  String get notifications_appUpdate_title => 'App Update';
  @override
  String get notifications_appUpdate_message => 'New features have been added to the app';
  @override
  String notifications_minutesAgo(int count) => '$count minutes ago';
  @override
  String notifications_hoursAgo(int count) => '$count hours ago';
  @override
  String notifications_daysAgo(int count) => '$count days ago';

  @override
  String get companies_title => 'My Companies';
  @override
  String get companies_createCompany => 'Create Company';
  @override
  String get companies_verification => 'Verification';
  @override
  String get companies_verified => 'Verified';
  @override
  String get companies_pending => 'Pending Review';

  @override
  String get admin_dashboard => 'Dashboard';

  @override
  String get savedItems_title => 'Saved Items';
  @override
  String get savedItems_empty => 'No saved items';
  @override
  String get savedItems_emptyMessage => 'Items you save will appear here';
  @override
  String get savedItems_jobs => 'Saved Jobs';
  @override
  String get savedItems_posts => 'Saved Posts';
  @override
  String get savedItems_courses => 'Saved Courses';

  @override
  String get forgotPassword_title => 'Forgot Password';
  @override
  String get forgotPassword_subtitle => 'Enter your email and we\'ll send you a password reset link';
  @override
  String get forgotPassword_sendLink => 'Send Link';
  @override
  String get forgotPassword_backToLogin => 'Back to Login';
  @override
  String get forgotPassword_emailSent => 'Reset link sent to your email';
  @override
  String get forgotPassword_checkEmail => 'Check your email';

  @override
  String get error_pageNotFound => 'Page not found';
  @override
  String get error_goHome => 'Go Home';
  @override
  String get error_unknown => 'Unknown error';
  @override
  String get error_networkError => 'Network error';
  @override
  String get error_tryAgain => 'Try again';

  @override
  String get desktop_sidebar_collapse => 'Collapse Menu';
  @override
  String get desktop_sidebar_expand => 'Expand';
}
