import 'package:xpertbiz/features/task_module/task_deatils/bloc/model/doc_model.dart';

abstract class CommentEvent {}
class PickAttachmentEvent extends CommentEvent {
  final AttachmentPickerType type;
  final String taskId;
  PickAttachmentEvent(this.type,this.taskId);
}

class RemoveAttachmentEvent extends CommentEvent {
  final int index;
  RemoveAttachmentEvent(this.index);
}

class UploadAttachmentsEvent extends CommentEvent {
  final String taskId;
  UploadAttachmentsEvent(this.taskId);
}


class LoadTaskAttachmentsEvent extends CommentEvent {
  final String taskId;
  LoadTaskAttachmentsEvent(this.taskId);
}