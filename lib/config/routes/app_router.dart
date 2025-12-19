import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth.dart';
import '../../features/courses/presentation/bloc/instructor_bloc.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/companies/presentation/pages/company_details_page.dart';
import '../../features/companies/presentation/pages/company_verification_page.dart';
import '../../features/companies/presentation/pages/create_company_page.dart';
import '../../features/companies/presentation/pages/my_companies_page.dart';
import '../../features/courses/presentation/pages/course_details_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/course_builder_page.dart';
import '../../features/courses/presentation/pages/instructor_application_page.dart';
import '../../features/courses/presentation/pages/instructor_dashboard_page.dart';
import '../../features/courses/presentation/pages/lesson_page.dart';
import '../../features/jobs/presentation/pages/job_applications_page.dart';
import '../../features/jobs/presentation/pages/job_details_page.dart';
import '../../features/jobs/presentation/pages/jobs_page.dart';
import '../../features/jobs/presentation/pages/manage_job_page.dart';
import '../../features/jobs/presentation/pages/my_applications_page.dart';
import '../../features/jobs/presentation/pages/post_job_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/posts/presentation/pages/create_post_page.dart';
import '../../features/posts/presentation/pages/post_details_page.dart';
import '../../features/posts/presentation/pages/posts_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/saved_items_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/user_profile_page.dart';
import '../injection/injection.dart' show getIt, AuthService;
import 'main_shell.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.jobs,
            name: RouteNames.jobs,
            builder: (context, state) => const JobsPage(),
            routes: [
              GoRoute(
                path: ':jobId',
                name: RouteNames.jobDetails,
                builder: (context, state) {
                  final jobId = state.pathParameters['jobId']!;
                  return JobDetailsPage(jobId: jobId);
                },
                routes: [
                  GoRoute(
                    path: 'applications',
                    name: RouteNames.jobApplications,
                    builder: (context, state) {
                      final jobId = state.pathParameters['jobId']!;
                      return JobApplicationsPage(jobId: jobId);
                    },
                  ),
                  GoRoute(
                    path: 'manage',
                    name: RouteNames.manageJob,
                    builder: (context, state) {
                      final jobId = state.pathParameters['jobId']!;
                      return ManageJobPage(jobId: jobId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.postJob,
            name: RouteNames.postJob,
            builder: (context, state) {
              final companyId = state.uri.queryParameters['companyId'];
              return PostJobPage(companyId: companyId);
            },
          ),
          GoRoute(
            path: RouteNames.myApplications,
            name: RouteNames.myApplications,
            builder: (context, state) => const MyApplicationsPage(),
          ),
          GoRoute(
            path: RouteNames.courses,
            name: RouteNames.courses,
            builder: (context, state) => const CoursesPage(),
            routes: [
              GoRoute(
                path: ':courseId',
                name: RouteNames.courseDetails,
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CourseDetailsPage(courseId: courseId);
                },
                routes: [
                  GoRoute(
                    path: 'lesson/:lessonId',
                    name: RouteNames.lesson,
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      final lessonId = state.pathParameters['lessonId']!;
                      return LessonPage(courseId: courseId, lessonId: lessonId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.instructorDashboard,
            name: RouteNames.instructorDashboard,
            builder: (context, state) => BlocProvider(
              create: (context) => getIt<InstructorBloc>(),
              child: const InstructorDashboardPage(),
            ),
            routes: [
              GoRoute(
                path: RouteNames.courseBuilder,
                name: RouteNames.courseBuilder,
                builder: (context, state) {
                  final courseId = state.uri.queryParameters['courseId'];
                  return BlocProvider(
                    create: (context) => getIt<InstructorBloc>(),
                    child: CourseBuilderPage(courseId: courseId),
                  );
                },
              ),
              GoRoute(
                path: '${RouteNames.courseAnalytics}/:courseId',
                name: RouteNames.courseAnalytics,
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  // TODO: Create CourseAnalyticsPage
                  return Scaffold(
                    appBar: AppBar(title: const Text('Course Analytics')),
                    body: Center(child: Text('Analytics for $courseId')),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.instructorApplication,
            name: RouteNames.instructorApplication,
            builder: (context, state) => const InstructorApplicationPage(),
          ),
          GoRoute(
            path: RouteNames.posts,
            name: RouteNames.posts,
            builder: (context, state) => const PostsPage(),
            routes: [
              GoRoute(
                path: ':postId',
                name: RouteNames.postDetails,
                builder: (context, state) {
                  final postId = state.pathParameters['postId']!;
                  return PostDetailsPage(postId: postId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.createPost,
            name: RouteNames.createPost,
            builder: (context, state) => const CreatePostPage(),
          ),
          GoRoute(
            path: RouteNames.chat,
            name: RouteNames.chat,
            builder: (context, state) => const ChatListPage(),
            routes: [
              GoRoute(
                path: ':chatId',
                name: RouteNames.chatRoom,
                builder: (context, state) {
                  final chatId = state.pathParameters['chatId']!;
                  return ChatRoomPage(chatId: chatId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.editProfile,
                builder: (context, state) => const EditProfilePage(),
              ),
              GoRoute(
                path: 'settings',
                name: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
          GoRoute(
            path: '${RouteNames.userProfile}/:userId',
            name: RouteNames.userProfile,
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return UserProfilePage(userId: userId);
            },
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: RouteNames.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteNames.companies,
            name: RouteNames.companies,
            builder: (context, state) => const MyCompaniesPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createCompany,
                builder: (context, state) => const CreateCompanyPage(),
              ),
              GoRoute(
                path: ':companyId',
                name: RouteNames.companyDetails,
                builder: (context, state) {
                  final companyId = state.pathParameters['companyId']!;
                  return CompanyDetailsPage(companyId: companyId);
                },
                routes: [
                  GoRoute(
                    path: 'verification',
                    name: RouteNames.companyVerification,
                    builder: (context, state) {
                      final companyId = state.pathParameters['companyId']!;
                      return CompanyVerificationPage(companyId: companyId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.adminDashboard,
            name: RouteNames.adminDashboard,
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: RouteNames.savedItems,
            name: RouteNames.savedItems,
            builder: (context, state) => const SavedItemsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );

  static Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authService = getIt<AuthService>();
    final isAuthenticated = await authService.isAuthenticated();
    final isVisitorMode = await authService.isVisitorMode();
    final currentPath = state.matchedLocation;

    // Auth routes - splash, login, register, forgot password
    final isAuthRoute = currentPath == RouteNames.login ||
        currentPath == RouteNames.register ||
        currentPath == RouteNames.forgotPassword ||
        currentPath == RouteNames.splash;

    // Check if current route is visitor-accessible
    final isVisitorAccessible = RouteGuards.isVisitorAccessible(currentPath);

    // If authenticated and trying to access auth routes (except splash), redirect to posts
    if (isAuthenticated && isAuthRoute && currentPath != RouteNames.splash) {
      return RouteNames.posts;
    }

    // If not authenticated and not in visitor mode
    if (!isAuthenticated && !isVisitorMode) {
      // Allow auth routes
      if (isAuthRoute) {
        return null;
      }
      // Allow visitor-accessible routes
      if (isVisitorAccessible) {
        return null;
      }
      // Redirect to login for protected routes
      return RouteNames.login;
    }

    // In visitor mode, check if route is accessible
    if (isVisitorMode && !isAuthenticated) {
      if (!isVisitorAccessible && !isAuthRoute) {
        // Redirect to login for protected routes when in visitor mode
        return RouteNames.login;
      }
    }

    // If authenticated, check role-based access
    if (isAuthenticated) {
      final userRole = await authService.getCurrentUserRole();
      if (!RouteGuards.canAccess(userRole, currentPath)) {
        return RouteGuards.getRedirectPath(userRole, currentPath);
      }
    }

    return null;
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    required this.error,
    super.key,
  });

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.posts),
              child: const Text('الرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}
