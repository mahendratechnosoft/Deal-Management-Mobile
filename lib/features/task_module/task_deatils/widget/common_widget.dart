import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';

void showCommentDialog({
  required BuildContext context,
  required void Function(String comment) onSubmit,
  String? initialComment,
}) {
  final controller = TextEditingController(text: initialComment ?? '');
  final ValueNotifier<bool> isValid =
      ValueNotifier(initialComment?.trim().isNotEmpty ?? false);

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              children: [
                /// HEADER
                _dialogHeader(
                  title: 'Add Comment',
                  onClose: () => Navigator.pop(context),
                ),

                /// TOOLBAR
                _editorToolbar(controller),

                /// TEXT FIELD
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Color(0xFF1A1A1A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Write your comment here…',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) {
                        isValid.value = v.trim().isNotEmpty;
                      },
                    ),
                  ),
                ),

                /// FOOTER
                _commentFooter(
                  isValid: isValid,
                  onAttach: () {
                    Navigator.pop(context);
                    showAttachmentsDialog(
                      context: context,
                      onFilesSelected: (_) {
                        showCommentDialog(
                          context: context,
                          onSubmit: onSubmit,
                          initialComment: controller.text,
                        );
                      },
                    );
                  },
                  onSubmit: () {
                    Navigator.pop(context);
                    onSubmit(controller.text.trim());
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showAttachmentsDialog({
  required BuildContext context,
  required void Function(List<String> files) onFilesSelected,
  List<String>? existingFiles,
}) {
  final files = ValueNotifier<List<String>>(existingFiles ?? []);

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) {
      return Dialog(
        backgroundColor: AppColors.background,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Column(
            children: [
              /// HEADER
              _dialogHeader(
                title: 'Attachments',
                onClose: () => Navigator.pop(context),
              ),

              /// CONTENT
              Expanded(
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: files,
                  builder: (_, list, __) {
                    if (list.isEmpty) {
                      return _emptyAttachmentState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey.shade200),
                      itemBuilder: (_, i) {
                        final file = list[i];
                        return _fileTile(
                          file,
                          onDelete: () {
                            files.value = List.from(list)..removeAt(i);
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              /// FOOTER
              _attachmentsFooter(
                files: files,
                onDone: () {
                  Navigator.pop(context);
                  onFilesSelected(files.value);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _dialogHeader({required String title, required VoidCallback onClose}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
      ],
    ),
  );
}

Widget _editorToolbar(TextEditingController controller) {
  return Container(
    height: 44,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.grey.shade200),
        bottom: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.format_bold_rounded),
          onPressed: () => applyWrapFormatting(controller, '**'),
        ),
        IconButton(
          icon: const Icon(Icons.format_italic_rounded),
          onPressed: () => applyWrapFormatting(controller, '_'),
        ),
        IconButton(
          icon: const Icon(Icons.format_underline_rounded),
          onPressed: () => applyWrapFormatting(controller, '__'),
        ),
        IconButton(
          icon: const Icon(Icons.format_list_bulleted_rounded),
          onPressed: () {
            controller.text += '\n- ';
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.format_list_numbered_rounded),
          onPressed: () {
            controller.text += '\n1. ';
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
          },
        ),
      ],
    ),
  );
}

void applyWrapFormatting(
  TextEditingController controller,
  String wrapper,
) {
  final text = controller.text;
  final selection = controller.selection;

  if (!selection.isValid || selection.isCollapsed) return;

  final selectedText = selection.textInside(text);
  final newText = '$wrapper$selectedText$wrapper';

  controller.value = controller.value.copyWith(
    text: selection.textBefore(text) + newText + selection.textAfter(text),
    selection: TextSelection.collapsed(
      offset: selection.start + newText.length,
    ),
  );
}

Widget _commentFooter({
  required ValueNotifier<bool> isValid,
  required VoidCallback onAttach,
  required VoidCallback onSubmit,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        TextButton.icon(
          onPressed: onAttach,
          icon: const Icon(Icons.attach_file_rounded, size: 18),
          label: const Text('Attach'),
        ),
        const Spacer(),
        ValueListenableBuilder<bool>(
          valueListenable: isValid,
          builder: (_, valid, __) {
            return ElevatedButton(
              onPressed: valid ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    valid ? const Color(0xFF2563EB) : Colors.grey.shade400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _emptyAttachmentState() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.attach_file_rounded, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          'No attachments added',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );
}

Widget _fileTile(String file, {required VoidCallback onDelete}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(_getFileIcon(file), color: Colors.grey.shade700),
    title: Text(
      _getFileName(file),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Text(_getFileSize(file)),
    trailing: IconButton(
      icon: const Icon(Icons.delete_outline_rounded),
      onPressed: onDelete,
    ),
  );
}

Widget _attachmentsFooter({
  required ValueNotifier<List<String>> files,
  required VoidCallback onDone,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              files.value = [...files.value, 'sample_file.pdf'];
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Files'),
          ),
        ),
        const SizedBox(width: 12),
        ValueListenableBuilder<List<String>>(
          valueListenable: files,
          builder: (_, list, __) {
            return ElevatedButton(
              onPressed: list.isNotEmpty ? onDone : null,
              child: const Text('Done'),
            );
          },
        ),
      ],
    ),
  );
}

IconData _getFileIcon(String fileName) {
  final ext = fileName.toLowerCase().split('.').last;
  if (['pdf'].contains(ext)) {
    return Icons.picture_as_pdf_rounded;
  } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext)) {
    return Icons.image_rounded;
  } else if (['doc', 'docx'].contains(ext)) {
    return Icons.description_rounded;
  } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
    return Icons.table_chart_rounded;
  } else if (['zip', 'rar', '7z'].contains(ext)) {
    return Icons.archive_rounded;
  }
  return Icons.insert_drive_file_rounded;
}

String _getFileName(String filePath) {
  return filePath.split('/').last;
}

String _getFileSize(String fileName) {
  final random = fileName.hashCode % 3;
  final sizes = ['1.2 MB', '4.5 MB', '256 KB'];
  return sizes[random];
}
