import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'chart_container.dart';
import 'base_line_chart.dart';

class HumidityChartWidget extends StatelessWidget {
  final List<DeviceHistoryPoint> points;
  final ThresholdEntity threshold;

  const HumidityChartWidget({
    super.key,
    required this.points,
    required this.threshold,
  });

  static const _humidColor = Color(0xFF007AFF);
  static const _humidHighColor = Color(0xFFFF9500);
  static const _humidLowColor = Color(0xFF34C759);

  DateTime _startOfDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startOfDay = _startOfDay(points.first.timestamp);
    double toHour(DateTime dt) =>
        (dt.millisecondsSinceEpoch - startOfDay.millisecondsSinceEpoch) /
        3600000.0;

    final spots = points
        .map((p) => FlSpot(toHour(p.timestamp), p.humidity))
        .toList();

    return ChartContainerWidget(
      legendItems: [
        ChartLegendItem('Ngưỡng cao', _humidHighColor, isDashed: true),
        ChartLegendItem('Ngưỡng thấp', _humidLowColor, isDashed: true),
      ],
      chart: BaseLineChart(
        spots: spots,
        lineColor: _humidColor,
        gradientColors: [
          _humidColor.withValues(alpha: 0.0),
          _humidColor.withValues(alpha: 0.0),
        ],
        minX: 0,
        maxX: 24,
        minY: 0,
        maxY: 100,
        isDark: isDark,
        startOfDay: startOfDay,
        unit: '%',
        horizontalLines: [
          HorizontalLine(
            y: threshold.humidHigh,
            color: _humidHighColor,
            strokeWidth: 1.5,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              labelResolver: (_) => '${threshold.humidHigh.toStringAsFixed(0)}%',
              style: AppTextStyles.labelSmall(color: _humidHighColor),
            ),
          ),
          HorizontalLine(
            y: threshold.humidLow,
            color: _humidLowColor,
            strokeWidth: 1.5,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.bottomRight,
              labelResolver: (_) => '${threshold.humidLow.toStringAsFixed(0)}%',
              style: AppTextStyles.labelSmall(color: _humidLowColor),
            ),
          ),
        ],
        checkAlert: (val) =>
            val > threshold.humidHigh || val < threshold.humidLow,
        alertColor: _humidHighColor,
        yInterval: 20,
      ),
    );
  }
}
