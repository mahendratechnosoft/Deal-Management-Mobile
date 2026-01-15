import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';

import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/create_task/model/add_comment.dart';
import 'package:xpertbiz/features/task_module/create_task/model/get_comment_model.dart';

void showCommentDialog({
  required BuildContext context,
  required String taskId,
}) {
  final controller = TextEditingController();
  final ValueNotifier<List<CommentAttachment>> attachments =
      ValueNotifier<List<CommentAttachment>>([]);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<CreateTaskBloc>().add(LoadCommentsEvent(taskId: taskId));
  });

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return BlocConsumer<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {
          if (state.commentError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.commentError!)),
            );
          }
        },
        builder: (context, state) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  _header(context, state.comments.length),
                  Expanded(
                    child: state.isLoadingComments
                        ? const Center(child: CircularProgressIndicator())
                        : state.comments.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: state.comments.length,
                                itemBuilder: (_, i) =>
                                    _commentItem(state.comments[i], context),
                              ),
                  ),
                  _inputArea(
                    context: context,
                    controller: controller,
                    isLoading: state.isAddingComment,
                    attachments: attachments,
                    onSend: () {
                      if (controller.text.trim().isEmpty) return;

                      context.read<CreateTaskBloc>().add(
                            AddCommentEvent(
                              taskId: taskId,
                              content: controller.text.trim(),
                              attachments: attachments.value,
                            ),
                          );

                      controller.clear();
                      attachments.value = [];
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/* ================= HEADER ================= */

Widget _header(BuildContext context, int count) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Row(
      children: [
        const Icon(Icons.sticky_note_2_outlined, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        const Text(
          'Task Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Text('($count)', style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

/* ================= EMPTY ================= */

Widget _emptyState() {
  return const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.note_alt_outlined, size: 48, color: Colors.grey),
        SizedBox(height: 12),
        Text('No notes added yet', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

/* ================= COMMENT CARD ================= */

Widget _commentItem(TaskComment comment, BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: comment.deleted ? Colors.red : const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.commentedBy,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),

                  /// Attachment icon (only if attachments exist)
                  if (comment.attachments.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showAttachmentPreview(
                          context,
                          comment.attachments,
                        );
                      },
                    ),

                  Text(
                    _formatTime(comment.commentedAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Html(
                data: comment.deleted
                    ? '<i>This note was deleted</i>'
                    : comment.content,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showAttachmentPreview(
  BuildContext context,
  List<CommentDoc> attachments,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                itemCount: attachments.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade300),
                itemBuilder: (_, i) {
                  final doc = attachments[i];

                  return ListTile(
                    leading: Icon(
                      _fileIcon(doc.fileName),
                      color: const Color(0xFF2563EB),
                    ),
                    title: Text(
                      doc.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      doc.contentType,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      Navigator.pop(context);
                      _openAttachment(context, doc);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _openAttachment(BuildContext context, CommentDoc doc) {
  final ext = doc.fileName.split('.').last.toLowerCase();

  /// Image preview
  if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.memory(
            base64Decode(doc.data),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  } else {
    /// For PDF / DOC → open later / download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document preview not supported yet'),
      ),
    );
  }
}

/* ================= INPUT ================= */

Widget _inputArea({
  required BuildContext context,
  required TextEditingController controller,
  required bool isLoading,
  required ValueNotifier<List<CommentAttachment>> attachments,
  required VoidCallback onSend,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      border: Border(top: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<List<CommentAttachment>>(
          valueListenable: attachments,
          builder: (_, list, __) {
            if (list.isEmpty) return const SizedBox();
            return SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final file = list[i];
                  return Chip(
                    label: Text(_shortName(file.fileName)),
                    avatar: Icon(_fileIcon(file.fileName), size: 16),
                    onDeleted: () {
                      attachments.value = List.from(list)..removeAt(i);
                    },
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
                child: AppTextField(
              hint: 'Add note...',
              controller: controller,
            )),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () => _showAttachmentPicker(context, attachments),
            ),
            isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: onSend,
                    icon: const Icon(Icons.send),
                  ),
          ],
        ),
      ],
    ),
  );
}

/* ================= PICKERS ================= */

void _showAttachmentPicker(
  BuildContext context,
  ValueNotifier<List<CommentAttachment>> attachments,
) {
  final picker = ImagePicker();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _attachOption(
              icon: Icons.image,
              label: 'Gallery Image',
              onTap: () async {
                final image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  final bytes = await File(image.path).readAsBytes();
                  attachments.value = [
                    ...attachments.value,
                    CommentAttachment(
                      fileName: image.name,
                      contentType: 'image/jpeg',
                      data: base64Encode(bytes),
                    ),
                  ];
                }
                Navigator.pop(context);
              },
            ),
            _attachOption(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () async {
                final image =
                    await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  final bytes = await File(image.path).readAsBytes();
                  attachments.value = [
                    ...attachments.value,
                    CommentAttachment(
                      fileName: image.name,
                      contentType: 'image/jpeg',
                      data: base64Encode(bytes),
                    ),
                  ];
                }
                Navigator.pop(context);
              },
            ),
            _attachOption(
              icon: Icons.picture_as_pdf,
              label: 'Document (PDF / DOC)',
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx'],
                );
                if (result != null) {
                  for (final f in result.files) {
                    final bytes = File(f.path!).readAsBytesSync();
                    attachments.value = [
                      ...attachments.value,
                      CommentAttachment(
                        fileName: f.name,
                        contentType: _mimeType(f.extension),
                        data: base64Encode(bytes),
                      ),
                    ];
                  }
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _attachOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: const Color(0xFF2563EB)),
    title: Text(label),
    onTap: onTap,
  );
}

/* ================= HELPERS ================= */

String _mimeType(String? ext) {
  switch (ext?.toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'doc':
    case 'docx':
      return 'application/msword';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    default:
      return 'application/octet-stream';
  }
}

IconData _fileIcon(String name) {
  final ext = name.split('.').last.toLowerCase();
  if (ext == 'pdf') return Icons.picture_as_pdf;
  if (['jpg', 'jpeg', 'png'].contains(ext)) return Icons.image;
  if (['doc', 'docx'].contains(ext)) return Icons.description;
  return Icons.insert_drive_file;
}

String _shortName(String name) {
  if (name.length <= 12) return name;
  final ext = name.split('.').last;
  return '${name.substring(0, 8)}...$ext';
}

String _formatTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}
