import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void showWeeklyTimeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      title: Row(
        children: const [
          Icon(Icons.calendar_today_rounded, color: Colors.blue, size: 26),
          SizedBox(width: 12),
          Text(
            "Weekly Time Distribution",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: const WeeklyTimeBarChart(),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueGrey[700],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            "Close",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class DayData {
  final String day;
  final double hours;
  final Color color;

  DayData(this.day, this.hours, {required this.color});
}

class WeeklyTimeBarChart extends StatelessWidget {
  const WeeklyTimeBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DayData> data = [
      DayData('Mon', 0.0, color: const Color(0xFFE3F2FD)),
      DayData('Tue', 0.0, color: const Color(0xFFE3F2FD)),
      DayData('Wed', 0.0, color: const Color(0xFFE3F2FD)),
      DayData('Thu', 0.0, color: const Color(0xFFE3F2FD)),
      DayData('Fri', 0.0, color: const Color(0xFFE3F2FD)),
      DayData('Sat', 0.9, color: const Color(0xFF1976D2)), // Highlight
      DayData('Sun', 0.0, color: const Color(0xFFE3F2FD)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SfCartesianChart(
          margin: const EdgeInsets.all(16),
          title: ChartTitle(
            text: 'Time Spent This Week',
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          primaryXAxis: CategoryAxis(
            labelPlacement: LabelPlacement.onTicks,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF616161),
            ),
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 1.5,
            interval: 0.3,
            labelFormat: '{value}h',
            labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
            majorGridLines: MajorGridLines(
              width: 1,
              color: Colors.grey[300]!,
              dashArray: const <double>[5, 5],
            ),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(width: 0),
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            color: Colors.blueGrey[900]!.withOpacity(0.9),
            // borderRadius: 12,
            shadowColor: Colors.black26,
            elevation: 6,
            animationDuration: 300,
            duration: 3500,
            canShowMarker: false,
            builder: (data, point, series, pointIndex, seriesIndex) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900]!.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${point.x} • ${point.y!.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
          plotAreaBorderWidth: 0,
          series: <ColumnSeries<DayData, String>>[
            ColumnSeries<DayData, String>(
              dataSource: data,
              xValueMapper: (DayData d, _) => d.day,
              yValueMapper: (DayData d, _) => d.hours,
              pointColorMapper: (DayData d, _) => d.color,
              borderRadius:
                  const BorderRadius.all(Radius.circular(12)), // Pill bars
              width: 0.6,
              animationDuration: 1200,
              enableTooltip: true,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
              ),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                showZeroValue: false,
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: const TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
