import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'chart_container.dart';
import 'base_line_chart.dart';

class TemperatureChartWidget extends StatelessWidget {
  final List<DeviceHistoryPoint> points;
  final ThresholdEntity threshold;

  const TemperatureChartWidget({
    super.key,
    required this.points,
    required this.threshold,
  });

  static const _tempColor = Color(0xFFFF6B35);
  static const _tempHighColor = Color(0xFFFF3B30);
  static const _tempLowColor = Color(0xFF5AC8FA);

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
        .map((p) => FlSpot(toHour(p.timestamp), p.temperature))
        .toList();
    final values = spots.map((s) => s.y).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) - 5).clamp(0.0, 200.0);
    final maxY = (values.reduce((a, b) => a > b ? a : b) + 8).clamp(0.0, 200.0);

    return ChartContainerWidget(
      legendItems: [
        ChartLegendItem('Ngưỡng cao', _tempHighColor, isDashed: true),
        ChartLegendItem('Ngưỡng thấp', _tempLowColor, isDashed: true),
      ],
      chart: BaseLineChart(
        spots: spots,
        lineColor: _tempColor,
        gradientColors: [
          _tempColor.withValues(alpha: 0.0),
          _tempColor.withValues(alpha: 0.0),
        ],
        minX: 0,
        maxX: 24,
        minY: minY,
        maxY: maxY,
        isDark: isDark,
        startOfDay: startOfDay,
        unit: '°C',
        horizontalLines: [
          HorizontalLine(
            y: threshold.tempHigh,
            color: _tempHighColor,
            strokeWidth: 1.5,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              labelResolver: (_) => '${threshold.tempHigh.toStringAsFixed(0)}°',
              style: AppTextStyles.labelSmall(color: _tempHighColor),
            ),
          ),
          HorizontalLine(
            y: threshold.tempLow,
            color: _tempLowColor,
            strokeWidth: 1.5,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.bottomRight,
              labelResolver: (_) => '${threshold.tempLow.toStringAsFixed(0)}°',
              style: AppTextStyles.labelSmall(color: _tempLowColor),
            ),
          ),
        ],
        checkAlert: (val) =>
            val > threshold.tempHigh || val < threshold.tempLow,
        alertColor: _tempHighColor,
      ),
    );
  }
}
