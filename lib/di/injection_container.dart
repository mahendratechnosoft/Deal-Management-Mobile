import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/network/dio_client.dart';
import 'package:xpertbiz/features/auth/bloc/auth_bloc.dart';
import 'package:xpertbiz/features/auth/data/repo/auth_repository.dart';
import 'package:xpertbiz/features/auth/data/services/auth_api_service.dart';

final sl = GetIt.instance;

void init() {
  // Dio
  sl.registerLazySingleton<Dio>(() => DioClient.getDio());

  // Services
  sl.registerLazySingleton(() => AuthApiService(sl()));

  // Repository
  sl.registerLazySingleton(() => AuthRepository(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));
}
