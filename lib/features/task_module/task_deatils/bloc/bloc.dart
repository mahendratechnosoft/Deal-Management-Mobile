
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/repo.dart';
import 'event.dart';
import 'model/doc_model.dart';
import 'state.dart';
class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository repo;

  CommentBloc(this.repo) : super(const CommentState()) {
    on<LoadTaskAttachmentsEvent>(_loadAttachments);
    on<RemoveAttachmentEvent>(_removeLocalAttachment);
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
}
