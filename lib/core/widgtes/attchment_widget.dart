import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import '../utils/responsive.dart';

class AttachmentPicker extends StatefulWidget {
  final int maxFiles;
  final int maxFileSizeMB;
  final List<String> allowedExtensions;
  final ValueChanged<List<PlatformFile>> onFilesChanged;

  const AttachmentPicker({
    super.key,
    this.maxFiles = 4,
    this.maxFileSizeMB = 5,
    this.allowedExtensions = const [
      'pdf',
      'doc',
      'docx',
      'txt',
      'jpg',
      'jpeg',
      'png'
    ],
    required this.onFilesChanged,
  });

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  List<PlatformFile> _files = [];

  Future<void> _pickFiles() async {
    if (_files.length >= widget.maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can upload max ${widget.maxFiles} files')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> pickedFiles = [];

      for (var file in result.files) {
        if (file.size / (1024 * 1024) > widget.maxFileSizeMB) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('${file.name} exceeds ${widget.maxFileSizeMB}MB')),
          );
          continue;
        }

        pickedFiles.add(file);
      }

      int availableSlots = widget.maxFiles - _files.length;
      if (pickedFiles.length > availableSlots) {
        pickedFiles = pickedFiles.sublist(0, availableSlots);
      }

      setState(() {
        _files.addAll(pickedFiles);
      });

      widget.onFilesChanged(_files);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
    widget.onFilesChanged(_files);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments (Max ${widget.maxFiles} files, ${widget.maxFileSizeMB}MB each)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Responsive.sp(12),
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.h(6)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._files.asMap().entries.map((entry) {
              int idx = entry.key;
              PlatformFile file = entry.value;

              // Format file size
              String getFileSize(int bytes) {
                double kb = bytes / 1024;
                if (kb < 1024) return "${kb.toStringAsFixed(1)} KB";
                double mb = kb / 1024;
                return "${mb.toStringAsFixed(2)} MB";
              }

              // Shorten file name: keep first 10 chars + ... + extension
              String shortFileName(String name) {
                if (name.length <= 15) return name;
                String ext = name.contains('.') ? name.split('.').last : '';
                String base = name.split('.').first;
                if (base.length > 10) base = base.substring(0, 10);
                return "$base...${ext.isNotEmpty ? '.$ext' : ''}";
              }

              return Chip(
                label: Text(
                  '${shortFileName(file.name)} (${getFileSize(file.size)})',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: Responsive.sp(14),
                  ),
                ),
                backgroundColor: AppColors.background,
                side: BorderSide(color: AppColors.border),
                deleteIcon: Icon(Icons.close,
                    size: Responsive.sp(18), color: Colors.redAccent),
                onDeleted: () => _removeFile(idx),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(8),
                  vertical: Responsive.h(4),
                ),
              );
            }),
            if (_files.length < widget.maxFiles)
              GestureDetector(
                onTap: _pickFiles,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(12),
                    vertical: Responsive.h(12),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file,
                          size: Responsive.sp(20),
                          color: AppColors.primaryDark),
                      SizedBox(width: Responsive.w(6)),
                      Text(
                        'Add File',
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
