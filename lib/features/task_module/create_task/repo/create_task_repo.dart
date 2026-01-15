import 'dart:developer';

import 'package:xpertbiz/features/task_module/create_task/model/add_comment.dart';
import 'package:xpertbiz/features/task_module/create_task/model/assign_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/check_timer_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/customer_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/invoice_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/lead_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proform_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proposal_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_task_update_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/start_timer_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/time_detail_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/update_task_model.dart';
import 'package:xpertbiz/features/task_module/create_task/service/create_task_service.dart';
import '../../edit_task/model/get_task_model.dart';
import '../model/get_comment_model.dart';
import '../model/request_model.dart';

class CreateTaskRepository {
  final CreateTaskService service;

  CreateTaskRepository(this.service);

  Future<void> createTask(CreateTaskRequest request) {
    return service.createTask(request);
  }

  Future<GetTaskModel> getPerTask(String taskId) async {
    final response = await service.getTask(taskId);
    return GetTaskModel.fromJson(response.data);
  }

  Future<TaskUpdateModel> taskUpdate(TaskUpdateRequest req) async {
    final response = await service.taskUpdate(req);
    return TaskUpdateModel.fromJson(response.data);
  }

  Future<List<ProposalModel>> fetchProposal(String value) async {
    final response = await service.fetchRelatedTO(value);

    final List data = response.data;

    return data
        .map(
          (e) => ProposalModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<ProformModel>> fetchProform(String value) async {
    final response = await service.fetchRelatedTO(value);

    final List data = response.data;

    return data
        .map(
          (e) => ProformModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<CustomerModel>> fetchCustomer(String value) async {
    final response = await service.fetchRelatedTO(value);

    final List data = response.data;

    return data
        .map(
          (e) => CustomerModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<LeadModel>> fetchLead(String value) async {
    final response = await service.fetchRelatedTO(value);

    final List data = response.data;

    return data
        .map(
          (e) => LeadModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<InvoiceModel>> fetchInvoice(String value) async {
    final response = await service.fetchRelatedTO(value);

    final List data = response.data;

    return data
        .map(
          (e) => InvoiceModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<AssignModel>> assignDropDown() async {
    final response = await service.fetchAssignsDropDown();
    final List data = response.data;
    return data
        .map(
          (e) => AssignModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<TaskLogModel> startTime(String taskId) async {
    final res = await service.startTaskTimer(taskId);
    return TaskLogModel.fromJson(
      res.data as Map<String, dynamic>,
    );
  }

  Future<String> endTime(String taskId, String note) async {
    final res = await service.stopTaskTimer(taskId, note);
    return res.data;
  }

  Future<CheckTimerStatusModel?> timeStatus(String taskId) async {
    final response = await service.checkTimerStatus(taskId);
    if (response.statusCode == 204 || response.data == null) {
      return null;
    }

    return CheckTimerStatusModel.fromJson(response.data);
  }

  Future<List<TimeDetailsModel>> timedetailsFetch(String taskId) async {
    final response = await service.timedetailsFetch(taskId);
    if (response.data == null) return [];
    return (response.data as List)
        .map((e) => TimeDetailsModel.fromJson(e))
        .toList();
  }

  Future<void> addComment(AddCommentRequest request) {
    return service.addComment(request);
  }

  Future<TaskCommentResponse> getComment(String taskId) async {
    final res = await service.getComment(taskId);
    return TaskCommentResponse.fromJson(res.data);
  }

  Future<void> addAsignee(
      {required String taskId, required List<String> employeeIds}) {
    log('Ganesh : response ');
    return service.addAssignee(taskId: taskId, employeeIds: employeeIds);
  }

  Future<void> addFollowers(
      {required String taskId, required List<String> employeeIds}) {
    return service.addFollower(taskId: taskId, employeeIds: employeeIds);
  }

  Future<void> updatedStatus({required String taskId, required String status}) {
    return service.updateStatus(taskId: taskId, status: status);
  }
}
