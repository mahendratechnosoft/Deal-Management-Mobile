import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../repo/repo.dart';
import 'event.dart';
import 'model/doc_model.dart';
import 'state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository repo;

  CommentBloc(this.repo) : super(const CommentState()) {
    on<LoadTaskAttachmentsEvent>(_loadAttachments);
    on<RemoveAttachmentEvent>(_removeLocalAttachment);
    on<UploadAttachmentsEvent>(_uploadAttachments);
    on<PickAttachmentEvent>(_pickAttachment);
  }

  Future<void> _loadAttachments(
    LoadTaskAttachmentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    try {
      final data = await repo.fetchTaskAttachments(event.taskId);
      emit(state.copyWith(
        loading: false,
        serverAttachments: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  void _removeLocalAttachment(
    RemoveAttachmentEvent event,
    Emitter<CommentState> emit,
  ) {
    final list = List<CommentDoc>.from(state.attachments)
      ..removeAt(event.index);

    emit(state.copyWith(attachments: list));
  }

  Future<void> _uploadAttachments(
    UploadAttachmentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    if (state.attachments.isEmpty) return;

    emit(state.copyWith(uploading: true, error: null));

    try {
      // Upload picked attachments
      await repo.uploadAttachments(state.attachments);

      // 🔁 Reload server attachments
      final updatedServerAttachments =
          await repo.fetchTaskAttachments(event.taskId);

      emit(state.copyWith(
        uploading: false,
        attachments: [], // clear local
        serverAttachments: updatedServerAttachments,
      ));
    } catch (e) {
      emit(state.copyWith(
        uploading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _pickAttachment(
    PickAttachmentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final picker = ImagePicker();
      File? file;
      String contentType = '';

      switch (event.type) {
        case AttachmentPickerType.gallery:
          final xFile = await picker.pickImage(source: ImageSource.gallery);
          if (xFile != null) {
            file = File(xFile.path);
            contentType = 'image/${xFile.path.split('.').last}';
          }
          break;

        case AttachmentPickerType.camera:
          final xFile = await picker.pickImage(source: ImageSource.camera);
          if (xFile != null) {
            file = File(xFile.path);
            contentType = 'image/${xFile.path.split('.').last}';
          }
          break;

        case AttachmentPickerType.pdf:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
          if (result != null) {
            file = File(result.files.single.path!);
            contentType = 'application/pdf';
          }
          break;
      }

      if (file == null) return;

      final bytes = await file.readAsBytes();

      // ✅ CORRECT MODEL USAGE
      final doc = CommentDoc(
        taskId: event.taskId, // or pass current taskId if available
        fileName: file.path.split('/').last,
        contentType: contentType,
        data: base64Encode(bytes),
      );

      final updated = List<CommentDoc>.from(state.attachments)..add(doc);

      emit(state.copyWith(attachments: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
