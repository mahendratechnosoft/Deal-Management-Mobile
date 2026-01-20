enum AttendanceStatus {
  present,
  absent,
  late,
  halfDay,
}

class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final double totalHours;
  final int timestamp; // Milliseconds since epoch
  final bool isLate;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.totalHours,
    required this.timestamp,
    this.isLate = false,
  });

  // Factory method for creating from JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      checkInTime: json['checkInTime'] != null 
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      isLate: json['isLate'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status.name,
      'totalHours': totalHours,
      'timestamp': timestamp,
      'isLate': isLate,
    };
  }

  // Check if attendance is marked based on timestamp
  bool get isMarked {
    return timestamp > 0;
  }

  // Get formatted date string
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Get day name
  String get dayName {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  // Copy with method
  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    double? totalHours,
    int? timestamp,
    bool? isLate,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      totalHours: totalHours ?? this.totalHours,
      timestamp: timestamp ?? this.timestamp,
      isLate: isLate ?? this.isLate,
    );
  }

  @override
  String toString() {
    return 'Attendance{date: $date, status: $status, hours: $totalHours, timestamp: $timestamp}';
  }
}