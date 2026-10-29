import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/leave_request/data/models/leave_request_model.dart';
import 'cancel_leave_dialog.dart';
import 'process_leave_dialog.dart';

class LeaveDetailBottomSheet extends StatelessWidget {
  final LeaveRequestModel leave;
  final VoidCallback? onCancel;
  final Function(String status, String? remarks)? onProcess;
  final bool isApproverView;
  final bool isMyLeaveView;

  const LeaveDetailBottomSheet({
    super.key,
    required this.leave,
    this.onCancel,
    this.onProcess,
    this.isApproverView = false,
    this.isMyLeaveView = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Handle
          Container(
            margin: EdgeInsets.only(top: Responsive.h(10), bottom: Responsive.h(8)),
            width: Responsive.h(38),
            height: Responsive.h(4),
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // 2. Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.h(18),
              vertical: Responsive.h(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave Details',
                        style: TextStyle(
                          fontSize: Responsive.h(17),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (leave.createdAt != null) ...[
                        SizedBox(height: Responsive.h(2)),
                        Text(
                          'Applied on ${_formatDateTime(leave.createdAt!)}',
                          style: TextStyle(
                            fontSize: Responsive.h(11.5),
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusPill(leave.status),
                SizedBox(width: Responsive.h(6)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 3. Scrollable Content
          Flexible(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.h(18),
                vertical: Responsive.h(14),
              ),
              children: [
                // Applicant Info (if available)
                if (leave.creatorName != null) ...[
                  _buildSectionCard(
                    title: 'Applicant',
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: Responsive.h(16),
                          backgroundColor: const Color(0xFF2563EB),
                          child: Text(
                            leave.creatorName!.isNotEmpty
                                ? leave.creatorName![0].toUpperCase()
                                : 'A',
                            style: TextStyle(
                              fontSize: Responsive.h(13),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.h(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leave.creatorName!,
                                style: TextStyle(
                                  fontSize: Responsive.h(13.5),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Employee',
                                style: TextStyle(
                                  fontSize: Responsive.h(11.5),
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                ],

                // Overview Grid (Leave Type & Duration)
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.beach_access_rounded,
                        iconColor: const Color(0xFF2563EB),
                        label: 'Leave Type',
                        value: leave.leaveType,
                      ),
                    ),
                    SizedBox(width: Responsive.h(10)),
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.timelapse_rounded,
                        iconColor: const Color(0xFF0D9488),
                        label: 'Total Duration',
                        value: leave.formattedDaysCount,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.h(12)),

                // Date Range & Day breakdown
                _buildSectionCard(
                  title: 'Date & Day Breakdown',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: Responsive.h(16),
                            color: const Color(0xFF2563EB),
                          ),
                          SizedBox(width: Responsive.h(6)),
                          Expanded(
                            child: Text(
                              '${leave.startDate ?? ''}  →  ${leave.endDate ?? ''}',
                              style: TextStyle(
                                fontSize: Responsive.h(13),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (leave.leaveDays.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(10)),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        SizedBox(height: Responsive.h(8)),
                        ...leave.leaveDays.map((day) => Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Responsive.h(3.5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day.date,
                                    style: TextStyle(
                                      fontSize: Responsive.h(12.5),
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.h(8),
                                      vertical: Responsive.h(2.5),
                                    ),
                                    decoration: BoxDecoration(
                                      color: day.leaveDayType == 'HALF_DAY'
                                          ? const Color(0xFFFEF3C7)
                                          : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(
                                        Responsive.h(4),
                                      ),
                                    ),
                                    child: Text(
                                      day.leaveDayType.replaceAll('_', ' '),
                                      style: TextStyle(
                                        fontSize: Responsive.h(10.5),
                                        fontWeight: FontWeight.w700,
                                        color: day.leaveDayType == 'HALF_DAY'
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: Responsive.h(12)),

                // Reason Card
                _buildSectionCard(
                  title: 'Reason for Leave',
                  child: Text(
                    leave.reason.isNotEmpty
                        ? leave.reason
                        : 'No reason provided',
                    style: TextStyle(
                      fontSize: Responsive.h(12.5),
                      color: const Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: Responsive.h(12)),

                // Approver & Handover Person
                Row(
                  children: [
                    if (leave.assignToName != null)
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.verified_user_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          label: 'Approver',
                          value: leave.assignToName!,
                        ),
                      ),
                    if (leave.assignToName != null &&
                        leave.handoverName != null)
                      SizedBox(width: Responsive.h(10)),
                    if (leave.handoverName != null)
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.handshake_rounded,
                          iconColor: const Color(0xFFEA580C),
                          label: 'Handover To',
                          value: leave.handoverName!,
                        ),
                      ),
                  ],
                ),

                // Attached File Preview / Viewer
                if (leave.hasAttachment) ...[
                  SizedBox(height: Responsive.h(12)),
                  _buildSectionCard(
                    title: 'Supporting Document',
                    child: _buildAttachmentViewer(context, leave),
                  ),
                ],

                SizedBox(height: Responsive.h(16)),
              ],
            ),
          ),

          // 4. Bottom Action Bar
          if ((leave.isPending && isMyLeaveView && onCancel != null) ||
              (leave.isPending && isApproverView && onProcess != null)) ...[
            Container(
              padding: EdgeInsets.fromLTRB(
                Responsive.h(18),
                Responsive.h(10),
                Responsive.h(18),
                Responsive.h(16),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (leave.isPending && isMyLeaveView && onCancel != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showCancelLeaveDialog(
                            context,
                            onConfirm: () => onCancel?.call(),
                          );
                        },
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: Responsive.h(16),
                          color: AppColors.error,
                        ),
                        label: Text(
                          'Cancel Application',
                          style: TextStyle(
                            fontSize: Responsive.h(13),
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFFCA5A5),
                            width: 1,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.h(11),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Responsive.h(10)),
                          ),
                        ),
                      ),
                    ),
                  if (leave.isPending && (isApproverView || !isMyLeaveView) && onProcess != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFFCA5A5),
                            width: 1,
                          ),
                          foregroundColor: AppColors.error,
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.h(11),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Responsive.h(10)),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: Responsive.h(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.h(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.h(11),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Responsive.h(10)),
                          ),
                        ),
                        child: Text(
                          'Approve',
                          style: TextStyle(
                            fontSize: Responsive.h(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.h(12)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(Responsive.h(10)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.h(11.5),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: Responsive.h(8)),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.h(10)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(Responsive.h(10)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: Responsive.h(14), color: iconColor),
              SizedBox(width: Responsive.h(5)),
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.h(11),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.h(12.5),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case 'REJECTED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      case 'CANCELLED':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        break;
      case 'PENDING':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.h(9),
        vertical: Responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Responsive.h(6)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: Responsive.h(11),
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  Widget _buildAttachmentViewer(BuildContext context, LeaveRequestModel leave) {
    final fullUrl = leave.fullAttachmentUrl ?? '';
    final fileName = leave.attachedFileUrl ?? 'Attachment';
    final isImg = leave.isAttachmentImage;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(Responsive.h(8)),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isImg && fullUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.h(8))),
              child: InkWell(
                onTap: () => _showFullScreenImage(context, fullUrl, fileName),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      fullUrl,
                      height: Responsive.h(160),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: Responsive.h(160),
                          width: double.infinity,
                          color: const Color(0xFFF8FAFC),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: Responsive.h(90),
                          width: double.infinity,
                          color: const Color(0xFFF8FAFC),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                size: Responsive.h(28),
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(height: Responsive.h(4)),
                              Text(
                                'Unable to load image preview',
                                style: TextStyle(
                                  fontSize: Responsive.h(11),
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: Responsive.h(6),
                      right: Responsive.h(6),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.h(8),
                          vertical: Responsive.h(4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(Responsive.h(6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              size: Responsive.h(13),
                              color: Colors.white,
                            ),
                            SizedBox(width: Responsive.h(3)),
                            Text(
                              'Tap to Zoom',
                              style: TextStyle(
                                fontSize: Responsive.h(10),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.h(10),
              vertical: Responsive.h(8),
            ),
            child: Row(
              children: [
                Icon(
                  isImg ? Icons.image_rounded : Icons.insert_drive_file_rounded,
                  size: Responsive.h(16),
                  color: const Color(0xFF2563EB),
                ),
                SizedBox(width: Responsive.h(6)),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.h(11.5),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (isImg && fullUrl.isNotEmpty) ...[
                  SizedBox(width: Responsive.h(6)),
                  GestureDetector(
                    onTap: () => _showFullScreenImage(context, fullUrl, fileName),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.h(8),
                        vertical: Responsive.h(3),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(Responsive.h(4)),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        'View Full',
                        style: TextStyle(
                          fontSize: Responsive.h(10.5),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(Responsive.h(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.h(13),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(8)),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Responsive.h(8)),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(24),
                      color: Colors.black54,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image:\n$url',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
