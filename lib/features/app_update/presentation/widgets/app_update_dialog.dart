import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import '../../models/app_version_model.dart';
import '../../services/app_update_service.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isMajor = updateInfo.isMajor;
    final primaryColor = isMajor ? const Color(0xFFDC2626) : const Color(0xFF2563EB);
    final badgeBgColor = isMajor ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF);
    final innerBadgeColor = isMajor ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE);
    final iconData = isMajor
        ? Icons.security_update_warning_rounded
        : Icons.rocket_launch_rounded;
    final chipLabel = isMajor ? 'REQUIRED UPDATE' : 'NEW VERSION AVAILABLE';
    final title = isMajor ? 'Critical Update Required' : 'New Update Available';

    return PopScope(
      canPop: !isMajor,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.h(20)),
        ),
        elevation: 12,
        insetPadding: EdgeInsets.symmetric(horizontal: Responsive.h(20)),
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
              // 1. Top Icon Badge
              Container(
                width: Responsive.h(62),
                height: Responsive.h(62),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeBgColor,
                ),
                child: Center(
                  child: Container(
                    width: Responsive.h(46),
                    height: Responsive.h(46),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: innerBadgeColor,
                    ),
                    child: Icon(
                      iconData,
                      color: primaryColor,
                      size: Responsive.h(26),
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.h(12)),

              // 2. Chip Tag (Required / Optional)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.h(9),
                  vertical: Responsive.h(3),
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(Responsive.h(6)),
                  border: Border.all(
                    color: isMajor ? const Color(0xFFFCA5A5) : const Color(0xFFBFDBFE),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontSize: Responsive.h(10),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: primaryColor,
                  ),
                ),
              ),

              SizedBox(height: Responsive.h(10)),

              // 3. Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.h(17.5),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),

              SizedBox(height: Responsive.h(6)),

              // 4. Subtitle / Prompt
              Text(
                isMajor
                    ? 'A major update is required to continue using the Xpertbiz app safely and access latest features.'
                    : 'A new minor update is available with performance improvements and bug fixes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.h(12),
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),

              SizedBox(height: Responsive.h(14)),

              // 5. Version Comparison Banner
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.h(12),
                  vertical: Responsive.h(8),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(Responsive.h(10)),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'v${updateInfo.currentVersion}',
                      style: TextStyle(
                        fontSize: Responsive.h(12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.h(10)),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: Responsive.h(15),
                        color: primaryColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.h(8),
                        vertical: Responsive.h(2.5),
                      ),
                      decoration: BoxDecoration(
                        color: isMajor ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(Responsive.h(5)),
                      ),
                      child: Text(
                        'v${updateInfo.storeVersion}',
                        style: TextStyle(
                          fontSize: Responsive.h(11.5),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.h(14)),

              // 6. What's New Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.h(11)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(Responsive.h(10)),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: Responsive.h(13),
                          color: const Color(0xFF2563EB),
                        ),
                        SizedBox(width: Responsive.h(5)),
                        Text(
                          "WHAT'S NEW",
                          style: TextStyle(
                            fontSize: Responsive.h(10.5),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(8)),
                    ...updateInfo.releaseNotes.map(
                      (note) => Padding(
                        padding: EdgeInsets.only(bottom: Responsive.h(4)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: Responsive.h(12),
                                color: const Color(0xFF2563EB),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                note,
                                style: TextStyle(
                                  fontSize: Responsive.h(11.5),
                                  color: const Color(0xFF475569),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.h(18)),

              // 7. Action Buttons
              if (isMajor) ...[
                // Major Update: Single Full-Width Primary Action (NO SKIP)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AppUpdateService.openStore();
                    },
                    icon: Icon(
                      Icons.system_update_rounded,
                      size: Responsive.h(17),
                      color: Colors.white,
                    ),
                    label: Text(
                      'Update to Continue',
                      style: TextStyle(
                        fontSize: Responsive.h(13.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(12.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.h(10)),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Minor Update: Skip/Later option + Update Now
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(11)),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.h(10)),
                          ),
                        ),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            fontSize: Responsive.h(13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.h(10)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AppUpdateService.openStore();
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.download_rounded,
                          size: Responsive.h(16),
                          color: Colors.white,
                        ),
                        label: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: Responsive.h(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(11)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.h(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
