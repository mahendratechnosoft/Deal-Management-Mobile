import '../bloc/model/attchment_model.dart';
import '../bloc/model/doc_model.dart';
import '../service/service.dart';

class CommentRepository {
  final CommentApiService api;
  CommentRepository(this.api);

  Future<void> uploadAttachments(List<CommentDoc> docs) {
    return api.uploadAttachments(docs);
  }
  
   Future<List<AttachmentModel>> fetchTaskAttachments(String taskId) {
    return api.getTaskAttachments(taskId);
  }
}
