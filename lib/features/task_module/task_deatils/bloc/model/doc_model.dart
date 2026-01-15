class CommentDoc {
  final String taskId;
  final String fileName;
  final String contentType;
  final String? data; // base64

  CommentDoc({
    required this.taskId,
    required this.fileName,
    required this.contentType,
    required this.data,
  });

  CommentDoc copyWith({String? taskId}) {
    return CommentDoc(
      taskId: taskId ?? this.taskId,
      fileName: fileName,
      contentType: contentType,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "taskId": taskId,
      "fileName": fileName,
      "contentType": contentType,
      "data": data,
    };
  }
}

enum AttachmentPickerType {
  gallery,
  camera,
  pdf,
}
