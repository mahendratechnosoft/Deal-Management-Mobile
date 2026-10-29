import 'package:xpertbiz/features/leave_request/data/models/leave_approver_model.dart';
import 'package:xpertbiz/features/leave_request/data/models/leave_request_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/employee_item_model.dart';

abstract class LeaveRequestState {
  const LeaveRequestState();
}

class LeaveRequestInitial extends LeaveRequestState {}

class LeaveListLoading extends LeaveRequestState {
  final String viewType;
  const LeaveListLoading({this.viewType = 'MY_LEAVES'});
}

class LeaveListLoaded extends LeaveRequestState {
  final List<LeaveRequestModel> leaves;
  final String currentViewType; // MY_LEAVES, APPROVALS, ALL_LEAVES
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool isLast;
  final bool isLoadingMore;
  final String? currentStatus;
  final String? currentSearch;
  final String? actionMessage;
  final bool isActionSuccess;

  const LeaveListLoaded({
    required this.leaves,
    required this.currentViewType,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
    this.isLoadingMore = false,
    this.currentStatus,
    this.currentSearch,
    this.actionMessage,
    this.isActionSuccess = false,
  });

  LeaveListLoaded copyWith({
    List<LeaveRequestModel>? leaves,
    String? currentViewType,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    bool? isLast,
    bool? isLoadingMore,
    String? currentStatus,
    String? currentSearch,
    String? actionMessage,
    bool? isActionSuccess,
  }) {
    return LeaveListLoaded(
      leaves: leaves ?? this.leaves,
      currentViewType: currentViewType ?? this.currentViewType,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      isLast: isLast ?? this.isLast,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentStatus: currentStatus ?? this.currentStatus,
      currentSearch: currentSearch ?? this.currentSearch,
      actionMessage: actionMessage,
      isActionSuccess: isActionSuccess ?? false,
    );
  }
}

class LeaveListError extends LeaveRequestState {
  final String message;
  final String viewType;

  const LeaveListError(this.message, {this.viewType = 'MY_LEAVES'});
}

/// Apply Leave Form States
class ApplyFormDependenciesLoading extends LeaveRequestState {
  const ApplyFormDependenciesLoading();
}

class ApplyFormDependenciesLoaded extends LeaveRequestState {
  final List<LeaveApproverModel> approvers;
  final List<EmployeeItemModel> handoverEmployees;

  const ApplyFormDependenciesLoaded({
    required this.approvers,
    required this.handoverEmployees,
  });
}

class ApplyFormSubmitting extends LeaveRequestState {
  const ApplyFormSubmitting();
}

class ApplyFormSuccess extends LeaveRequestState {
  final LeaveRequestModel createdLeave;
  final String message;

  const ApplyFormSuccess({
    required this.createdLeave,
    this.message = 'Leave applied successfully',
  });
}

class ApplyFormError extends LeaveRequestState {
  final String message;

  const ApplyFormError(this.message);
}
