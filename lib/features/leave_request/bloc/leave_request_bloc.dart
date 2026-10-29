import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_event.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_state.dart';
import 'package:xpertbiz/features/leave_request/data/models/leave_request_model.dart';
import 'package:xpertbiz/features/leave_request/data/repositories/leave_request_repository.dart';

class LeaveRequestBloc extends Bloc<LeaveRequestEvent, LeaveRequestState> {
  final LeaveRequestRepository repository;

  String _currentViewType = 'MY_LEAVES';
  String? _currentStatus;
  String? _currentSearch;

  LeaveRequestBloc(this.repository) : super(LeaveRequestInitial()) {
    on<FetchLeavesEvent>(_onFetchLeaves);
    on<SwitchTabEvent>(_onSwitchTab);
    on<FilterLeavesEvent>(_onFilterLeaves);
    on<CancelLeaveEvent>(_onCancelLeave);
    on<ProcessLeaveEvent>(_onProcessLeave);
    on<LoadApplyFormDataEvent>(_onLoadApplyFormData);
    on<SubmitLeaveApplicationEvent>(_onSubmitLeaveApplication);
  }

  Future<void> _onFetchLeaves(
    FetchLeavesEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    final viewType = event.viewType ?? _currentViewType;
    _currentViewType = viewType;
    if (event.status != null) _currentStatus = event.status;
    if (event.search != null) _currentSearch = event.search;

    final currentState = state;
    final isLoadMore = event.isLoadMore && currentState is LeaveListLoaded;

    if (isLoadMore) {
      if (currentState.isLast || currentState.isLoadingMore) return;
      emit(currentState.copyWith(isLoadingMore: true));
    } else if (!event.isRefresh) {
      emit(LeaveListLoading(viewType: viewType));
    }

    try {
      final pageToFetch = isLoadMore ? (currentState.currentPage + 1) : event.page;
      final response = await repository.getAllLeaves(
        page: pageToFetch,
        size: 10,
        viewType: viewType,
        status: _currentStatus,
        search: _currentSearch,
      );

      final List<LeaveRequestModel> updatedLeaves = isLoadMore
          ? [...currentState.leaves, ...response.content]
          : response.content;

      emit(LeaveListLoaded(
        leaves: updatedLeaves,
        currentViewType: viewType,
        currentPage: response.pageNumber,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
        isLast: response.isLast || response.pageNumber >= response.totalPages - 1,
        isLoadingMore: false,
        currentStatus: _currentStatus,
        currentSearch: _currentSearch,
      ));
    } catch (e) {
      log('❌ [LeaveRequestBloc._onFetchLeaves] Error: $e');
      if (isLoadMore) {
        emit(currentState.copyWith(isLoadingMore: false));
      } else {
        emit(LeaveListError(e.toString().replaceAll('Exception: ', ''), viewType: viewType));
      }
    }
  }

  Future<void> _onSwitchTab(
    SwitchTabEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    _currentViewType = event.viewType;
    _currentStatus = null;
    _currentSearch = null;
    add(FetchLeavesEvent(viewType: event.viewType, page: 0));
  }

  Future<void> _onFilterLeaves(
    FilterLeavesEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    _currentStatus = event.status;
    _currentSearch = event.search;
    add(FetchLeavesEvent(
      viewType: _currentViewType,
      page: 0,
      status: _currentStatus,
      search: _currentSearch,
    ));
  }

  Future<void> _onCancelLeave(
    CancelLeaveEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    try {
      final success = await repository.cancelLeave(event.leaveRequestId);
      if (success) {
        if (state is LeaveListLoaded) {
          final loaded = state as LeaveListLoaded;
          emit(loaded.copyWith(
            actionMessage: 'Leave request cancelled successfully',
            isActionSuccess: true,
          ));
        }
        add(FetchLeavesEvent(viewType: _currentViewType, page: 0, isRefresh: true));
      }
    } catch (e) {
      log('❌ [LeaveRequestBloc._onCancelLeave] Error: $e');
      if (state is LeaveListLoaded) {
        final loaded = state as LeaveListLoaded;
        emit(loaded.copyWith(
          actionMessage: 'Failed to cancel: ${e.toString().replaceAll('Exception: ', '')}',
          isActionSuccess: false,
        ));
      }
    }
  }

  Future<void> _onProcessLeave(
    ProcessLeaveEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    try {
      final success = await repository.processLeaveRequest(
        event.leaveRequestId,
        newStatus: event.newStatus,
        remarks: event.remarks,
      );
      if (success) {
        final action = event.newStatus.toUpperCase() == 'APPROVED' ? 'approved' : 'rejected';
        if (state is LeaveListLoaded) {
          final loaded = state as LeaveListLoaded;
          emit(loaded.copyWith(
            actionMessage: 'Leave request $action successfully',
            isActionSuccess: true,
          ));
        }
        add(FetchLeavesEvent(viewType: _currentViewType, page: 0, isRefresh: true));
      }
    } catch (e) {
      log('❌ [LeaveRequestBloc._onProcessLeave] Error: $e');
      if (state is LeaveListLoaded) {
        final loaded = state as LeaveListLoaded;
        emit(loaded.copyWith(
          actionMessage: 'Failed to process: ${e.toString().replaceAll('Exception: ', '')}',
          isActionSuccess: false,
        ));
      }
    }
  }

  Future<void> _onLoadApplyFormData(
    LoadApplyFormDataEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(const ApplyFormDependenciesLoading());
    try {
      final results = await Future.wait([
        repository.getLeaveApproversDropdown(),
        repository.getHandoverEmployees(),
      ]);

      emit(ApplyFormDependenciesLoaded(
        approvers: results[0] as dynamic,
        handoverEmployees: results[1] as dynamic,
      ));
    } catch (e) {
      log('❌ [LeaveRequestBloc._onLoadApplyFormData] Error: $e');
      emit(ApplyFormError('Failed to load form data: $e'));
    }
  }

  Future<void> _onSubmitLeaveApplication(
    SubmitLeaveApplicationEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(const ApplyFormSubmitting());
    try {
      final payload = Map<String, dynamic>.from(event.data);

      if (event.localFilePath != null && event.localFileName != null) {
        final uploadedFileName = await repository.uploadAttachment(
          event.localFilePath!,
          event.localFileName!,
        );
        if (uploadedFileName != null) {
          payload['attachedFileUrl'] = uploadedFileName;
        }
      }

      LeaveRequestModel resultLeave;
      if (event.isEdit && event.leaveRequestId != null) {
        resultLeave = await repository.updateLeaveRequest(
          event.leaveRequestId!,
          payload,
        );
      } else {
        resultLeave = await repository.applyForLeave(payload);
      }

      emit(ApplyFormSuccess(
        createdLeave: resultLeave,
        message: event.isEdit
            ? 'Leave request updated successfully'
            : 'Leave application submitted successfully',
      ));
    } catch (e) {
      log('❌ [LeaveRequestBloc._onSubmitLeaveApplication] Error: $e');
      emit(ApplyFormError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
