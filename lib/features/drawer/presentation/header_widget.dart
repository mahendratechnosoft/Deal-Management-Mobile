import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';

class DrawerHeaderWidget extends StatelessWidget {
  const DrawerHeaderWidget({super.key});

  /// Extract initials from full name
  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return "NA";
    }

    final parts = fullName.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<LoginResponse>(ApiConstants.boxName);

    return ValueListenableBuilder<Box<LoginResponse>>(
      valueListenable: box.listenable(),
      builder: (context, box, _) {
        final user = box.get(ApiConstants.userKey);

        final name = user?.loginUserName?.trim().isNotEmpty == true
            ? user!.loginUserName!
            : user?.loginEmail ?? "NA";

        final email = user?.loginEmail ?? "Not logged in";
        final initials = _getInitials(user?.loginUserName);

        return Container(
          margin: EdgeInsets.all(Responsive.h(10)),
          padding: EdgeInsets.all(Responsive.h(16)),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(Responsive.h(14)),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: Responsive.h(22),
                backgroundColor: Colors.blueAccent.withOpacity(0.15),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: Responsive.h(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.blueAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(width: Responsive.h(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Responsive.h(15),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Responsive.h(12),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
