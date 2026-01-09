
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/task_module/create_task/repo/create_task_repo.dart';
import 'create_task_event.dart';
import 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  final CreateTaskRepository repository;

  CreateTaskBloc(this.repository) : super(const CreateTaskState()) {
    on<RelatedChange>(_onRelatedChanged);
    on<PriorityChange>(_onPriorityChanged);
    on<AssigneeChange>(_onAssigneeChanged);
    on<FollowerChange>(_onFollowerChanged);
    on<TaskStartDateChanged>(_onStartDateChanged);
    on<TaskDueDateChanged>(_onDueDateChanged);
    on<AttachmentsChanged>(_onAttachmentsChanged);
    on<SubmitCreateTask>(_onSubmitTask);
    on<GetTaskEvent>(_getTask);
    on<UpdateTaskEvent>(_taskUpdate);
  }

  void _onRelatedChanged(RelatedChange event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(relatedTo: event.value));
  }

  void _onPriorityChanged(PriorityChange event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(priority: event.value));
  }

  void _onAssigneeChanged(AssigneeChange event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(assignee: event.value));
  }

  void _onFollowerChanged(FollowerChange event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(follower: event.value));
  }

  void _onStartDateChanged(
      TaskStartDateChanged event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(startDate: event.date));
  }

  void _onDueDateChanged(
      TaskDueDateChanged event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(dueDate: event.date));
  }

  void _onAttachmentsChanged(
      AttachmentsChanged event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(attachments: event.attachments));
  }

  Future<void> _onSubmitTask(
    SubmitCreateTask event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, success: false));
    try {
      await repository.createTask(event.request);

      emit(const CreateTaskState());
      emit(state.copyWith(
        isLoading: false,
        success: true,
        errorMessage: null,
      ));
    } on DioException catch (dioError) {
      final message = ApiError.getMessage(dioError);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: message,
        success: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Something went wrong. Please try again.",
        success: false,
      ));
    }
  }

  Future<void> _getTask(
    GetTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await repository.getPerTask(event.taskId);

      emit(state.copyWith(
        isLoading: false,
        getTaskModel: response,
      ));
    } on DioException catch (dioError) {
      final message = ApiError.getMessage(dioError);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: message,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Something went wrong",
      ));
    }
  }

  Future<void> _taskUpdate(
    UpdateTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await repository.taskUpdate(event.request);

      emit(state.copyWith(
        isLoading: false,
        taskUpdateModel: response,
        success: true,
      ));
      emit(const CreateTaskState());
    } on DioException catch (dioError) {
      final message = ApiError.getMessage(dioError);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: message,
        success: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        success: false,
        errorMessage: "Something went wrong",
      ));
    }
  }

 
}
