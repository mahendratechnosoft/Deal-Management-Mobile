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

  
}
