import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/bloc/user_role.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import '../../auth/data/locale_data/login_response.dart';
import '../block/timesheet_bloc.dart';
import '../block/timesheet_event.dart';
import '../block/timesheet_state.dart';
import '../data/model/emp_model.dart';
import '../presentation/emp_helper.dart';
import '../widget/emp_card.dart';
import 'attendance_mark.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final String _currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final controller = TextEditingController();
  LoginResponse? user = AuthLocalStorage.getUser();
  final role = RoleResolver.rolePath;

  @override
  void initState() {
    super.initState();
    _resetAndFetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ModalRoute.of(context)!.isCurrent) {
      _resetAndFetchData();
    }
  }

  void _resetAndFetchData() {
    // Reset bloc state to employee list mode
    context.read<TimeSheetBloc>().add(ResetToEmployeeList(_currentDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: 'Timesheet'),
      body: BlocBuilder<TimeSheetBloc, TimeSheetState>(
        builder: (context, state) {
          if (state is! TimeSheetLoading &&
              state is! TimeSheetLoaded &&
              state is! TimeSheetEmpty &&
              state is! TimeSheetError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resetAndFetchData();
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TimeSheetState state) {
    if (state is TimeSheetLoading) {
      return SkeletonCard(isLoading: true, itemCount: 10);
    }

    if (state is TimeSheetError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetAndFetchData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is TimeSheetLoaded) {
      final apiList = state.employees;
      // if (apiList.isEmpty) {
      //   return _buildEmptyState(context);
      // }

      final employees = apiList.map(EmployeeMapper.fromApi).toList();
      final activeCount = apiList.where((e) => e.status).length;
      final activeEmployees =
          employees.where((e) => e.totalMinutes > 0).toList();

      final avgMinutes = activeEmployees.isEmpty
          ? 0
          : activeEmployees
                  .map((e) => e.totalMinutes)
                  .reduce((a, b) => a + b) ~/
              activeEmployees.length;

      final avgHoursText = "${avgMinutes ~/ 60}h ${avgMinutes % 60}m";

      return RefreshIndicator(
        onRefresh: () async {
          _resetAndFetchData();
        },
        child: Column(
          children: [
            role == 'employee'
                ? SizedBox.shrink()
                : _buildHeader(
                    total: employees.length,
                    active: activeCount,
                    avgHoursText: avgHoursText,
                  ),
            role == 'employee'
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: CheckInOutWidget(),
                  )
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    child: AppTextField(
                      prefixIcon: Icon(Icons.search),
                      hint: 'Search',
                      controller: controller,
                      onChanged: (value) {
                        context
                            .read<TimeSheetBloc>()
                            .add(FilterEmployees(value));
                      },
                    ),
                  ),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: employees.length,
                  itemBuilder: (cnxt, i) {
                    return EmployeeCard(
                      employee: employees[i],
                      onTap: () => fetchMonthAttendance(context, employees[i]),
                    );
                  }),
            ),
          ],
        ),
      );
    }

    if (state is TimeSheetEmpty) {
      return _buildEmptyState(context);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No employees found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _resetAndFetchData,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required int total,
    required int active,
    required String avgHoursText,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Employees', '$total', Icons.group, Colors.blue),
          _buildStatItem(
              'Active Today', '$active', Icons.check_circle, Colors.green),
          _buildStatItem(
              'Avg Hours', avgHoursText, Icons.access_time, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void fetchMonthAttendance(BuildContext context, Employee employee) {
    final now = DateTime.now();

    final String monthStartDate = DateFormat('yyyy-MM-dd').format(
      DateTime(now.year, now.month, 1),
    );

    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    context.read<TimeSheetBloc>().add(
          FetchEmpMonthAttendance(
            fromDate: currentDate,
            toDate: monthStartDate,
            employeeId: employee.id,
          ),
        );
    context.push(AppRouteName.attendance, extra: employee);
  }
}
