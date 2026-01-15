import 'model/attchment_model.dart';
import 'model/doc_model.dart';

class CommentState {
  final bool loading;
  final bool uploading;

  /// API attachments
  final List<AttachmentModel> serverAttachments;

  /// Local picked attachments
  final List<CommentDoc> attachments;

  final String? error;

  const CommentState({
    this.loading = false,
    this.uploading = false,
    this.serverAttachments = const [],
    this.attachments = const [],
    this.error,
  });

  CommentState copyWith({
    bool? loading,
    bool? uploading,
    List<AttachmentModel>? serverAttachments,
    List<CommentDoc>? attachments,
    String? error,
  }) {
    return CommentState(
      loading: loading ?? this.loading,
      uploading: uploading ?? this.uploading,
      serverAttachments: serverAttachments ?? this.serverAttachments,
      attachments: attachments ?? this.attachments,
      error: error,
    );
  }
}
