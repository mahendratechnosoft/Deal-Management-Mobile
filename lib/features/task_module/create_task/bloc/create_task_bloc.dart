import 'dart:developer';
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
    on<FetchAssignEvent>(_fetchAssigne);
    on<UpdateTaskEvent>(_taskUpdate);
  }

  void _onRelatedChanged(RelatedChange e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(relatedTo: e.value));
  }

  void _onPriorityChanged(PriorityChange e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(priority: e.value));
  }

  void _onAssigneeChanged(AssigneeChange e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(assignee: e.value));
  }

  void _onFollowerChanged(FollowerChange e, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(follower: e.value));
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

  // ---------------- FETCH ASSIGNE ----------------
  Future<void> _fetchAssigne(
    FetchAssignEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, leadList: []));

    try {
      switch (event.value) {
        case 'Lead':
          final leads = await repository.fetchLead(event.value);
          emit(state.copyWith(
            isLoading: false,
            leadList: leads,
          ));
          break;

        case 'Customer':
          final customers = await repository.fetchCustomer(event.value);
          emit(state.copyWith(
            isLoading: false,
            customerList: customers,
          ));
          break;

        case 'Proposal':
          final proposals = await repository.fetchProposal(event.value);
          emit(state.copyWith(
            isLoading: false,
            proposalList: proposals,
          ));
          break;

        case 'Proforma':
          final proformas = await repository.fetchProform(event.value);
          emit(state.copyWith(
            isLoading: false,
            proformList: proformas,
          ));
          break;

        case 'Invoice':
          final invoices = await repository.fetchInvoice(event.value);
          emit(state.copyWith(
            isLoading: false,
            invoiceList: invoices,
          ));
          break;

        default:
          emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      log('FetchAssign error: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ---------------- SUBMIT TASK ----------------
  Future<void> _onSubmitTask(
    SubmitCreateTask event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      isSubmitting: true,
      taskCreated: false,
      errorMessage: null,
    ));

    try {
      await repository.createTask(event.request);

      emit(state.copyWith(
        isSubmitting: false,
        taskCreated: true,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: ApiError.getMessage(e),
      ));
    }
  }

  // ---------------- GET TASK ----------------
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
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ---------------- UPDATE TASK ----------------
  Future<void> _taskUpdate(
    UpdateTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    emit(state.copyWith(
      isSubmitting: true,
      taskUpdated: false,
      errorMessage: null,
    ));

    try {
      final response = await repository.taskUpdate(event.request);

      emit(state.copyWith(
        isSubmitting: false,
        taskUpdated: true,
        taskUpdateModel: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
