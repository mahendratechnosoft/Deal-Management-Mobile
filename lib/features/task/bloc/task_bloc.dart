import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/task/bloc/task_event.dart';
import 'package:xpertbiz/features/task/bloc/task_state.dart';
import 'package:xpertbiz/features/task/data/repo/task_repo.dart';
import '../data/model/task_list_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskListState> {
  final TaskRepository repository;

  static const int pageSize = 10;

  TaskBloc(this.repository) : super(const TaskListInitial()) {
    on<FetchTasks>(_fetchTasks);
    on<UpdateSearch>(_updateSearch);
    on<UpdateStatus>(_updateStatus);
    on<UpdatePriority>(_updatePriority);

    /// initial load
    add(const FetchTasks());
  }

  /// ==========================
  /// FETCH TASKS (pagination + refresh)
  /// ==========================
  Future<void> _fetchTasks(
    FetchTasks event,
    Emitter<TaskListState> emit,
  ) async {
    try {
      if (state is TaskListLoading) return;

      int page = 0;
      List<TaskList> tasks = [];
      TaskFilter filter = const TaskFilter();

      if (state is TaskListSuccess) {
        final s = state as TaskListSuccess;

        // Stop loading if reached max
        if (s.hasReachedMax && event.isLoadMore) return;

        page = event.isLoadMore ? s.page + 1 : 0;
        tasks = event.isLoadMore ? s.tasks : []; // reset on refresh
        filter = s.filter;
      }

      // Show loading only on refresh / initial load
      if (!event.isLoadMore) emit(const TaskListLoading());

      final response = await repository.fetchTasks(page: page, size: pageSize);

      final newTasks = response.taskList;

      emit(TaskListSuccess(
        tasks: [...tasks, ...newTasks],
        filter: filter,
        page: page,
        hasReachedMax: newTasks.length < pageSize,
      ));
    } on DioException catch (e) {
      emit(TaskFailure(ApiError.getMessage(e)));
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  /// ==========================
  /// UPDATE SEARCH (reset page)
  /// ==========================
  void _updateSearch(UpdateSearch event, Emitter<TaskListState> emit) async {
    if (state is TaskListSuccess) {
      final s = state as TaskListSuccess;

      emit(const TaskListLoading());

      try {
        final response = await repository.fetchTasks(page: 0, size: pageSize);

        emit(TaskListSuccess(
          tasks: response.taskList,
          filter: s.filter.copyWith(search: event.value),
          page: 0,
          hasReachedMax: response.taskList.length < pageSize,
        ));
      } catch (e) {
        emit(TaskFailure(e.toString()));
      }
    }
  }

  /// ==========================
  /// UPDATE STATUS FILTER (reset page)
  /// ==========================
  void _updateStatus(UpdateStatus event, Emitter<TaskListState> emit) async {
    if (state is TaskListSuccess) {
      final s = state as TaskListSuccess;

      emit(const TaskListLoading());

      try {
        final response = await repository.fetchTasks(page: 0, size: pageSize);

        emit(TaskListSuccess(
          tasks: response.taskList,
          filter: s.filter.copyWith(status: event.value),
          page: 0,
          hasReachedMax: response.taskList.length < pageSize,
        ));
      } catch (e) {
        emit(TaskFailure(e.toString()));
      }
    }
  }

  /// ==========================
  /// UPDATE PRIORITY FILTER (reset page)
  /// ==========================
  void _updatePriority(
      UpdatePriority event, Emitter<TaskListState> emit) async {
    if (state is TaskListSuccess) {
      final s = state as TaskListSuccess;

      emit(const TaskListLoading());

      try {
        final response = await repository.fetchTasks(page: 0, size: pageSize);

        emit(TaskListSuccess(
          tasks: response.taskList,
          filter: s.filter.copyWith(priority: event.value),
          page: 0,
          hasReachedMax: response.taskList.length < pageSize,
        ));
      } catch (e) {
        emit(TaskFailure(e.toString()));
      }
    }
  }
}
