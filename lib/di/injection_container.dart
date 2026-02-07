import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/network/dio_client.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_bloc.dart';
import 'package:xpertbiz/features/Lead/data/service/service.dart';
import 'package:xpertbiz/features/auth/bloc/auth_bloc.dart';
import 'package:xpertbiz/features/auth/data/repo/auth_repository.dart';
import 'package:xpertbiz/features/auth/data/services/auth_api_service.dart';
import 'package:xpertbiz/features/customers/bloc/customer_bloc.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/create_customer_bloc.dart';
import 'package:xpertbiz/features/customers/data/repo.dart';
import 'package:xpertbiz/features/customers/data/service.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/repo/create_task_repo.dart';
import 'package:xpertbiz/features/task_module/create_task/service/create_task_service.dart';
import 'package:xpertbiz/features/task_module/task/bloc/task_bloc.dart';
import 'package:xpertbiz/features/task_module/task/data/repo/task_repo.dart';
import 'package:xpertbiz/features/task_module/task/data/service/task_service.dart';
import 'package:xpertbiz/features/timesheet/block/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/bloc.dart';
import 'package:xpertbiz/features/timesheet/data/repo/repo.dart';
import 'package:xpertbiz/features/timesheet/data/service/service.dart';

import '../features/Lead/data/repo/repo.dart';
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
  sl.registerLazySingleton(() => LeadService(sl()));
  sl.registerLazySingleton(() => CustomerService(sl()));

  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton(() => TaskRepository(sl()));
  sl.registerLazySingleton(() => CreateTaskRepository(sl()));
  sl.registerLazySingleton(() => CommentRepository(sl()));
  sl.registerLazySingleton(() => TimeSheetRepository(sl()));
  sl.registerLazySingleton(() => LeadRepository(sl()));
  sl.registerLazySingleton(() => CustomerRepository(sl()));

  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => TaskBloc(sl()));
  sl.registerFactory(() => CreateTaskBloc(sl()));
  sl.registerFactory(() => CommentBloc(sl()));
  sl.registerFactory(() => TimeSheetBloc(sl()));
  sl.registerFactory(() => LeadBloc(sl()));
  sl.registerFactory(() => CreateLeadBloc(sl()));
  sl.registerFactory(() => CustomerBloc(sl()));
  sl.registerFactory(() => CreateCustomerBloc(sl()));
  sl.registerFactory(() => CheckInBloc(sl()));
}
