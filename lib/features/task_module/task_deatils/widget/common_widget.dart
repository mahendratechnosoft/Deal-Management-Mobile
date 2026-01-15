import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/model/doc_model.dart';
import '../bloc/state.dart';

void showAttachmentsDialog(BuildContext context, String taskId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<CommentBloc>().add(
          LoadTaskAttachmentsEvent(taskId),
        );
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return BlocBuilder<CommentBloc, CommentState>(
        builder: (context, state) {
          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    /// Drag Handle
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Text(
                            'Attachments',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    /// Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Attachment Options
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _attachmentOption(
                                  icon: Icons.image_rounded,
                                  label: 'Gallery',
                                  color: Colors.blue,
                                  onTap: () => context.read<CommentBloc>().add(
                                      PickAttachmentEvent(
                                          AttachmentPickerType.gallery)),
                                ),
                                _attachmentOption(
                                  icon: Icons.camera_alt_rounded,
                                  label: 'Camera',
                                  color: Colors.green,
                                  onTap: () => context.read<CommentBloc>().add(
                                      PickAttachmentEvent(
                                          AttachmentPickerType.camera)),
                                ),
                                _attachmentOption(
                                  icon: Icons.picture_as_pdf_rounded,
                                  label: 'Document',
                                  color: Colors.red,
                                  onTap: () => context.read<CommentBloc>().add(
                                      PickAttachmentEvent(
                                          AttachmentPickerType.pdf)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            /// Existing Attachments (API)
                            if (state.serverAttachments.isNotEmpty) ...[
                              const Text(
                                'Existing Attachments',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.serverAttachments.length,
                                separatorBuilder: (_, __) =>
                                    Divider(color: Colors.grey.shade200),
                                itemBuilder: (_, i) {
                                  final file = state.serverAttachments[i];
                                  final isImage = ['jpg', 'jpeg', 'png']
                                      .contains(file.fileName
                                          .split('.')
                                          .last
                                          .toLowerCase());

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      _getFileIcon(file.fileName),
                                      color: Colors.grey.shade700,
                                    ),
                                    title: Text(
                                      file.fileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      'Uploaded by ${file.uploadedBy}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    onTap: isImage
                                        ? () => _showImagePreview(
                                              context,
                                              file.data,
                                            )
                                        : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),

                    /// Upload Button (Fixed Bottom)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Button(
                        isLoading: state.loading,
                        text: 'Upload Attachments',
                        isValid: state.attachments.isNotEmpty,
                        onPressed: () {
                          context
                              .read<CommentBloc>()
                              .add(UploadAttachmentsEvent(taskId));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

void _showImagePreview(BuildContext context, String base64Image) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.memory(
            base64Decode(base64Image),
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  );
}

Widget _attachmentOption({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

IconData _getFileIcon(String fileName) {
  final ext = fileName.toLowerCase().split('.').last;
  if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
  if (['jpg', 'jpeg', 'png'].contains(ext)) return Icons.image_rounded;
  return Icons.insert_drive_file_rounded;
}
