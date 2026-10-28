import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/drawer/bloc/drawer_bloc.dart';
import '../../app_route_name.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthLocalStorage.getUser();

    final menuItems = <DrawerMenuItem>[
      DrawerMenuItem(
        title: 'Leads',
        icon: Icons.leaderboard_rounded,
        route: AppRouteName.dashboard,
        visible: user?.moduleAccess.leadAccess == true,
      ),
      DrawerMenuItem(
        title: 'Timesheets',
        icon: Icons.access_time_rounded,
        route: AppRouteName.timesheet,
        visible: user?.moduleAccess.timeSheetAccess == true,
      ),
      DrawerMenuItem(
        title: 'Task',
        icon: Icons.task_alt_rounded,
        route: AppRouteName.task,
        visible: user?.moduleAccess.taskAccess == true,
      ),
      DrawerMenuItem(
        title: 'Customers',
        icon: Icons.people_alt_rounded,
        route: AppRouteName.customers,
        visible: user?.moduleAccess.customerAccess == true,
      ),
    ].where((item) => item.visible).toList();

    return Expanded(
      child: BlocBuilder<DrawerBloc, DrawerState>(
        builder: (context, state) {
          String currentPath = '';
          try {
            currentPath = GoRouterState.of(context).uri.path;
          } catch (_) {}

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.h(16),
                  Responsive.h(12),
                  Responsive.h(16),
                  Responsive.h(6),
                ),
                child: Text(
                  "MAIN MENU",
                  style: TextStyle(
                    fontSize: Responsive.h(10.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.h(12),
                    vertical: Responsive.h(4),
                  ),
                  itemCount: menuItems.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: Responsive.h(4)),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final isActive = currentPath.isNotEmpty
                        ? currentPath == item.route
                        : state.selectedIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF1E293B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(Responsive.h(10)),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF334155)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Responsive.h(8)),
                        splashColor: Colors.white.withValues(alpha: 0.06),
                        onTap: () {
                          context
                              .read<DrawerBloc>()
                              .add(DrawerItemSelected(index));
                          Navigator.pop(context);
                          final path = GoRouterState.of(context).uri.path;
                          if (path != item.route) {
                            context.push(item.route);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.h(8),
                            vertical: Responsive.h(7),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(Responsive.h(6.5)),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF1E293B),
                                  borderRadius:
                                      BorderRadius.circular(Responsive.h(7)),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: Responsive.h(17),
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              SizedBox(width: Responsive.h(12)),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: Responsive.h(13.5),
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFFCBD5E1),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  width: Responsive.h(3.5),
                                  height: Responsive.h(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
