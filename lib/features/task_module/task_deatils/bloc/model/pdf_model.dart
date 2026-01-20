

class DocModel {
  final String fileName;
  final String filePath;
  final String uploadedBy;
  final String? base64;

  DocModel({
    required this.fileName,
    required this.filePath,
    required this.uploadedBy,
    this.base64,
  });
}
