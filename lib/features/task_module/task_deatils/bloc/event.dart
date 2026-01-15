import 'package:xpertbiz/features/task_module/task_deatils/bloc/model/doc_model.dart';

abstract class CommentEvent {}

/// ONE event for all picking
class PickAttachmentEvent extends CommentEvent {
  final AttachmentPickerType type;
  PickAttachmentEvent(this.type);
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