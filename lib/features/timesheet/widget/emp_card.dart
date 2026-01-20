import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import '../data/model/emp_model.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                employee.name.isNotEmpty
                    ? employee.name.substring(0, 1).toUpperCase()
                    : '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Employee Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.role,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        employee.totalHoursText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.assignment, size: 14, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        '${employee.projects.length} projects',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Indicator
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: employee.avatarColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: employee.avatarColor.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Forward Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
