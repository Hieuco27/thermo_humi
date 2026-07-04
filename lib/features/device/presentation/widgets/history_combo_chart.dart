import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:intl/intl.dart';

class HistoryComboChart extends StatelessWidget {
  final DeviceHistoryDataEntity historyData;

  const HistoryComboChart({super.key, required this.historyData});

  @override
  Widget build(BuildContext context) {
    // Derive dark mode from theme so colors are always visible
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (historyData.points.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu',
          style: AppTextStyles.bodyMedium(color: Colors.grey),
        ),
      );
    }

    final points = historyData.points;
    final threshold = historyData.threshold;

    // Sort points by timestamp ascending
    final sortedPoints = List<DeviceHistoryPoint>.from(points)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // X-axis: normalize to hours 0.0–24.0
    // fl_chart places ticks at ceil(minX/interval)*interval, so using epoch ms
    // with a 2h interval causes ticks to land on odd hours (1,3,5...).
    // Normalizing to hours makes tick math exact: interval=2 → ticks at 0,2,4,...,24
    final firstDate = sortedPoints.first.timestamp;
    final startOfDay = DateTime(firstDate.year, firstDate.month, firstDate.day);
    final startEpochMs = startOfDay.millisecondsSinceEpoch;

    // Convert timestamp → hour offset (0.0 to 24.0)
    double toHour(DateTime dt) =>
        (dt.millisecondsSinceEpoch - startEpochMs) / 3600000.0;

    const double minX = 0.0;
    const double maxX = 24.0;

    // Y-axis: fixed 0–100
    const double minY = 0;
    const double maxY = 105;

    final tempSpots = sortedPoints
        .map((p) => FlSpot(toHour(p.timestamp), p.temperature))
        .toList();
    final humidSpots = sortedPoints
        .map((p) => FlSpot(toHour(p.timestamp), p.humidity))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Legend
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Nhiệt độ', const Color(0xFF007AFF)),
              _buildLegendItem('Độ ẩm', const Color(0xFF34C759)),
              _buildLegendItem(
                'Ngưỡng cao',
                const Color(0xFFFF3B30),
                isDashed: true,
              ),
              _buildLegendItem(
                'Ngưỡng thấp',
                const Color(0xFF5AC8FA),
                isDashed: true,
              ),
            ],
          ),
        ),
        // Chart
        SizedBox(
          height: 220.h,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              // Clip lines so they never render outside the 0–24h / 0–100 frame
              clipData: const FlClipData.all(),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      // Decode hour back to HH:mm
                      final dt = startOfDay.add(
                        Duration(milliseconds: (spot.x * 3600000).round()),
                      );
                      final timeStr = DateFormat('HH:mm').format(dt);
                      final isTemp = spot.barIndex == 0;
                      return LineTooltipItem(
                        '$timeStr\n${spot.y.toStringAsFixed(1)}${isTemp ? '\u00b0C' : '%'}',
                        AppTextStyles.bodyMedium(
                          color: isTemp
                              ? const Color(0xFF007AFF)
                              : const Color(0xFF34C759),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                // Draw a subtle horizontal guide line every 20 units (20,40,60,80,100)
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 40.w,
                    getTitlesWidget: (value, meta) {
                      final rounded = value.round();
                      if (rounded % 20 == 0 &&
                          rounded >= 20 &&
                          rounded <= 100) {
                        return Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Text(
                            '$rounded',
                            style: AppTextStyles.labelSmall(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // ── Bottom axis: 0h, 4h, 8h, 12h, 18h, 24h ────────────
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    // interval=2h in normalized hours; ticks land at 0,2,4,...,24
                    interval: 2,
                    reservedSize: 28.h,
                    getTitlesWidget: (value, meta) {
                      final h = value.round();
                      // Whitelist: 0h, 4h, 8h, 12h, 18h, 24h
                      const wanted = {0, 4, 8, 12, 18, 24};
                      if (!wanted.contains(h)) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          '${h}h',
                          style: AppTextStyles.labelSmall(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Temperature Line
                LineChartBarData(
                  spots: tempSpots,
                  isCurved: true,
                  color: const Color(0xFF007AFF),
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      return spot.y > threshold.tempHigh ||
                          spot.y < threshold.tempLow;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFFFF3B30),
                        strokeWidth: 0,
                      );
                    },
                  ),
                ),
                // Humidity Line
                LineChartBarData(
                  spots: humidSpots,
                  isCurved: true,
                  color: const Color(0xFF34C759),
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      return spot.y > threshold.humidHigh ||
                          spot.y < threshold.humidLow;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFFFF3B30),
                        strokeWidth: 0,
                      );
                    },
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: threshold.tempHigh,
                    color: const Color(0xFFFF3B30),
                    strokeWidth: 1.5,
                    dashArray: [5, 5],
                  ),
                  HorizontalLine(
                    y: threshold.tempLow,
                    color: const Color(0xFF5AC8FA),
                    strokeWidth: 1.5,
                    dashArray: [5, 5],
                  ),
                  HorizontalLine(
                    y: threshold.humidHigh,
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.5),
                    strokeWidth: 1.5,
                    dashArray: [5, 5],
                  ),
                  HorizontalLine(
                    y: threshold.humidLow,
                    color: const Color(0xFF5AC8FA).withValues(alpha: 0.5),
                    strokeWidth: 1.5,
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed
                ? Border(
                    bottom: BorderSide(
                      color: color,
                      width: 2.h,
                      style: BorderStyle.solid,
                    ),
                  )
                : null,
          ),
          child: isDashed
              ? CustomPaint(painter: _DashedLinePainter(color))
              : null,
        ),
        SizedBox(width: 6.w),
        Text(label, style: AppTextStyles.titleSmall2(color: Colors.grey)),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 4, dashSpace = 4, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
