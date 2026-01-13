import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/task_module/create_task/repo/create_task_repo.dart';
import 'create_task_event.dart';
import 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  final CreateTaskRepository repository;
  Timer? _ticker;

  CreateTaskBloc(this.repository) : super(const CreateTaskState()) {
    on<TimerStatusEvent>(_getTimerStatus);
    on<StartTaskTimerEvent>(_onStartTimer);
    on<StopTaskTimerEvent>(_onStopTimer);
    on<TimerTickEvent>(_onTimerTick);

    // other existing events (unchanged)
    on<GetTaskEvent>(_getTask);
    on<LoadAssigneesEvent>(_loadAssignees);
    on<UpdateTaskEvent>(_taskUpdate);
    on<SubmitCreateTask>(_onSubmitTask);
    on<AssigneesDropDownEvent>(_assignDropdown);
    on<FollowerChange>(_onFollowerChanged);
    on<TaskStartDateChanged>(_onStartDateChanged);
    on<TaskDueDateChanged>(_onDueDateChanged);
    on<AttachmentsChanged>(_onAttachmentsChanged);
    on<FetchListEvent>(_fetchAssigne);
    on<RelatedChange>(_onRelatedChanged);
    on<PriorityChange>(_onPriorityChanged);
    on<DependsLelatedtoEvent>(_dependsRelatedto);
    on<TimerDetailsEvent>(_timeDetails);
  }

  // ================= TIMER STATUS (APP REOPEN RESUME) =================
  Future<void> _getTimerStatus(
    TimerStatusEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      final response = await repository.timeStatus(event.taskId);

      // 🔴 CASE: 204 or null → timer never started
      if (response == null) {
        _ticker?.cancel();

        emit(state.copyWith(
          checktimerStatus: null,
          isTimerRunning: false,
          elapsedSeconds: 0,
        ));

        log('ℹ️ No active timer (204)');
        return;
      }

      log('✅ Timer status: ${response.status}');

      // 🔴 ACTIVE timer → resume
      if (response.status == 'ACTIVE') {
        final startTime = response.startTime;
        final elapsed = DateTime.now().difference(startTime).inSeconds;

        _startTicker(startTime);

        emit(state.copyWith(
          checktimerStatus: response,
          isTimerRunning: true,
          elapsedSeconds: elapsed,
        ));
        return;
      }

      // 🔴 Timer exists but stopped
      _ticker?.cancel();

      emit(state.copyWith(
        checktimerStatus: response,
        isTimerRunning: false,
        elapsedSeconds: 0,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ================= START TIMER =================
  Future<void> _onStartTimer(
    StartTaskTimerEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    final res = await repository.startTime(event.taskId);

    final startTime = res.startTime;
    final elapsed = DateTime.now().difference(startTime).inSeconds;

    _startTicker(startTime);

    emit(state.copyWith(
      isTimerRunning: true,
      activeTaskLog: res,
      elapsedSeconds: elapsed,
    ));
  }

  // ================= STOP TIMER =================
  Future<void> _onStopTimer(
    StopTaskTimerEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    await repository.endTime(event.taskId, event.comment);
    _ticker?.cancel();
    emit(state.copyWith(
      isTimerRunning: false,
      activeTaskLog: null,
      elapsedSeconds: 0,
    ));
  }

  // ================= TICK EVENT =================
  void _onTimerTick(
    TimerTickEvent event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(
      elapsedSeconds: state.elapsedSeconds + 1,
    ));
  }

  // 🔴 CHANGE: Centralized ticker logic
  void _startTicker(DateTime startTime) {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTickEvent());
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  // ================= OTHER EVENTS (UNCHANGED) =================
  void _onRelatedChanged(RelatedChange e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(relatedTo: e.value));
  }

  void _onPriorityChanged(PriorityChange e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(priority: e.value));
  }

  void _dependsRelatedto(
      DependsLelatedtoEvent e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(assignee: e.value.id, relatedToId: e.value.name));
  }

  void _assignDropdown(
    AssigneesDropDownEvent e,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(assignIdValue: e.id, assignNameValue: e.name));
  }

  void _onFollowerChanged(FollowerChange e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(followerId: e.id, followerName: e.name));
  }

  void _onStartDateChanged(
      TaskStartDateChanged e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(startDate: e.date));
  }

  void _onDueDateChanged(TaskDueDateChanged e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(dueDate: e.date));
  }

  void _onAttachmentsChanged(
      AttachmentsChanged e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(attachments: e.attachments));
  }

  Future<void> _loadAssignees(
    LoadAssigneesEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isAssigneesLoading: true));
    final assignees = await repository.assignDropDown();
    emit(state.copyWith(
      assigneesList: assignees,
      isAssigneesLoading: false,
    ));
  }

  Future<void> _fetchAssigne(
    FetchListEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    // unchanged
  }

  Future<void> _onSubmitTask(
    SubmitCreateTask event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await repository.createTask(event.request);
      emit(state.copyWith(isSubmitting: false, taskCreated: true));
    } on DioException catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: ApiError.getMessage(e),
      ));
    }
  }

  Future<void> _getTask(
    GetTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final response = await repository.getPerTask(event.taskId);
    emit(state.copyWith(isLoading: false, getTaskModel: response));
  }

  Future<void> _taskUpdate(
    UpdateTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final response = await repository.taskUpdate(event.request);
    emit(state.copyWith(
      isSubmitting: false,
      taskUpdated: true,
      taskUpdateModel: response,
    ));
  }

  Future<void> _timeDetails(
    TimerDetailsEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      final res = await repository.timedetailsFetch(event.taskId);

      emit(state.copyWith(
        timeDetailsModel: res,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
