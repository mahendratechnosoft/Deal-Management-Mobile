class AddCommentRequest {
  final String taskId;
  final String content;
  final List<CommentAttachment> attachments;

  AddCommentRequest({
    required this.taskId,
    required this.content,
    required this.attachments,
  });

  Map<String, dynamic> toJson() => {
        "taskId": taskId,
        "content": content,
        "attachments": attachments.map((e) => e.toJson()).toList(),
      };
}

class CommentAttachment {
  final String fileName;
  final String contentType;
  final String data; // Base64

  CommentAttachment({
    required this.fileName,
    required this.contentType,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "contentType": contentType,
        "data": data,
      };
}
