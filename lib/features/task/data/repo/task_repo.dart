import 'package:xpertbiz/features/task/data/model/task_list_model.dart';
import '../service/task_service.dart';

class TaskRepository {
  final TaskApiService api;

  TaskRepository(this.api);

  Future<TaskListModel> fetchTasks({
    required int page,
    required int size,
    String? status,
    String? listType,
    String? search,
  }) async {
    final response = await api.getTasks(
      page: page,
      size: size,
      status: status,
      listType: listType,
      search: search,
    );

    return TaskListModel.fromJson(response.data);
  }

  Future<void> deleteTask(String taskId) async {
    await api.deleteTask(taskId);
  }
}
