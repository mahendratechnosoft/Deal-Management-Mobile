import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/network/dio_client.dart';
import 'package:xpertbiz/features/auth/bloc/auth_bloc.dart';
import 'package:xpertbiz/features/auth/data/repo/auth_repository.dart';
import 'package:xpertbiz/features/auth/data/services/auth_api_service.dart';
import 'package:xpertbiz/features/task/bloc/task_bloc.dart';
import 'package:xpertbiz/features/task/data/repo/task_repo.dart';
import 'package:xpertbiz/features/task/data/service/task_service.dart';

final sl = GetIt.instance;

void init() {
  // Dio
  sl.registerLazySingleton<Dio>(() => DioClient.getDio());

  // Services
  sl.registerLazySingleton(() => AuthApiService(sl()));
  sl.registerLazySingleton(() => TaskApiService(sl()));

  // Repository
  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton(() => TaskRepository(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => TaskBloc(sl()));
}
