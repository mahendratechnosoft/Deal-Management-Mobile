import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/task_module/create_task/model/add_comment.dart';
import 'package:xpertbiz/features/task_module/create_task/repo/create_task_repo.dart';
import '../../../../core/widgtes/custom_dropdown.dart';
import 'create_task_event.dart';
import 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  final CreateTaskRepository repository;
  Timer? _ticker;

  CreateTaskBloc(this.repository) : super(const CreateTaskState()) {
    // Comment events
    on<LoadCommentsEvent>(_loadComments);
    on<AddCommentEvent>(_addComment);
    on<RefreshCommentsEvent>(_refreshComments);
    on<UpdatedStatusEvent>(_updateStatus);
    // Assignee and Follower events
    on<AddAssigneeEvent>(_addAssignee);
    on<AddFollowerEvent>(_addFollower);
    on<LoadTaskAssigneesEvent>(_loadTaskAssignees);
    on<LoadTaskFollowersEvent>(_loadTaskFollowers);

    // Timer events
    on<TimerStatusEvent>(_getTimerStatus);
    on<StartTaskTimerEvent>(_onStartTimer);
    on<StopTaskTimerEvent>(_onStopTimer);
    on<TimerTickEvent>(_onTimerTick);

    // Other existing events
    on<StatusEvent>(_statusDropdown);
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

    on<AddAssigneeLocal>((event, emit) {
      if (state.selectedAssignees.any((e) => e.id == event.item.id)) return;

      emit(state.copyWith(
        selectedAssignees: [
          ...state.selectedAssignees,
          event.item,
        ],
      ));
    });
    on<AddFollowerLocal>((event, emit) {
      if (state.selectedFollower.any((e) => e.id == event.item.id)) return;

      emit(state.copyWith(
        selectedFollower: [
          ...state.selectedFollower,
          event.item,
        ],
      ));
    });

    on<RemoveAssigneeLocal>((event, emit) {
      emit(state.copyWith(
        selectedAssignees:
            state.selectedAssignees.where((e) => e.id != event.id).toList(),
      ));
    });

    on<RemoveFollowerLocal>((event, emit) {
      emit(state.copyWith(
        selectedFollower:
            state.selectedFollower.where((e) => e.id != event.id).toList(),
      ));
    });
  }

  // ================= ASSIGNEE & FOLLOWER EVENTS =================
  Future<void> _addAssignee(
    AddAssigneeEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      isAddingAssignee: true,
      assigneeError: null,
    ));

    try {
      await repository.addAsignee(
        taskId: event.taskId,
        employeeIds: event.employeeIds,
      );

      // Refresh task assignees after adding
      add(LoadTaskAssigneesEvent(taskId: event.taskId));

      emit(state.copyWith(
        isAddingAssignee: false,
      ));
    } catch (e) {
      log('Add assignee error: $e');
      emit(state.copyWith(
        isAddingAssignee: false,
        assigneeError: e.toString(),
      ));
    }
  }

  Future<void> _addFollower(
    AddFollowerEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      isAddingFollower: true,
      followerError: null,
    ));

    try {
      await repository.addFollowers(
        taskId: event.taskId,
        employeeIds: event.employeeIds,
      );

      // Refresh task followers after adding
      add(LoadTaskFollowersEvent(taskId: event.taskId));

      emit(state.copyWith(
        isAddingFollower: false,
      ));
    } catch (e) {
      log('Add follower error: $e');
      emit(state.copyWith(
        isAddingFollower: false,
        followerError: e.toString(),
      ));
    }
  }

  Future<void> _loadTaskAssignees(
    LoadTaskAssigneesEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingTaskAssignees: true,
      assigneeError: null,
    ));

    try {
      final assignees = state.assigneesList;
      emit(state.copyWith(
        taskAssignees: assignees,
        isLoadingTaskAssignees: false,
      ));
    } catch (e) {
      log('Load task assignees error: $e');
      emit(state.copyWith(
        isLoadingTaskAssignees: false,
        assigneeError: e.toString(),
      ));
    }
  }

  Future<void> _loadTaskFollowers(
    LoadTaskFollowersEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingTaskFollowers: true,
      followerError: null,
    ));

    try {
      // Note: You need to implement this method in your repository
      // final followers = await repository.getTaskFollowers(event.taskId);
      // For now, using the assigneesList as placeholder
      final followers = state.assigneesList;

      emit(state.copyWith(
        taskFollowers: followers,
        isLoadingTaskFollowers: false,
      ));
    } catch (e) {
      log('Load task followers error: $e');
      emit(state.copyWith(
        isLoadingTaskFollowers: false,
        followerError: e.toString(),
      ));
    }
  }

  // ================= COMMENT EVENTS =================
  Future<void> _loadComments(
    LoadCommentsEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isLoadingComments: true, commentError: null));

    try {
      final response = await repository.getComment(event.taskId);
      emit(state.copyWith(
        comments: response.content,
        isLoadingComments: false,
      ));
    } catch (e) {
      log('Load comments error: $e');
      emit(state.copyWith(
        isLoadingComments: false,
        commentError: e.toString(),
      ));
    }
  }

  Future<void> _addComment(
    AddCommentEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isAddingComment: true, commentError: null));

    try {
      final request = AddCommentRequest(
        taskId: event.taskId,
        content: event.content,
        attachments: event.attachments,
      );

      await repository.addComment(request);

      // Refresh comments after adding
      add(RefreshCommentsEvent(taskId: event.taskId));

      emit(state.copyWith(isAddingComment: false));
    } catch (e) {
      log('Add comment error: $e');
      emit(state.copyWith(
        isAddingComment: false,
        commentError: e.toString(),
      ));
    }
  }

  Future<void> _refreshComments(
    RefreshCommentsEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      final response = await repository.getComment(event.taskId);
      emit(state.copyWith(comments: response.content));
    } catch (e) {
      log('Refresh comments error: $e');
    }
  }

  // ================= TIMER EVENTS =================
  Future<void> _getTimerStatus(
    TimerStatusEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      final response = await repository.timeStatus(event.taskId);

      if (response == null) {
        _ticker?.cancel();
        emit(state.copyWith(
          checktimerStatus: null,
          isTimerRunning: false,
          elapsedSeconds: 0,
        ));
        log('ℹ️ No active timer');
        return;
      }

      log('✅ Timer status: ${response.status}');

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

  void _onTimerTick(
    TimerTickEvent event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(
      elapsedSeconds: state.elapsedSeconds + 1,
    ));
  }

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

  // ================= OTHER EVENTS =================
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

  void _statusDropdown(StatusEvent e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(status: e.status));
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
    emit(state.copyWith(errorMessage: null, leadList: []));

    try {
      switch (event.value) {
        case 'Lead':
          final leads = await repository.fetchLead(event.value);
          emit(state.copyWith(leadList: leads));
          break;
        case 'Customer':
          final customers = await repository.fetchCustomer(event.value);
          emit(state.copyWith(customerList: customers));
          break;
        case 'Proposal':
          final proposals = await repository.fetchProposal(event.value);
          emit(state.copyWith(proposalList: proposals));
          break;
        case 'Proforma':
          final proformas = await repository.fetchProform(event.value);
          emit(state.copyWith(proformList: proformas));
          break;
        case 'Invoice':
          final invoices = await repository.fetchInvoice(event.value);
          emit(state.copyWith(invoiceList: invoices));
          break;
        default:
          emit(state.copyWith());
      }
    } catch (e) {
      log('FetchAssign error: $e');
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSubmitTask(
    SubmitCreateTask event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      taskCreated: true,
      errorMessage: null,
    ));

    try {
      await repository.createTask(event.request);
      emit(state.copyWith(
        taskCreated: false,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        taskCreated: false,
        errorMessage: ApiError.getMessage(e),
      ));
    }
  }

  Future<void> _getTask(
      GetTaskEvent event, Emitter<CreateTaskState> emit) async {
    emit(state.copyWith(isLoading: true));

    final response = await repository.getPerTask(event.taskId);
    final taskAssignees = response.task.assignedEmployees;
    final taskFollowers = response.task.followersEmployees;

    final selectedAssignees = taskAssignees
        .map((assignee) => DropdownItem(
              id: assignee.employeeId,
              name: assignee.name,
            ))
        .toList();

    final selectedFollowers = taskFollowers
        .map((follower) => DropdownItem(
              id: follower.employeeId,
              name: follower.name,
            ))
        .toList();

    emit(state.copyWith(
      isLoading: false,
      getTaskModel: response,
      canEdit: response.canEdit,
      selectedAssignees: selectedAssignees, // Set existing assignees
      selectedFollower: selectedFollowers, // Set existing followers
    ));
  }

  Future<void> _taskUpdate(
    UpdateTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      taskUpdated: true,
      errorMessage: null,
    ));

    try {
      final response = await repository.taskUpdate(event.request);

      // ✅ emit SUCCESS after API completes
      emit(state.copyWith(
        taskUpdated: false,
        taskUpdateModel: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        taskUpdated: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _timeDetails(
    TimerDetailsEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      final res = await repository.timedetailsFetch(event.taskId);
      emit(state.copyWith(timeDetailsModel: res));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _updateStatus(
    UpdatedStatusEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      emit(state.copyWith(taskUpdated: true, isLoading: true));
      await repository.updatedStatus(
          taskId: event.taskId, status: event.status);
      emit(state.copyWith(updatedStatus: false, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
