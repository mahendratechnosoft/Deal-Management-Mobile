import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';

void showWeeklyTimeDialog(BuildContext context, CreateTaskState state) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: AppColors.card,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const WeeklyTimeCRMView(),
      );
    },
  );
}

/* ================= DATA MODEL ================= */

class DayData {
  final String day;
  final double hours;

  DayData(this.day, this.hours);
}

/* ================= CRM VIEW ================= */

class WeeklyTimeCRMView extends StatelessWidget {
  const WeeklyTimeCRMView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = <DayData>[
      DayData('Mon', 0.0),
      DayData('Tue', 0.0),
      DayData('Wed', 0.0),
      DayData('Thu', 0.0),
      DayData('Fri', 0.0),
      DayData('Sat', 0.9), // Active day
      DayData('Sun', 0.0),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          const SizedBox(height: 16),
          _summaryCard(data),
          const SizedBox(height: 16),
          _chartCard(data),
          const SizedBox(height: 16),
          _footer(context),
        ],
      ),
    );
  }
}

/* ================= HEADER ================= */

Widget _header(BuildContext context) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.bar_chart_rounded,
          color: Color(0xFF2563EB),
        ),
      ),
      const SizedBox(width: 12),
      const Text(
        'Weekly Time Overview',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

/* ================= SUMMARY CARD ================= */

Widget _summaryCard(List<DayData> data) {
  final totalHours = data.fold<double>(0, (sum, item) => sum + item.hours);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        _summaryItem(
          title: 'Total Time',
          value: '${totalHours.toStringAsFixed(1)} h',
          icon: Icons.timer_outlined,
        ),
        const SizedBox(width: 20),
        _summaryItem(
          title: 'Active Days',
          value: data.where((e) => e.hours > 0).length.toString(),
          icon: Icons.event_available_outlined,
        ),
      ],
    ),
  );
}

Widget _summaryItem({
  required String title,
  required String value,
  required IconData icon,
}) {
  return Expanded(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/* ================= CHART CARD ================= */

Widget _chartCard(List<DayData> data) {
  return Container(
    height: 260,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
        ),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 2,
        interval: 0.5,
        labelFormat: '{value}h',
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
        majorGridLines: MajorGridLines(
          color: Colors.grey.shade200,
          dashArray: const [4, 4],
        ),
        labelStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF64748B),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: const Color(0xFF1E293B),
        builder: (data, point, series, pointIndex, seriesIndex) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${point.x} • ${point.y} h',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
      series: <ColumnSeries<DayData, String>>[
        ColumnSeries<DayData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.day,
          yValueMapper: (d, _) => d.hours,
          borderRadius: BorderRadius.circular(10),
          width: 0.5,
          pointColorMapper: (d, _) =>
              d.hours > 0 ? const Color(0xFF2563EB) : Colors.grey.shade300,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    ),
  );
}

/* ================= FOOTER ================= */

Widget _footer(BuildContext context) {
  return Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Close',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
