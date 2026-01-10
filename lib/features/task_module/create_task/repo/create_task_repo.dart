import 'package:xpertbiz/features/task_module/create_task/model/customer_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/invoice_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/lead_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proform_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proposal_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_task_update_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/update_task_model.dart';
import 'package:xpertbiz/features/task_module/create_task/service/create_task_service.dart';
import '../../edit_task/model/get_task_model.dart';
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
    final response = await service.fetchAssigns(value);

    final List data = response.data;

    return data
        .map(
          (e) => ProposalModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<ProformModel>> fetchProform(String value) async {
    final response = await service.fetchAssigns(value);

    final List data = response.data;

    return data
        .map(
          (e) => ProformModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<CustomerModel>> fetchCustomer(String value) async {
    final response = await service.fetchAssigns(value);

    final List data = response.data;

    return data
        .map(
          (e) => CustomerModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<LeadModel>> fetchLead(String value) async {
    final response = await service.fetchAssigns(value);

    final List data = response.data;

    return data
        .map(
          (e) => LeadModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<InvoiceModel>> fetchInvoice(String value) async {
    final response = await service.fetchAssigns(value);

    final List data = response.data;

    return data
        .map(
          (e) => InvoiceModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
