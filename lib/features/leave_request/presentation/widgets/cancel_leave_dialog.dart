import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/responsive.dart';

Future<void> showCancelLeaveDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.h(18)),
        ),
        elevation: 8,
        insetPadding: EdgeInsets.symmetric(horizontal: Responsive.h(24)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.h(20),
            Responsive.h(22),
            Responsive.h(20),
            Responsive.h(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Alert Icon Badge
              Container(
                width: Responsive.h(58),
                height: Responsive.h(58),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFEF2F2),
                ),
                child: Center(
                  child: Container(
                    width: Responsive.h(42),
                    height: Responsive.h(42),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFEE2E2),
                    ),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: const Color(0xFFDC2626),
                      size: Responsive.h(24),
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.h(16)),

              // 2. Title
              Text(
                'Cancel Leave Request?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.h(17),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),

              SizedBox(height: Responsive.h(8)),

              // 3. Subtitle / Description
              Text(
                'Are you sure you want to cancel this leave application? Once cancelled, this request cannot be restored.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.h(12.5),
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),

              SizedBox(height: Responsive.h(22)),

              // 4. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.h(10)),
                        ),
                      ),
                      child: Text(
                        'Keep Request',
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
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.h(10)),
                        ),
                      ),
                      child: Text(
                        'Yes, Cancel',
                        style: TextStyle(
                          fontSize: Responsive.h(13),
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
      );
    },
  );
}
