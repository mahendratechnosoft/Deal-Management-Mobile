import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/responsive.dart';

class ProcessLeaveDialog extends StatefulWidget {
  final bool isApprove;
  final String leaveRequestId;
  final Function(String? remarks) onConfirm;

  const ProcessLeaveDialog({
    super.key,
    required this.isApprove,
    required this.leaveRequestId,
    required this.onConfirm,
  });

  @override
  State<ProcessLeaveDialog> createState() => _ProcessLeaveDialogState();
}

class _ProcessLeaveDialogState extends State<ProcessLeaveDialog> {
  final TextEditingController _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (!widget.isApprove) {
      if (!_formKey.currentState!.validate()) return;
    }
    Navigator.pop(context);
    widget.onConfirm(_remarksController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = widget.isApprove ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final lightBgColor = widget.isApprove ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final badgeBgColor = widget.isApprove ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final iconData = widget.isApprove ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded;
    final title = widget.isApprove ? 'Approve Leave Request' : 'Reject Leave Request';
    final actionBtnText = widget.isApprove ? 'Confirm Approval' : 'Confirm Rejection';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.h(18)),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.h(22)),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Responsive.h(20),
            Responsive.h(22),
            Responsive.h(20),
            Responsive.h(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Status Badge Icon
              Container(
                width: Responsive.h(58),
                height: Responsive.h(58),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lightBgColor,
                ),
                child: Center(
                  child: Container(
                    width: Responsive.h(42),
                    height: Responsive.h(42),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeBgColor,
                    ),
                    child: Icon(
                      iconData,
                      color: actionColor,
                      size: Responsive.h(24),
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.h(14)),

              // 2. Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.h(17),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),

              SizedBox(height: Responsive.h(6)),

              // 3. Subtitle / Prompt
              Text(
                widget.isApprove
                    ? 'Are you sure you want to approve this leave application? You can provide optional remarks below.'
                    : 'Please specify the reason for rejecting this leave application to inform the employee.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.h(12),
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),

              SizedBox(height: Responsive.h(16)),

              // 4. Remarks Input Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.isApprove ? 'Remarks (Optional)' : 'Reason for Rejection *',
                  style: TextStyle(
                    fontSize: Responsive.h(11.5),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(6)),
              TextFormField(
                controller: _remarksController,
                maxLines: 3,
                style: TextStyle(
                  fontSize: Responsive.h(12.5),
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: widget.isApprove
                      ? 'Add any approval comments or notes...'
                      : 'e.g. Schedule conflicts, pending project deadlines...',
                  hintStyle: TextStyle(
                    fontSize: Responsive.h(12),
                    color: const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.all(Responsive.h(10)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.h(10)),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.h(10)),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.h(10)),
                    borderSide: BorderSide(color: actionColor, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (!widget.isApprove) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a reason for rejection';
                    }
                  }
                  return null;
                },
              ),

              SizedBox(height: Responsive.h(20)),

              // 5. Dual Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.h(10)),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: Responsive.h(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.h(10)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.h(10)),
                        ),
                      ),
                      child: Text(
                        actionBtnText,
                        style: TextStyle(
                          fontSize: Responsive.h(12.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
