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
    List<String>? assignEmployeeIds,
    List<String>? followerId,
    List<String>? relatedToId,
    String? relatedTo,
    List<String>? milestoneIds,
  }) {
    return dio.put(
      '${ApiConstants.getTask}$page/$size',
      data: {
        'assignEmployeeIds': assignEmployeeIds ?? [],
        'followerId': followerId ?? [],
        'relatedToId': relatedToId ?? [],
        'relatedTo': relatedTo,
        'milestoneIds': milestoneIds ?? [],
      },
      queryParameters: {
        if (status != null) 'status': status,
        if (listType != null) 'listType': listType,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
  }

  Future<Response> deleteTask(String taskId) {
    return dio.delete(
      '${ApiConstants.deleteTask}$taskId',
      options: Options(
        responseType: ResponseType.plain,
      ),
    );
  }
}
