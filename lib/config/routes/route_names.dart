abstract final class RouteNames {
  // ===== AUTH ROUTES =====
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ===== SEARCH =====
  static const String search = '/search';

  // ===== JOBS =====
  static const String jobs = '/jobs';
  static const String jobDetail = '/jobs/:id';
  static const String jobDetails = 'jobDetails'; // Legacy - use jobDetail
  static const String jobApplications = 'jobApplications';
  static const String applyJob = '/jobs/:id/apply';
  static const String jobApply = 'apply'; // Legacy - use applyJob
  static const String manageJob = 'manageJob';
  static const String postJob = '/post-job';
  static const String editJob = '/jobs/:id/edit';
  static const String myApplications = '/my-applications';

  // ===== COURSES =====
  static const String courses = '/courses';
  static const String courseDetail = '/courses/:id';
  static const String courseDetails = 'courseDetails'; // Legacy - use courseDetail
  static const String lesson = 'lesson';
  static const String lessonDetail = '/courses/:courseId/lessons/:lessonId';
  static const String enrollCourse = '/courses/:id/enroll';
  static const String courseEnroll = 'enroll'; // Legacy - use enrollCourse
  static const String quiz = 'quiz';
  static const String quizAttempt = '/courses/:courseId/quiz/:quizId';
  static const String certificate = 'certificate';
  static const String certificateView = '/certificates/:id';
  static const String verifyCertificate = '/verify/:token';
  static const String myLearning = '/my-learning';
  static const String myEnrollments = '/my-enrollments';
  static const String myCourses = '/my-courses';

  // ===== INSTRUCTOR =====
  static const String instructorDashboard = '/instructor';
  static const String instructorApplication = '/become-instructor';
  static const String instructorVerification = '/instructor/verification';
  static const String createCourse = '/instructor/courses/new';
  static const String editCourse = '/instructor/courses/:id/edit';
  static const String courseBuilder = 'course-builder'; // Legacy - use createCourse
  static const String courseAnalytics = '/instructor/courses/:id/analytics';
  static const String createQuiz = '/instructor/courses/:courseId/quiz/new';
  static const String editQuiz = '/instructor/courses/:courseId/quiz/:quizId/edit';
  static const String issueCertificate = '/instructor/courses/:courseId/certificate/:enrollmentId';

  // ===== POSTS =====
  static const String posts = '/posts';
  static const String postDetail = '/posts/:id';
  static const String postDetails = 'postDetails'; // Legacy - use postDetail
  static const String createPost = '/create-post';
  static const String editPost = '/posts/:id/edit';

  // ===== CHAT =====
  static const String chat = '/chat';
  static const String chatRoom = 'chatRoom';
  static const String chatConversation = '/chat/:id';

  // ===== PROFILE =====
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String userProfile = '/user';
  static const String publicProfile = '/user/:id';

  // ===== NOTIFICATIONS =====
  static const String notifications = '/notifications';
  static const String notificationSettings = '/settings/notifications';

  // ===== COMPANIES =====
  static const String companies = '/companies';
  static const String companyDetail = '/companies/:id';
  static const String companyDetails = 'companyDetails'; // Legacy - use companyDetail
  static const String createCompany = '/companies/new';
  static const String editCompany = '/companies/:id/edit';
  static const String companyVerification = '/companies/:id/verification';
  static const String companyDashboard = '/companies/:id/dashboard';
  static const String companyAnalytics = '/companies/:id/analytics';
  static const String companyTeam = '/companies/:id/team';
  static const String companyJobs = '/companies/:id/jobs';
  static const String companyCourses = '/companies/:id/courses';
  static const String companySettings = '/companies/:id/settings';

  // ===== COMPANY TRAINING =====
  static const String companyTrainingDashboard = '/companies/:id/training';
  static const String createCompanyCourse = '/companies/:id/training/courses/new';
  static const String editCompanyCourse = '/companies/:id/training/courses/:courseId/edit';

  // ===== ADMIN =====
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminCourses = '/admin/courses';
  static const String adminCompanies = '/admin/companies';
  static const String adminJobs = '/admin/jobs';
  static const String adminVerifications = '/admin/verifications';
  static const String adminReports = '/admin/reports';
  static const String adminAuditLog = '/admin/audit-log';
  static const String adminSettings = '/admin/settings';

  // ===== SAVED ITEMS =====
  static const String savedItems = '/saved-items';

  // ===== VERIFICATION =====
  static const String verificationDocuments = '/verification/documents';
  static const String verificationRequirements = '/verification/requirements';

  // ===== ADMIN VERIFICATION QUEUES =====
  static const String adminInstructorVerifications = '/admin/verifications/instructors';
  static const String adminCompanyVerifications = '/admin/verifications/companies';

  // ===== COURSE PUBLISHING =====
  static const String coursePublish = '/instructor/courses/:courseId/publish';
  static const String coursePreview = '/courses/:courseId/preview';

  // ===== QUIZ AUTHORING =====
  static const String quizBuilder = '/instructor/courses/:courseId/quizzes/:quizId/build';
  static const String questionBank = '/instructor/courses/:courseId/questions';
  static const String quizAttempts = '/courses/:courseId/quiz/:quizId/attempts';
  static const String lockedLesson = '/courses/:courseId/lessons/:lessonId/locked';
  static const String finalQuizGate = '/courses/:courseId/final-quiz';

  // ===== CERTIFICATE =====
  static const String certificateVerifyPublic = '/verify/:code';
  static const String certificateRevoke = '/instructor/certificates/:certificateId/revoke';

  // ===== JOBS PIPELINE =====
  static const String applicationPipeline = '/companies/:companyId/jobs/:jobId/pipeline';
  static const String applicantReview = '/companies/:companyId/jobs/:jobId/applications/:applicationId';

  // ===== SOCIAL SAFETY =====
  static const String reportContent = '/report';
  static const String blockedUsers = '/settings/blocked';
  static const String privacySettings = '/settings/privacy';

  // ===== SYSTEM ERROR PAGES =====
  static const String unauthorized = '/403';
  static const String notFound = '/404';
  static const String networkError = '/error';
}
