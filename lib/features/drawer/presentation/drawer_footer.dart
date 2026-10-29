import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/app_update/services/app_update_service.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/drawer/bloc/drawer_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import 'logout_dialog.dart';

class DrawerFooter extends StatefulWidget {
  const DrawerFooter({super.key});

  @override
  State<DrawerFooter> createState() => _DrawerFooterState();
}

class _DrawerFooterState extends State<DrawerFooter> {
  String _version = 'v1.1.2';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = 'v${info.version}';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.h(12),
        Responsive.h(10),
        Responsive.h(12),
        Responsive.h(12),
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF334155),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sign Out Action
          InkWell(
            borderRadius: BorderRadius.circular(Responsive.h(8)),
            onTap: () async {
              final bool? shouldLogout = await showLogoutDialog(context);
              if (shouldLogout == true && context.mounted) {
                AuthLocalStorage.clear();
                context.read<LeadBloc>().add(const ResetLeadEvent());
                context.read<AuthBloc>().add(LogoutEvent());
                context.read<DrawerBloc>().add(DrawerItemSelected(0));
                context.go(AppRouteName.login);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.h(10),
                vertical: Responsive.h(8.5),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Responsive.h(10)),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.28),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.h(6)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(Responsive.h(8)),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: Responsive.h(15),
                      color: const Color(0xFFF87171),
                    ),
                  ),
                  SizedBox(width: Responsive.h(10)),
                  Expanded(
                    child: Text(
                      "Sign Out",
                      style: TextStyle(
                        fontSize: Responsive.h(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF87171),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: Responsive.h(11),
                    color: const Color(0xFFF87171).withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: Responsive.h(8)),

          // Version & Check for Updates on Tap
          InkWell(
            onTap: () {
              AppUpdateService.showUpdateDialogIfNeeded(context, isManualCheck: true);
            },
            borderRadius: BorderRadius.circular(Responsive.h(6)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.h(8),
                vertical: Responsive.h(3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "XpertBiz • $_version",
                    style: TextStyle(
                      fontSize: Responsive.h(10.5),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: Responsive.h(4)),
                  Icon(
                    Icons.sync_rounded,
                    size: Responsive.h(12),
                    color: const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
