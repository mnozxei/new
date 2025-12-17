import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/storage_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../routes/app_router.dart';

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
}

void _registerDataSources() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
}

void _registerRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
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
}

class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<bool> isAuthenticated() async {
    return _client.auth.currentSession != null;
  }
}
