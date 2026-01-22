class LeadStatusModel {
  final String status;
  final int count;

  LeadStatusModel({
    required this.status,
    required this.count,
  });

  factory LeadStatusModel.fromJson(Map<String, dynamic> json) {
    return LeadStatusModel(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
