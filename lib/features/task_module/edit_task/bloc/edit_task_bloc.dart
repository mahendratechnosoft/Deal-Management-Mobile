// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:xpertbiz/core/network/api_error.dart';
// import 'package:xpertbiz/features/task_module/edit_task/bloc/edit_task_event.dart';
// import 'package:xpertbiz/features/task_module/edit_task/bloc/edit_task_state.dart';
// import 'package:xpertbiz/features/task_module/edit_task/repo/edit_task_repo.dart';

// class EditTaskBloc extends Bloc<EditTaskEvent, EditTaskState> {
//   final GetTaskPerRepo repository;
//   EditTaskBloc(this.repository) : super(IntitialState()) {
//     on<GetTaskEvent>(_getTask);
//   }

//   Future<void> _getTask(GetTaskEvent event, Emitter<EditTaskState> emit) async {
//     emit(LoadingState());
//     try {
//       final response = await repository.getPerTask(event.taskId);
//       emit(SuccessResState(getTaskModel: response));
//     } on DioException catch (dioError) {
//       final message = ApiError.getMessage(dioError);
//       log(message);
//       emit(EditTaskError(error: message));
//     } catch (error) {
//       emit(EditTaskError(
//         error: "Something went wrong. Please try again.",
//       ));
//     }
//   }
// }
