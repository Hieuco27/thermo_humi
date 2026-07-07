import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'components/chart_tab_selector.dart';
import 'components/temperature_chart_widget.dart';
import 'components/humidity_chart_widget.dart';

class HistoryTabChart extends StatefulWidget {
  final DeviceHistoryDataEntity historyData;

  const HistoryTabChart({super.key, required this.historyData});

  @override
  State<HistoryTabChart> createState() => _HistoryTabChartState();
}

class _HistoryTabChartState extends State<HistoryTabChart> {
  ChartTab _selectedTab = ChartTab.temperature;

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
        SizedBox(height: 12.h),
        _selectedTab == ChartTab.temperature
            ? TemperatureChartWidget(
                points: _sortedPoints,
                threshold: widget.historyData.threshold,
              )
            : HumidityChartWidget(
                points: _sortedPoints,
                threshold: widget.historyData.threshold,
              ),
      ],
    );
  }

  List<DeviceHistoryPoint> get _sortedPoints {
    final pts = List<DeviceHistoryPoint>.from(widget.historyData.points);
    pts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return pts;
  }
}
