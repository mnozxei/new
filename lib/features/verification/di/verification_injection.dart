import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/verification_remote_datasource.dart';
import '../data/repositories/verification_repository_impl.dart';
import '../domain/repositories/verification_repository.dart';
import '../presentation/bloc/verification_bloc.dart';

/// Register verification feature dependencies
void registerVerificationDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Repositories
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(sl<VerificationRemoteDataSource>()),
  );

  // BLoC
  sl.registerFactory<VerificationBloc>(
    () => VerificationBloc(repository: sl<VerificationRepository>()),
  );
}
