abstract class LeaveRequestEvent {
  const LeaveRequestEvent();
}

/// Fetch or refresh leave list for a viewType (MY_LEAVES, APPROVALS, ALL_LEAVES)
class FetchLeavesEvent extends LeaveRequestEvent {
  final String? viewType;
  final int page;
  final String? status;
  final String? search;
  final bool isRefresh;
  final bool isLoadMore;

  const FetchLeavesEvent({
    this.viewType,
    this.page = 0,
    this.status,
    this.search,
    this.isRefresh = false,
    this.isLoadMore = false,
  });
}

/// Change active tab (MY_LEAVES, APPROVALS, ALL_LEAVES)
class SwitchTabEvent extends LeaveRequestEvent {
  final String viewType;

  const SwitchTabEvent(this.viewType);
}

/// Filter leaves by status or search query
class FilterLeavesEvent extends LeaveRequestEvent {
  final String? status;
  final String? search;

  const FilterLeavesEvent({this.status, this.search});
}

/// Cancel a pending leave request
class CancelLeaveEvent extends LeaveRequestEvent {
  final String leaveRequestId;

  const CancelLeaveEvent(this.leaveRequestId);
}

/// Approve or Reject a leave request (Manager/Approver action)
class ProcessLeaveEvent extends LeaveRequestEvent {
  final String leaveRequestId;
  final String newStatus; // APPROVED or REJECTED
  final String? remarks;

  const ProcessLeaveEvent({
    required this.leaveRequestId,
    required this.newStatus,
    this.remarks,
  });
}

/// Load approvers & handover colleagues for Apply Leave screen
class LoadApplyFormDataEvent extends LeaveRequestEvent {
  const LoadApplyFormDataEvent();
}

/// Submit leave application
class SubmitLeaveApplicationEvent extends LeaveRequestEvent {
  final Map<String, dynamic> data;
  final String? localFilePath;
  final String? localFileName;
  final bool isEdit;
  final String? leaveRequestId;

  const SubmitLeaveApplicationEvent({
    required this.data,
    this.localFilePath,
    this.localFileName,
    this.isEdit = false,
    this.leaveRequestId,
  });
}
