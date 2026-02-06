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
        title: 'Task',
        icon: Icons.dashboard,
        route: AppRouteName.task,
        visible: user?.moduleAccess.taskAccess == true,
      ),
      DrawerMenuItem(
        title: 'Timesheets',
        icon: Icons.people,
        route: AppRouteName.timesheet,
        visible: user?.moduleAccess.timeSheetAccess == true,
      ),
      DrawerMenuItem(
        title: 'Customers',
        icon: Icons.receipt_long,
        route: AppRouteName.customers,
        visible: user?.moduleAccess.customerAccess == true,
      ),
    ].where((item) => item.visible).toList();

    return Expanded(
      child: BlocBuilder<DrawerBloc, DrawerState>(
        builder: (context, state) {
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
            itemCount: menuItems.length,
            separatorBuilder: (_, __) => SizedBox(height: Responsive.h(6)),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isActive = state.selectedIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.symmetric(
                  horizontal: Responsive.h(10),
                ),
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFF1E293B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(Responsive.h(12)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Responsive.h(12)),
                  splashColor: Colors.white.withOpacity(0.08),
                  onTap: () {
                    context.read<DrawerBloc>().add(DrawerItemSelected(index));
                    context.push(item.route);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.h(16),
                      vertical: Responsive.h(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: Responsive.h(22),
                          color: isActive ? Colors.white : Colors.white70,
                        ),
                        SizedBox(width: Responsive.h(16)),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: Responsive.h(15),
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            width: Responsive.h(4),
                            height: Responsive.h(24),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
