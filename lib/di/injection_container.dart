import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/network/dio_client.dart';
import 'package:xpertbiz/features/auth/bloc/auth_bloc.dart';
import 'package:xpertbiz/features/auth/data/repo/auth_repository.dart';
import 'package:xpertbiz/features/auth/data/services/auth_api_service.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/repo/create_task_repo.dart';
import 'package:xpertbiz/features/task_module/create_task/service/create_task_service.dart';
import 'package:xpertbiz/features/task_module/task/bloc/task_bloc.dart';
import 'package:xpertbiz/features/task_module/task/data/repo/task_repo.dart';
import 'package:xpertbiz/features/task_module/task/data/service/task_service.dart';
import 'package:xpertbiz/features/timesheet/block/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/data/repo/repo.dart';
import 'package:xpertbiz/features/timesheet/data/service/service.dart';

import '../features/task_module/task_deatils/bloc/bloc.dart';
import '../features/task_module/task_deatils/repo/repo.dart';
import '../features/task_module/task_deatils/service/service.dart';

final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton<Dio>(() => DioClient.getDio());

  sl.registerLazySingleton(() => AuthApiService(sl()));
  sl.registerLazySingleton(() => TaskApiService(sl()));
  sl.registerLazySingleton(() => CreateTaskService(sl()));
  sl.registerLazySingleton(() => CommentApiService(sl()));
  sl.registerLazySingleton(() => TimesheetService(sl()));

  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton(() => TaskRepository(sl()));
  sl.registerLazySingleton(() => CreateTaskRepository(sl()));
  sl.registerLazySingleton(() => CommentRepository(sl()));
  sl.registerLazySingleton(() => TimeSheetRepository(sl()));

  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => TaskBloc(sl()));
  sl.registerFactory(() => CreateTaskBloc(sl()));
  sl.registerFactory(() => CommentBloc(sl()));
  sl.registerFactory(() => TimeSheetBloc(sl()));
}
