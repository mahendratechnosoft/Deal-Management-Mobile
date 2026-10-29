class LeaveDayModel {
  final String? leaveDayId;
  final String date;
  final String leaveDayType; // FULL_DAY, HALF_DAY, WEEKEND
  final String? status;

  const LeaveDayModel({
    this.leaveDayId,
    required this.date,
    required this.leaveDayType,
    this.status,
  });

  factory LeaveDayModel.fromJson(Map<String, dynamic> json) {
    return LeaveDayModel(
      leaveDayId: json['leaveDayId']?.toString(),
      date: json['date']?.toString() ?? json['leaveDate']?.toString() ?? '',
      leaveDayType: json['leaveDayType']?.toString() ?? 'FULL_DAY',
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (leaveDayId != null) 'leaveDayId': leaveDayId,
        'date': date,
        'leaveDayType': leaveDayType,
        if (status != null) 'status': status,
      };

  LeaveDayModel copyWith({
    String? leaveDayId,
    String? date,
    String? leaveDayType,
    String? status,
  }) {
    return LeaveDayModel(
      leaveDayId: leaveDayId ?? this.leaveDayId,
      date: date ?? this.date,
      leaveDayType: leaveDayType ?? this.leaveDayType,
      status: status ?? this.status,
    );
  }
}

class LeaveRequestModel {
  final String leaveRequestId;
  final String? adminId;
  final String? creatorId;
  final String? creatorName;
  final String? assignToId;
  final String? assignToName;
  final String leaveType;
  final String? startDate;
  final String? endDate;
  final List<LeaveDayModel> leaveDays;
  final String reason;
  final String status;
  final String? remarks;
  final String? attachedFileUrl;
  final String? handoverId;
  final String? handoverName;
  final String? createdAt;
  final String? updatedAt;

  const LeaveRequestModel({
    required this.leaveRequestId,
    this.adminId,
    this.creatorId,
    this.creatorName,
    this.assignToId,
    this.assignToName,
    required this.leaveType,
    this.startDate,
    this.endDate,
    this.leaveDays = const [],
    required this.reason,
    required this.status,
    this.remarks,
    this.attachedFileUrl,
    this.handoverId,
    this.handoverName,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    var rawDays = json['leaveDays'];
    List<LeaveDayModel> days = [];
    if (rawDays is List) {
      days = rawDays
          .whereType<Map<String, dynamic>>()
          .map((e) => LeaveDayModel.fromJson(e))
          .toList();
    }

    return LeaveRequestModel(
      leaveRequestId: json['leaveRequestId']?.toString() ?? '',
      adminId: json['adminId']?.toString(),
      creatorId: json['creatorId']?.toString(),
      creatorName: json['creatorName']?.toString(),
      assignToId: json['assignToId']?.toString(),
      assignToName: json['assignToName']?.toString(),
      leaveType: json['leaveType']?.toString() ?? 'Leave without Pay',
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      leaveDays: days,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      remarks: json['remarks']?.toString(),
      attachedFileUrl: json['attachedFileUrl']?.toString(),
      handoverId: json['handoverId']?.toString(),
      handoverName: json['handoverName']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'leaveRequestId': leaveRequestId,
        if (adminId != null) 'adminId': adminId,
        if (creatorId != null) 'creatorId': creatorId,
        if (creatorName != null) 'creatorName': creatorName,
        'assignToId': assignToId,
        'assignToName': assignToName,
        'leaveType': leaveType,
        'startDate': startDate,
        'endDate': endDate,
        'leaveDays': leaveDays.map((d) => d.toJson()).toList(),
        'reason': reason,
        'status': status,
        if (remarks != null) 'remarks': remarks,
        if (attachedFileUrl != null) 'attachedFileUrl': attachedFileUrl,
        if (handoverId != null) 'handoverId': handoverId,
        if (handoverName != null) 'handoverName': handoverName,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  double get totalDaysCount {
    if (leaveDays.isNotEmpty) {
      double total = 0.0;
      for (final day in leaveDays) {
        if (day.leaveDayType.toUpperCase() == 'HALF_DAY') {
          total += 0.5;
        } else if (day.leaveDayType.toUpperCase() == 'FULL_DAY') {
          total += 1.0;
        }
      }
      return total > 0 ? total : 1.0;
    }
    return 1.0;
  }

  String get formattedDaysCount {
    final count = totalDaysCount;
    if (count == count.roundToDouble()) {
      final intDays = count.toInt();
      return intDays == 1 ? '1 Day' : '$intDays Days';
    }
    return '$count Days';
  }

  /// Whether the leave request has an attached file
  bool get hasAttachment =>
      attachedFileUrl != null && attachedFileUrl!.trim().isNotEmpty;

  /// Whether the attached file is an image based on file extension
  bool get isAttachmentImage {
    if (attachedFileUrl == null || attachedFileUrl!.trim().isEmpty) return false;
    final lower = attachedFileUrl!.toLowerCase().trim();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  /// Formats the attachment URL to load from:
  /// http://api.mtechnosoft.xpertbizsolutions.com/uploads/{fileName}
  String? get fullAttachmentUrl {
    if (attachedFileUrl == null || attachedFileUrl!.trim().isEmpty) return null;
    return formatAttachmentUrl(attachedFileUrl!);
  }

  /// Helper to convert any raw filename / path to the full uploads URL
  static String formatAttachmentUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    String clean = trimmed;
    if (clean.startsWith('/')) clean = clean.substring(1);
    if (clean.startsWith('uploads/')) clean = clean.substring('uploads/'.length);
    return 'http://api.mtechnosoft.xpertbizsolutions.com/uploads/$clean';
  }
}

class LeavePageResponse {
  final List<LeaveRequestModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const LeavePageResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  factory LeavePageResponse.fromJson(dynamic data) {
    if (data is List) {
      final list = data
          .whereType<Map<String, dynamic>>()
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
      return LeavePageResponse(
        content: list,
        pageNumber: 0,
        pageSize: list.length,
        totalPages: 1,
        totalElements: list.length,
        isLast: true,
      );
    } else if (data is Map<String, dynamic>) {
      final rawList = data['content'] ?? data['data'] ?? [];
      List<LeaveRequestModel> list = [];
      if (rawList is List) {
        list = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => LeaveRequestModel.fromJson(e))
            .toList();
      }
      final pageable = data['pageable'] as Map<String, dynamic>?;
      return LeavePageResponse(
        content: list,
        pageNumber: (data['number'] ?? pageable?['pageNumber'] ?? 0) as int,
        pageSize: (data['size'] ?? pageable?['pageSize'] ?? list.length) as int,
        totalPages: (data['totalPages'] ?? 1) as int,
        totalElements: (data['totalElements'] ?? list.length) as int,
        isLast: (data['last'] ?? true) as bool,
      );
    }
    return const LeavePageResponse(
      content: [],
      pageNumber: 0,
      pageSize: 10,
      totalPages: 0,
      totalElements: 0,
      isLast: true,
    );
  }
}
