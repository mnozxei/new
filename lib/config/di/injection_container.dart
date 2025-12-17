import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ads/data/datasources/ad_remote_data_source.dart';
import '../../features/ads/data/repositories/ad_repository_impl.dart';
import '../../features/ads/domain/repositories/ad_repository.dart';
import '../../features/ads/presentation/bloc/ad_bloc.dart';
import '../../features/ads/services/ad_injection_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/companies/data/datasources/company_remote_data_source.dart';
import '../../features/companies/data/repositories/company_repository_impl.dart';
import '../../features/companies/domain/repositories/company_repository.dart';
import '../../features/companies/presentation/bloc/company_bloc.dart';
import '../../features/courses/data/datasources/course_remote_data_source.dart';
import '../../features/courses/data/repositories/course_repository_impl.dart';
import '../../features/courses/domain/repositories/course_repository.dart';
import '../../features/courses/presentation/bloc/course_bloc.dart';
import '../../features/jobs/data/datasources/job_remote_data_source.dart';
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
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
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
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );
}

void _initProfile() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: sl()),
  );
}

void _initCompanies() {
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<CompanyBloc>(
    () => CompanyBloc(companyRepository: sl()),
  );
}

void _initJobs() {
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<JobBloc>(
    () => JobBloc(jobRepository: sl()),
  );
}

void _initCourses() {
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<CourseBloc>(
    () => CourseBloc(courseRepository: sl()),
  );
}

void _initPosts() {
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<PostBloc>(
    () => PostBloc(postRepository: sl()),
  );
}

void _initChat() {
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(chatRepository: sl()),
  );
}

void _initNotifications() {
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(notificationRepository: sl()),
  );
}

void _initAds() {
  sl.registerLazySingleton<AdRemoteDataSource>(
    () => AdRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<AdRepository>(
    () => AdRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AdInjectionService>(
    () => AdInjectionService(adRepository: sl()),
  );

  sl.registerFactory<AdBloc>(
    () => AdBloc(adRepository: sl()),
  );
}
