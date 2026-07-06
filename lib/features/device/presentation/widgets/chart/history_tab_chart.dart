import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'components/chart_tab_selector.dart';
import 'components/chart_container.dart';
import 'components/base_line_chart.dart';

class HistoryTabChart extends StatefulWidget {
  final DeviceHistoryDataEntity historyData;

  const HistoryTabChart({super.key, required this.historyData});

  @override
  State<HistoryTabChart> createState() => _HistoryTabChartState();
}

class _HistoryTabChartState extends State<HistoryTabChart> {
  ChartTab _selectedTab = ChartTab.temperature;

  static const _tempColor = Color(0xFFFF6B35);
  static const _humidColor = Color(0xFF007AFF);
  static const _tempHighColor = Color(0xFFFF3B30);
  static const _tempLowColor = Color(0xFF5AC8FA);
  static const _humidHighColor = Color(0xFFFF9500);
  static const _humidLowColor = Color(0xFF34C759);

  void _switchTab(ChartTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.historyData.points.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu',
          style: AppTextStyles.bodyMedium(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChartTabSelector(selected: _selectedTab, onChanged: _switchTab),
        SizedBox(height: 16.h),
        _selectedTab == ChartTab.temperature
            ? _buildTemperatureChart()
            : _buildHumidityChart(),
      ],
    );
  }

  Widget _buildTemperatureChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = _sortedPoints;
    final startOfDay = _startOfDay(points.first.timestamp);
    double toHour(DateTime dt) =>
        (dt.millisecondsSinceEpoch - startOfDay.millisecondsSinceEpoch) /
        3600000.0;

    final spots = points
        .map((p) => FlSpot(toHour(p.timestamp), p.temperature))
        .toList();
    final threshold = widget.historyData.threshold;
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
          _tempColor.withValues(alpha: 0.3),
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

  Widget _buildHumidityChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = _sortedPoints;
    final startOfDay = _startOfDay(points.first.timestamp);
    double toHour(DateTime dt) =>
        (dt.millisecondsSinceEpoch - startOfDay.millisecondsSinceEpoch) /
        3600000.0;

    final spots = points
        .map((p) => FlSpot(toHour(p.timestamp), p.humidity))
        .toList();
    final threshold = widget.historyData.threshold;

    return ChartContainerWidget(
      legendItems: [
        ChartLegendItem('Ngưỡng cao', _humidHighColor, isDashed: true),
        ChartLegendItem('Ngưỡng thấp', _humidLowColor, isDashed: true),
      ],
      chart: BaseLineChart(
        spots: spots,
        lineColor: _humidColor,
        gradientColors: [
          _humidColor.withValues(alpha: 0.25),
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
              labelResolver: (_) =>
                  '${threshold.humidHigh.toStringAsFixed(0)}%',
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

  List<DeviceHistoryPoint> get _sortedPoints {
    final pts = List<DeviceHistoryPoint>.from(widget.historyData.points);
    pts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return pts;
  }

  DateTime _startOfDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }
}
