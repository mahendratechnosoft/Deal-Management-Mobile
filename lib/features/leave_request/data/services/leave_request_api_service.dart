import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';

class LeaveRequestApiService {
  final Dio dio;

  LeaveRequestApiService(this.dio);

  /// Fetches paginated leave requests by viewType (MY_LEAVES, APPROVALS, ALL_LEAVES)
  Future<Response> getAllLeaves({
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
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'viewType': viewType,
    };

    if (status != null && status.isNotEmpty && status != 'ALL') {
      queryParams['status'] = status;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (leaveType != null && leaveType.isNotEmpty) {
      queryParams['leaveType'] = leaveType;
    }
    if (targetEmpId != null && targetEmpId.isNotEmpty) {
      queryParams['targetEmpId'] = targetEmpId;
    }

    log('📤 [LeaveRequestApiService] GET ${ApiConstants.getAllLeavesUrl} params: $queryParams');
    return await dio.get(
      ApiConstants.getAllLeavesUrl,
      queryParameters: queryParams,
    );
  }

  /// Submits a new leave request application
  Future<Response> applyForLeave(Map<String, dynamic> data) async {
    log('📤 [LeaveRequestApiService] POST ${ApiConstants.applyForLeaveUrl} payload: $data');
    return await dio.post(
      ApiConstants.applyForLeaveUrl,
      data: data,
    );
  }

  /// Updates an existing leave request application
  Future<Response> updateLeaveRequest(
    String leaveRequestId,
    Map<String, dynamic> data,
  ) async {
    final url = '${ApiConstants.updateLeaveUrl}/$leaveRequestId';
    log('📤 [LeaveRequestApiService] PUT $url payload: $data');
    return await dio.put(url, data: data);
  }

  /// Cancels an existing pending leave request
  Future<Response> cancelLeave(String leaveRequestId) async {
    final url = '${ApiConstants.cancelLeaveUrl}/$leaveRequestId';
    log('📤 [LeaveRequestApiService] PUT $url');
    return await dio.put(url);
  }

  /// Approves or rejects a pending leave request (by approver/manager)
  Future<Response> processLeaveRequest(
    String leaveRequestId, {
    required String newStatus,
    String? remarks,
  }) async {
    final url = '${ApiConstants.processLeaveUrl}/$leaveRequestId';
    final payload = <String, dynamic>{
      'newStatus': newStatus,
      if (remarks != null && remarks.trim().isNotEmpty)
        'remarks': remarks.trim(),
    };
    log('📤 [LeaveRequestApiService] PUT $url payload: $payload');
    return await dio.put(
      url,
      data: payload,
    );
  }

  /// Gets single leave request by ID
  Future<Response> getLeaveRequestById(String leaveRequestId) async {
    final url = '${ApiConstants.getLeaveByIdUrl}/$leaveRequestId';
    log('📤 [LeaveRequestApiService] GET $url');
    return await dio.get(url);
  }

  /// Gets dropdown list of eligible approvers
  Future<Response> getLeaveApproversDropdown() async {
    log('📤 [LeaveRequestApiService] GET ${ApiConstants.getLeaveApproversUrl}');
    return await dio.get(ApiConstants.getLeaveApproversUrl);
  }

  /// Gets list of colleagues for handover selection (excluding current user)
  Future<Response> getEmployeeNameAndId({bool excludeMe = true}) async {
    log('📤 [LeaveRequestApiService] GET ${ApiConstants.assignUrl}?excludeMe=$excludeMe');
    return await dio.get(
      ApiConstants.assignUrl,
      queryParameters: {'excludeMe': excludeMe},
    );
  }

  /// Uploads media/image for leave request attachment via media/{category}/upload
  Future<String?> uploadMediaFile(
    String filePath,
    String fileName, {
    String category = 'image',
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}media/$category/upload';
      log('📤 [LeaveRequestApiService.uploadMediaFile] POST $url (file: $fileName)');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dio.post(
        url,
        data: formData,
      );

      log('📥 [LeaveRequestApiService.uploadMediaFile] Status ${response.statusCode}: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          final data = response.data as Map;
          return data['fileName']?.toString() ??
              data['data']?['fileName']?.toString() ??
              data['previewUrl']?.toString() ??
              data['url']?.toString();
        } else if (response.data is String) {
          return response.data.toString();
        }
      }
    } catch (e) {
      log('⚠️ Error uploading media file: $e');
    }
    return null;
  }
}
