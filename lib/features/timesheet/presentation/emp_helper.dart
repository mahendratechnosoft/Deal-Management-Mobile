import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:xpertbiz/features/timesheet/data/model/get_all_emp_status.dart';
import '../data/model/emp_model.dart';

class EmployeeMapper {
  static Employee fromApi(GetAllEmpStatusModel api) {
    log('status check : ${api.status}');

    final DateTime? eventTime = api.timeStamp != null
        ? DateTime.fromMillisecondsSinceEpoch(api.timeStamp!)
        : null;

    // ✅ Handle session tracking correctly
    if (api.status && eventTime != null) {
      HrSessionTracker.saveCheckIn(api.employeeId, eventTime);
    } else {
      HrSessionTracker.clear(api.employeeId); // 👈 IMPORTANT
    }

    final DateTime? checkIn = HrSessionTracker.getCheckIn(api.employeeId);

    final String hoursText =
        _calculateHoursWithMinutes(api.status, checkIn, eventTime);

    return Employee(
      id: api.employeeId,
      name: api.employeeName,
      role: api.role,
      avatarColor: api.status ? Colors.green : Colors.grey,
      totalHoursText: hoursText,
      projects: [api.department],
    );
  }

  static String _calculateHoursWithMinutes(
    bool status,
    DateTime? checkIn,
    DateTime? eventTime,
  ) {
    if (checkIn == null) return "0h 0m";

    Duration diff;

    // Running (checked-in)
    if (status) {
      diff = DateTime.now().difference(checkIn);
    }
    // Checked-out
    else if (eventTime != null) {
      diff = eventTime.difference(checkIn);
    } else {
      return "0h 0m";
    }

    if (diff.isNegative) return "0h 0m";

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    return "${hours}h ${minutes}m";
  }
}

class HrSessionTracker {
  static final Map<String, DateTime> _checkInMap = {};

  static void saveCheckIn(String empId, DateTime time) {
    _checkInMap[empId] = time; // ✅ overwrite
  }

  static DateTime? getCheckIn(String empId) {
    return _checkInMap[empId];
  }

  static void clear(String empId) {
    _checkInMap.remove(empId);
  }
}
