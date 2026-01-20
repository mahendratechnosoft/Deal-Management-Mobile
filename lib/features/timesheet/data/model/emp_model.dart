import 'package:flutter/material.dart';

class Employee {
  final String id;
  final String name;
  final String role;
  final Color avatarColor;
  final String totalHoursText; // "2h 15m"
  final List<String> projects;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.totalHoursText,
    required this.projects,
  });

  /// ⏱ Convert "2h 15m" → total minutes (135)
  int get totalMinutes {
    final regex = RegExp(r'(\d+)h\s*(\d+)m');
    final match = regex.firstMatch(totalHoursText);
    if (match == null) return 0;

    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    return hours * 60 + minutes;
  }
}
