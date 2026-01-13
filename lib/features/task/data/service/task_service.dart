import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';

class TaskApiService {
  final Dio dio;

  TaskApiService(this.dio);

  Future<Response> getTasks({
    required int page,
    required int size,
    String? status,
    String? listType,
    String? search,
  }) {
    return dio.get(
      '${ApiConstants.getTask}$page/$size',
      queryParameters: {
        if (status != null) 'status': status,
        if (listType != null) 'listType': listType,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
  }

  Future<void> deleteTask(String taskId) {
    return dio.delete('${ApiConstants.deleteTask}/$taskId');
  }
}
