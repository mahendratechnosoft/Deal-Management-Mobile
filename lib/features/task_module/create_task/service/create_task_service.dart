import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_task_update_model.dart';
import '../model/request_model.dart';

class CreateTaskService {
  final Dio dio;

  CreateTaskService(this.dio);

  Future<Response> createTask(CreateTaskRequest request) {
    return dio.post(
      ApiConstants.createTask,
      data: jsonEncode(request.toJson()),
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<Response> taskUpdate(TaskUpdateRequest request) {
    return dio.put(
      ApiConstants.taskUpdate,
      data: request.toJson(),
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<Response> getTask(String taskId) {
    return dio.get(
      "${ApiConstants.getPertucularTAsk}$taskId",
    );
  }

  Future<Response> deleteTask(String taskId) {
    return dio.delete('${ApiConstants.deleteTask}$taskId');
  }

  Future<Response> fetchAssigns(String value) async {
    final url = await _getAssignEndpoint(value);
    return dio.get(url);
  }

  Future<String> _getAssignEndpoint(String value) async {
    switch (value) {
      case 'Lead':
        return 'admin/getLeadNameAndIdWithConverted';

      case 'Customer':
        return 'admin/getCustomerListWithNameAndId';

      case 'Proforma':
        return 'admin/getProformaNumberAndId';

      case 'Proposal':
        return 'admin/getProposalNumberAndId';

      case 'Invoice':
        return 'admin/getInvoiceNumberAndId';

      default:
        throw ArgumentError('Invalid assign type: $value');
    }
  }
}
