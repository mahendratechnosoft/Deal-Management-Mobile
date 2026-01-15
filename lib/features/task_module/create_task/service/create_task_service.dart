import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/features/task_module/create_task/model/add_comment.dart';
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

  Future<Response> fetchRelatedTO(String value) async {
    final url = await _getAssignEndpoint(value);
    return dio.get(url);
  }

  Future<String> _getAssignEndpoint(String value) async {
    switch (value) {
      case 'Lead':
        return ApiConstants.leadUrl;

      case 'Customer':
        return ApiConstants.customerUrl;

      case 'Proforma':
        return ApiConstants.proformaUrl;

      case 'Proposal':
        return ApiConstants.proposalUrl;

      case 'Invoice':
        return ApiConstants.invoiceUrl;

      default:
        throw ArgumentError('Invalid assign type: $value');
    }
  }

  Future<Response> fetchAssignsDropDown() async {
    return dio.get(
      ApiConstants.assignUrl,
    );
  }

  Future<Response> startTaskTimer(String taskId) {
    return dio.post(
      ApiConstants.timerStartUrl,
      data: {
        "taskId": taskId,
      },
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<Response> stopTaskTimer(String taskId, String note) async {
    var pay = {"taskId": taskId, "endNote": note};
    return await dio.post(
      ApiConstants.timerStopUrl,
      data: json.encode(pay),
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<Response> checkTimerStatus(String taskId) {
    return dio.get(
      "${ApiConstants.activeStuseUrl}/$taskId",
    );
  }

  Future<Response> timedetailsFetch(String taskId) {
    return dio.get(
      "${ApiConstants.timeLogUrl}/$taskId",
    );
  }

  Future<Response> addComment(AddCommentRequest request) {
    return dio.post(
      ApiConstants.addCommentUrl,
      data: jsonEncode(request.toJson()),
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<Response> getComment(String taskId) async {
    return dio.get(
      "${ApiConstants.getCommentUrl}/$taskId",
    );
  }

  Future<Response> addAssignee({
    required String taskId,
    required List<String> employeeIds,
  }) {
    return dio.put(
      '${ApiConstants.addAssignees}/$taskId',
      data: employeeIds,
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<Response> addFollower({
    required String taskId,
    required List<String> employeeIds,
  }) {
    return dio.put(
      '${ApiConstants.addFollowers}/$taskId',
      data: employeeIds,
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<Response> updateStatus({
    required String taskId,
    required String status,
  }) {
    return dio.put(
      '${ApiConstants.updateStatusUrl}/$taskId/$status',
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }
}
