import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/leave_request/data/models/leave_request_model.dart';
import 'cancel_leave_dialog.dart';
import 'leave_detail_bottom_sheet.dart';
import 'process_leave_dialog.dart';

class LeaveCard extends StatelessWidget {
  final LeaveRequestModel leave;
  final bool isApproverView;
  final bool isMyLeaveView;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final Function(String status, String? remarks)? onProcess;

  const LeaveCard({
    super.key,
    required this.leave,
    this.isApproverView = false,
    this.isMyLeaveView = true,
    this.onCancel,
    this.onEdit,
    this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.h(14),
        vertical: Responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.h(12)),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.h(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.h(12)),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => LeaveDetailBottomSheet(
                leave: leave,
                onCancel: onCancel,
                onProcess: onProcess,
                isApproverView: isApproverView,
                isMyLeaveView: isMyLeaveView,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(Responsive.h(11)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Employee Name (Full room) + Status Pill
                Row(
                  children: [
                    CircleAvatar(
                      radius: Responsive.h(13),
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        (leave.creatorName?.isNotEmpty == true)
                            ? leave.creatorName![0].toUpperCase()
                            : 'L',
                        style: TextStyle(
                          fontSize: Responsive.h(11.5),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.h(8)),
                    Expanded(
                      child: Text(
                        isMyLeaveView
                            ? (leave.creatorName ?? 'My Leave Application')
                            : (leave.creatorName ?? 'Employee'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Responsive.h(13),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.h(8)),
                    _buildStatusPill(leave.status),
                  ],
                ),

                SizedBox(height: Responsive.h(7)),

                // 2. Leave Type Chip (on its own row so it never squishes the name) + Days Count
                Row(
                  children: [
                    _buildLeaveTypeChip(leave.leaveType),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.h(7),
                        vertical: Responsive.h(2.5),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(Responsive.h(4)),
                      ),
                      child: Text(
                        leave.formattedDaysCount,
                        style: TextStyle(
                          fontSize: Responsive.h(10.5),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.h(6)),

                // 3. Compact Date Range Banner
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.h(9),
                    vertical: Responsive.h(5.5),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(Responsive.h(7)),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: Responsive.h(12),
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: Responsive.h(6)),
                      Expanded(
                        child: Text(
                          _formatDateRange(leave.startDate, leave.endDate),
                          style: TextStyle(
                            fontSize: Responsive.h(11.5),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Reason preview (if present)
                if (leave.reason.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(6)),
                  Text(
                    leave.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.h(11.5),
                      color: const Color(0xFF475569),
                      height: 1.3,
                    ),
                  ),
                ],

                // 5. Approver info (Handover completely removed as requested)
                if (leave.assignToName != null) ...[
                  SizedBox(height: Responsive.h(6)),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: Responsive.h(11.5),
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: Responsive.h(4)),
                      Expanded(
                        child: Text(
                          'Approver: ${leave.assignToName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Responsive.h(10.5),
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // 6. Divider & Bottom Action Bar (Icon Buttons)
                SizedBox(height: Responsive.h(7)),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                SizedBox(height: Responsive.h(6)),

                Row(
                  children: [
                    // Applied date tag
                    if (leave.createdAt != null) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: Responsive.h(11),
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: Responsive.h(4)),
                      Text(
                        _formatAppliedDate(leave.createdAt!),
                        style: TextStyle(
                          fontSize: Responsive.h(10.5),
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],

                    // Attachment badge (if attached file exists)
                    if (leave.hasAttachment) ...[
                      SizedBox(width: Responsive.h(6)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.h(5),
                          vertical: Responsive.h(1.5),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(Responsive.h(4)),
                          border: Border.all(color: const Color(0xFFBFDBFE), width: 0.6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: Responsive.h(10.5),
                              color: const Color(0xFF2563EB),
                            ),
                            SizedBox(width: Responsive.h(2)),
                            Text(
                              'File',
                              style: TextStyle(
                                fontSize: Responsive.h(9.5),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),

                    // Action Icon Buttons:
                    // 1. Edit (shown for PENDING leaves when onEdit is available, including All Leaves & My Leaves)
                    if (leave.isPending && onEdit != null) ...[
                      _ActionIconButton(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                        tooltip: 'Edit Leave',
                        onTap: onEdit!,
                      ),
                      SizedBox(width: Responsive.h(6)),
                    ],

                    // 2. Cancel (for applicant in My Leaves when PENDING)
                    if (leave.isPending && isMyLeaveView && onCancel != null) ...[
                      _ActionIconButton(
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEE2E2),
                        tooltip: 'Cancel Request',
                        onTap: () => _confirmCancel(context),
                      ),
                      SizedBox(width: Responsive.h(6)),
                    ],

                    // 3. Reject & Approve (for approver in Approvals OR in All Leaves section when PENDING)
                    if (leave.isPending && (isApproverView || !isMyLeaveView) && onProcess != null) ...[
                      _ActionIconButton(
                        icon: Icons.close_rounded,
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEE2E2),
                        tooltip: 'Reject Leave',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ProcessLeaveDialog(
                              isApprove: false,
                              leaveRequestId: leave.leaveRequestId,
                              onConfirm: (remarks) =>
                                  onProcess!('REJECTED', remarks),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: Responsive.h(6)),
                      _ActionIconButton(
                        icon: Icons.check_rounded,
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFDCFCE7),
                        tooltip: 'Approve Leave',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ProcessLeaveDialog(
                              isApprove: true,
                              leaveRequestId: leave.leaveRequestId,
                              onConfirm: (remarks) =>
                                  onProcess!('APPROVED', remarks),
                            ),
                          );
                        },
                      ),
                    ],

                    // If not pending, show subtle details chevron
                    if (!leave.isPending) ...[
                      Icon(
                        Icons.chevron_right_rounded,
                        size: Responsive.h(16),
                        color: const Color(0xFFCBD5E1),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveTypeChip(String leaveType) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.h(7),
        vertical: Responsive.h(2.5),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(Responsive.h(5)),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.beach_access_rounded,
            size: Responsive.h(10.5),
            color: const Color(0xFF2563EB),
          ),
          SizedBox(width: Responsive.h(3.5)),
          Text(
            leaveType,
            style: TextStyle(
              fontSize: Responsive.h(10.5),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        break;
      case 'CANCELLED':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        icon = Icons.remove_circle_outline_rounded;
        break;
      case 'PENDING':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        icon = Icons.schedule_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.h(7),
        vertical: Responsive.h(2.5),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Responsive.h(5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Responsive.h(10), color: fg),
          SizedBox(width: Responsive.h(3.5)),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: Responsive.h(9.5),
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null && end == null) return 'Dates Not Set';
    if (start != null && (end == null || start == end)) return start;
    return '$start  →  $end';
  }

  String _formatAppliedDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  void _confirmCancel(BuildContext context) {
    showCancelLeaveDialog(
      context,
      onConfirm: () => onCancel?.call(),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.h(6)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.h(6)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(Responsive.h(6)),
            child: Icon(
              icon,
              size: Responsive.h(15),
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
