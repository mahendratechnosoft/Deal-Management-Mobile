import 'dart:convert';
import 'package:xpertbiz/features/task_module/task/data/model/task_list_model.dart';
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
    List<String>? assignEmployeeIds,
    List<String>? followerId,
    List<String>? relatedToId,
    String? relatedTo,
    List<String>? milestoneIds,
  }) async {
    final response = await api.getTasks(
      page: page,
      size: size,
      status: status,
      listType: listType,
      search: search,
      assignEmployeeIds: assignEmployeeIds,
      followerId: followerId,
      relatedToId: relatedToId,
      relatedTo: relatedTo,
      milestoneIds: milestoneIds,
    );

    final dynamic rawData = response.data;
    final Map<String, dynamic> mapData = rawData is String
        ? jsonDecode(rawData)
        : (rawData is Map<String, dynamic> ? rawData : {});

    final Map<String, dynamic> targetData =
        (mapData.containsKey('data') && mapData['data'] is Map<String, dynamic>)
            ? mapData['data']
            : mapData;

    return TaskListModel.fromJson(targetData);
  }

  Future<dynamic> deleteTask(String taskId) async {
    final res = await api.deleteTask(taskId);
    return res;
  }
}
