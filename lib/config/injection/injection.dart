import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth.dart';
import '../../core/services/storage_service.dart';
import '../../features/ads/data/datasources/ad_remote_data_source.dart';
import '../../features/ads/data/repositories/ad_repository_impl.dart';
import '../../features/ads/domain/repositories/ad_repository.dart';
import '../../features/ads/presentation/bloc/ad_bloc.dart';
import '../../features/ads/services/ad_injection_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/companies/data/datasources/company_remote_datasource.dart';
import '../../features/companies/data/repositories/company_repository_impl.dart';
import '../../features/companies/domain/repositories/company_repository.dart';
import '../../features/companies/presentation/bloc/company_bloc.dart';
import '../../features/courses/data/datasources/course_remote_data_source.dart';
import '../../features/courses/data/repositories/course_repository_impl.dart';
import '../../features/courses/domain/repositories/course_repository.dart';
import '../../features/courses/presentation/bloc/course_bloc.dart';
import '../../features/courses/presentation/bloc/instructor_bloc.dart';
import '../../features/courses/presentation/bloc/student_bloc.dart';
import '../../features/jobs/data/datasources/job_remote_datasource.dart';
import '../../features/jobs/data/repositories/job_repository_impl.dart';
import '../../features/jobs/domain/repositories/job_repository.dart';
import '../../features/jobs/presentation/bloc/job_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/posts/data/datasources/post_remote_data_source.dart';
import '../../features/posts/data/repositories/post_repository_impl.dart';
import '../../features/posts/domain/repositories/post_repository.dart';
import '../../features/posts/presentation/bloc/post_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  _registerExternalDependencies();
  _registerServices();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerExternalDependencies() {
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
}

void _registerServices() {
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AdInjectionService>(
    () => AdInjectionService(adRepository: getIt<AdRepository>()),
  );
}

void _registerDataSources() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(supabase: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(supabase: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AdRemoteDataSource>(
    () => AdRemoteDataSourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
}

void _registerRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );

  getIt.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: getIt<CompanyRemoteDataSource>()),
  );

  getIt.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: getIt<JobRemoteDataSource>()),
  );

  getIt.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(remoteDataSource: getIt<CourseRemoteDataSource>()),
  );

  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: getIt<PostRemoteDataSource>()),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>()),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: getIt<NotificationRemoteDataSource>()),
  );

  getIt.registerLazySingleton<AdRepository>(
    () => AdRepositoryImpl(remoteDataSource: getIt<AdRemoteDataSource>()),
  );
}

void _registerUseCases() {
  getIt.registerLazySingleton<LoginUser>(
    () => LoginUser(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RegisterUser>(
    () => RegisterUser(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUser>(
    () => LogoutUser(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<CheckAuthStatus>(
    () => CheckAuthStatus(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetUserProfile>(
    () => GetUserProfile(getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<UpdateUserProfile>(
    () => UpdateUserProfile(getIt<ProfileRepository>()),
  );
}

void _registerBlocs() {
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUser: getIt<LoginUser>(),
      registerUser: getIt<RegisterUser>(),
      logoutUser: getIt<LogoutUser>(),
      checkAuthStatus: getIt<CheckAuthStatus>(),
      getCurrentUser: getIt<GetCurrentUser>(),
    ),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfile: getIt<GetUserProfile>(),
      updateUserProfile: getIt<UpdateUserProfile>(),
    ),
  );

  getIt.registerFactory<CompanyBloc>(
    () => CompanyBloc(repository: getIt<CompanyRepository>()),
  );

  getIt.registerFactory<JobBloc>(
    () => JobBloc(repository: getIt<JobRepository>()),
  );

  getIt.registerFactory<CourseBloc>(
    () => CourseBloc(repository: getIt<CourseRepository>()),
  );

  getIt.registerFactory<InstructorBloc>(
    () => InstructorBloc(repository: getIt<CourseRepository>()),
  );

  getIt.registerFactory<StudentBloc>(
    () => StudentBloc(repository: getIt<CourseRepository>()),
  );

  getIt.registerFactory<PostBloc>(
    () => PostBloc(repository: getIt<PostRepository>()),
  );

  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(repository: getIt<ChatRepository>()),
  );

  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(repository: getIt<NotificationRepository>()),
  );

  getIt.registerFactory<AdBloc>(
    () => AdBloc(repository: getIt<AdRepository>()),
  );
}

abstract class AuthService {
  Future<bool> isAuthenticated();
  Future<bool> isVisitorMode();
  Future<void> setVisitorMode(bool enabled);
  Future<UserRole> getCurrentUserRole();
}

class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._client);

  final SupabaseClient _client;
  static const String _visitorModeKey = 'visitor_mode';

  @override
  Future<bool> isAuthenticated() async {
    try {
      return _client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isVisitorMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_visitorModeKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setVisitorMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_visitorModeKey, enabled);
    } catch (_) {
      // Ignore errors
    }
  }

  @override
  Future<UserRole> getCurrentUserRole() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        final isVisitor = await isVisitorMode();
        return isVisitor ? UserRole.visitor : UserRole.visitor;
      }

      // Fetch user profile to get role
      final userId = session.user.id;
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && response['role'] != null) {
        return UserRole.fromString(response['role'] as String);
      }

      return UserRole.user;
    } catch (_) {
      return UserRole.visitor;
    }
  }
}
