import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';

import '../bloc/model/attchment_model.dart';
import '../bloc/model/doc_model.dart';

class CommentApiService {
  final Dio dio;
  CommentApiService(this.dio);

  Future<void> uploadAttachments(List<CommentDoc> docs) async {
    await dio.post(
      ApiConstants.addDocUrl,
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.jsonContentType,
      ),
      data: docs.map((e) => e.toJson()).toList(),
    );
  }

  Future<List<AttachmentModel>> getTaskAttachments(String taskId) async {
    final res = await dio.get(
      '${ApiConstants.getAttchmentUrl}/$taskId',
    );

    return (res.data as List).map((e) => AttachmentModel.fromJson(e)).toList();
  }
}
