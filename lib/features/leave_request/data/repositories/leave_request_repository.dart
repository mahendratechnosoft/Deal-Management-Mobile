import 'dart:developer';
import 'package:xpertbiz/features/leave_request/data/models/leave_approver_model.dart';
import 'package:xpertbiz/features/leave_request/data/models/leave_request_model.dart';
import 'package:xpertbiz/features/leave_request/data/services/leave_request_api_service.dart';
import 'package:xpertbiz/features/timesheet/data/model/employee_item_model.dart';

class LeaveRequestRepository {
  final LeaveRequestApiService apiService;

  LeaveRequestRepository(this.apiService);

  /// Fetches paginated leave requests list
  Future<LeavePageResponse> getAllLeaves({
    int page = 0,
    int size = 10,
    required String viewType,
    String? status,
    String? search,
    String? startDate,
    String? endDate,
    String? leaveType,
    String? targetEmpId,
  }) async {
    try {
      final response = await apiService.getAllLeaves(
        page: page,
        size: size,
        viewType: viewType,
        status: status,
        search: search,
        startDate: startDate,
        endDate: endDate,
        leaveType: leaveType,
        targetEmpId: targetEmpId,
      );

      if (response.statusCode == 200 && response.data != null) {
        return LeavePageResponse.fromJson(response.data);
      }
      throw Exception('Failed to load leave requests (${response.statusCode})');
    } catch (e) {
      log('❌ [LeaveRequestRepository.getAllLeaves] Error: $e');
      rethrow;
    }
  }

  /// Submits leave application
  Future<LeaveRequestModel> applyForLeave(Map<String, dynamic> data) async {
    try {
      final response = await apiService.applyForLeave(data);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return LeaveRequestModel.fromJson(response.data);
        }
      }
      throw Exception('Failed to apply for leave (${response.statusCode})');
    } catch (e) {
      log('❌ [LeaveRequestRepository.applyForLeave] Error: $e');
      rethrow;
    }
  }

  /// Updates existing leave application
  Future<LeaveRequestModel> updateLeaveRequest(
    String leaveRequestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiService.updateLeaveRequest(leaveRequestId, data);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return LeaveRequestModel.fromJson(response.data);
        }
      }
      throw Exception('Failed to update leave (${response.statusCode})');
    } catch (e) {
      log('❌ [LeaveRequestRepository.updateLeaveRequest] Error: $e');
      rethrow;
    }
  }

  /// Cancels pending leave request
  Future<bool> cancelLeave(String leaveRequestId) async {
    try {
      final response = await apiService.cancelLeave(leaveRequestId);
      return response.statusCode == 200;
    } catch (e) {
      log('❌ [LeaveRequestRepository.cancelLeave] Error: $e');
      rethrow;
    }
  }

  /// Approves or rejects a leave request
  Future<bool> processLeaveRequest(
    String leaveRequestId, {
    required String newStatus,
    String? remarks,
  }) async {
    try {
      final response = await apiService.processLeaveRequest(
        leaveRequestId,
        newStatus: newStatus,
        remarks: remarks,
      );
      return response.statusCode == 200;
    } catch (e) {
      log('❌ [LeaveRequestRepository.processLeaveRequest] Error: $e');
      rethrow;
    }
  }

  /// Fetches leave request details
  Future<LeaveRequestModel> getLeaveRequestById(String leaveRequestId) async {
    try {
      final response = await apiService.getLeaveRequestById(leaveRequestId);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return LeaveRequestModel.fromJson(response.data);
      }
      throw Exception('Failed to fetch leave request details');
    } catch (e) {
      log('❌ [LeaveRequestRepository.getLeaveRequestById] Error: $e');
      rethrow;
    }
  }

  /// Fetches approver candidates
  Future<List<LeaveApproverModel>> getLeaveApproversDropdown() async {
    try {
      final response = await apiService.getLeaveApproversDropdown();
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => LeaveApproverModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ [LeaveRequestRepository.getLeaveApproversDropdown] Error: $e');
      return [];
    }
  }

  /// Fetches colleagues for handover (excludes current user)
  Future<List<EmployeeItemModel>> getHandoverEmployees() async {
    try {
      final response = await apiService.getEmployeeNameAndId(excludeMe: true);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => EmployeeItemModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ [LeaveRequestRepository.getHandoverEmployees] Error: $e');
      return [];
    }
  }

  /// Uploads attachment file if provided (defaults to 'image' for media/image/upload)
  Future<String?> uploadAttachment(
    String filePath,
    String fileName, {
    String category = 'image',
  }) async {
    return await apiService.uploadMediaFile(filePath, fileName, category: category);
  }
}
