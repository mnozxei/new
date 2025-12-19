import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final supabase = Supabase.instance.client;

  sl.registerLazySingleton<SupabaseClient>(() => supabase);

  _initAuth();
  _initProfile();
  _initCompanies();
  _initJobs();
  _initCourses();
  _initPosts();
  _initChat();
  _initNotifications();
  _initAds();
}

void _initAuth() {
  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      checkAuthStatus: sl(),
      getCurrentUser: sl(),
    ),
  );
}

void _initProfile() {
  // Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));

  // Bloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
    ),
  );
}

void _initCompanies() {
  // Data Source
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(supabase: sl()),
  );

  // Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );

  // Bloc
  sl.registerFactory<CompanyBloc>(
    () => CompanyBloc(repository: sl()),
  );
}

void _initJobs() {
  // Data Source
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(supabase: sl()),
  );

  // Repository
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl()),
  );

  // Bloc
  sl.registerFactory<JobBloc>(
    () => JobBloc(repository: sl()),
  );
}

void _initCourses() {
  // Data Source
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(remoteDataSource: sl()),
  );

  // Bloc
  sl.registerFactory<CourseBloc>(
    () => CourseBloc(repository: sl()),
  );
}

void _initPosts() {
  // Data Source
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );

  // Bloc
  sl.registerFactory<PostBloc>(
    () => PostBloc(repository: sl()),
  );
}

void _initChat() {
  // Data Source
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Bloc
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(repository: sl()),
  );
}

void _initNotifications() {
  // Data Source
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Bloc
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(repository: sl()),
  );
}

void _initAds() {
  // Data Source
  sl.registerLazySingleton<AdRemoteDataSource>(
    () => AdRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AdRepository>(
    () => AdRepositoryImpl(remoteDataSource: sl()),
  );

  // Service
  sl.registerLazySingleton<AdInjectionService>(
    () => AdInjectionService(adRepository: sl()),
  );

  // Bloc
  sl.registerFactory<AdBloc>(
    () => AdBloc(repository: sl()),
  );
}
