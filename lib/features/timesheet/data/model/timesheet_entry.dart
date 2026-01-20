class TimesheetEntry {
  final String date;
  final String project;
  final String task;
  final double hours;
  final String status;

  const TimesheetEntry({
    required this.date,
    required this.project,
    required this.task,
    required this.hours,
    required this.status,
  });

  // Factory method for creating from JSON
  factory TimesheetEntry.fromJson(Map<String, dynamic> json) {
    return TimesheetEntry(
      date: json['date'] ?? '',
      project: json['project'] ?? '',
      task: json['task'] ?? '',
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'project': project,
      'task': task,
      'hours': hours,
      'status': status,
    };
  }

  // Copy with method for immutability
  TimesheetEntry copyWith({
    String? date,
    String? project,
    String? task,
    double? hours,
    String? status,
  }) {
    return TimesheetEntry(
      date: date ?? this.date,
      project: project ?? this.project,
      task: task ?? this.task,
      hours: hours ?? this.hours,
      status: status ?? this.status,
    );
  }

  // Get formatted date (MM/DD)
  String get formattedDate {
    try {
      final parts = date.split('-');
      if (parts.length >= 3) {
        return '${parts[1]}/${parts[2]}';
      }
    } catch (e) {
      // Fallback if date parsing fails
    }
    return date;
  }

  // Get day name from date
  String get dayName {
    try {
      final dateTime = DateTime.parse(date);
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[dateTime.weekday % 7];
    } catch (e) {
      return 'N/A';
    }
  }

  // Get month name
  String get monthName {
    try {
      final dateTime = DateTime.parse(date);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return months[dateTime.month - 1];
    } catch (e) {
      return '';
    }
  }

  // Get day number
  String get dayNumber {
    try {
      final dateTime = DateTime.parse(date);
      return dateTime.day.toString();
    } catch (e) {
      return '';
    }
  }

  // Get status color
  int get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return 0xFF4CAF50; // Green
      case 'in progress':
      case 'in-progress':
        return 0xFFFF9800; // Orange
      case 'approved':
        return 0xFF2196F3; // Blue
      case 'pending':
        return 0xFF9E9E9E; // Grey
      case 'rejected':
      case 'cancelled':
        return 0xFFF44336; // Red
      case 'on hold':
        return 0xFFFFC107; // Amber
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  // Get project color (consistent color based on project name)
  int get projectColor {
    final hash = project.hashCode;
    final colors = [
      0xFF2196F3, // Blue
      0xFF4CAF50, // Green
      0xFFFF9800, // Orange
      0xFF9C27B0, // Purple
      0xFFF44336, // Red
      0xFF00BCD4, // Cyan
      0xFF673AB7, // Deep Purple
      0xFFFF5722, // Deep Orange
      0xFF795548, // Brown
      0xFF607D8B, // Blue Grey
    ];
    return colors[hash.abs() % colors.length];
  }

  // Get hours formatted
  String get formattedHours {
    if (hours == hours.truncate()) {
      return '${hours.toInt()}h';
    }
    return '${hours.toStringAsFixed(1)}h';
  }

  // Check if entry is today
  bool get isToday {
    try {
      final entryDate = DateTime.parse(date);
      final now = DateTime.now();
      return entryDate.year == now.year &&
          entryDate.month == now.month &&
          entryDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  // Check if entry is in the current week
  bool get isThisWeek {
    try {
      final entryDate = DateTime.parse(date);
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return entryDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          entryDate.isBefore(weekEnd.add(const Duration(days: 1)));
    } catch (e) {
      return false;
    }
  }

  // Get status icon
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'completed':
        return '✓';
      case 'in progress':
      case 'in-progress':
        return '↻';
      case 'approved':
        return '✔';
      case 'pending':
        return '⋯';
      case 'rejected':
        return '✗';
      default:
        return '•';
    }
  }

  // Compare two entries for sorting
  static int compareByDate(TimesheetEntry a, TimesheetEntry b) {
    try {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      return dateB.compareTo(dateA); // Newest first
    } catch (e) {
      return 0;
    }
  }

  // Compare by hours (descending)
  static int compareByHours(TimesheetEntry a, TimesheetEntry b) {
    return b.hours.compareTo(a.hours);
  }

  // Compare by project name
  static int compareByProject(TimesheetEntry a, TimesheetEntry b) {
    return a.project.compareTo(b.project);
  }

  // Check if entry is valid
  bool get isValid {
    return date.isNotEmpty &&
        project.isNotEmpty &&
        task.isNotEmpty &&
        hours > 0 &&
        status.isNotEmpty;
  }

  // Calculate total hours from a list of entries
  static double calculateTotalHours(List<TimesheetEntry> entries) {
    return entries.fold(0.0, (sum, entry) => sum + entry.hours);
  }

  // Filter entries by project
  static List<TimesheetEntry> filterByProject(
    List<TimesheetEntry> entries,
    String projectName,
  ) {
    return entries
        .where((entry) => entry.project == projectName)
        .toList();
  }

  // Filter entries by status
  static List<TimesheetEntry> filterByStatus(
    List<TimesheetEntry> entries,
    String status,
  ) {
    return entries
        .where((entry) => entry.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // Filter entries by date range
  static List<TimesheetEntry> filterByDateRange(
    List<TimesheetEntry> entries,
    DateTime startDate,
    DateTime endDate,
  ) {
    return entries.where((entry) {
      try {
        final entryDate = DateTime.parse(entry.date);
        return entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entryDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Group entries by date
  static Map<String, List<TimesheetEntry>> groupByDate(
    List<TimesheetEntry> entries,
  ) {
    final Map<String, List<TimesheetEntry>> grouped = {};
    
    for (final entry in entries) {
      if (grouped.containsKey(entry.date)) {
        grouped[entry.date]!.add(entry);
      } else {
        grouped[entry.date] = [entry];
      }
    }
    
    return grouped;
  }

  // Group entries by project
  static Map<String, List<TimesheetEntry>> groupByProject(
    List<TimesheetEntry> entries,
  ) {
    final Map<String, List<TimesheetEntry>> grouped = {};
    
    for (final entry in entries) {
      if (grouped.containsKey(entry.project)) {
        grouped[entry.project]!.add(entry);
      } else {
        grouped[entry.project] = [entry];
      }
    }
    
    return grouped;
  }

  // Group entries by status
  static Map<String, List<TimesheetEntry>> groupByStatus(
    List<TimesheetEntry> entries,
  ) {
    final Map<String, List<TimesheetEntry>> grouped = {};
    
    for (final entry in entries) {
      if (grouped.containsKey(entry.status)) {
        grouped[entry.status]!.add(entry);
      } else {
        grouped[entry.status] = [entry];
      }
    }
    
    return grouped;
  }

  @override
  String toString() {
    return 'TimesheetEntry{date: $date, project: $project, task: $task, hours: $hours, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TimesheetEntry &&
        other.date == date &&
        other.project == project &&
        other.task == task &&
        other.hours == hours &&
        other.status == status;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        project.hashCode ^
        task.hashCode ^
        hours.hashCode ^
        status.hashCode;
  }
}