import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class BaseLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color lineColor;
  final List<Color> gradientColors;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool isDark;
  final DateTime startOfDay;
  final String unit;
  final List<HorizontalLine> horizontalLines;
  final bool Function(double) checkAlert;
  final Color alertColor;
  final double? yInterval;

  const BaseLineChart({
    super.key,
    required this.spots,
    required this.lineColor,
    required this.gradientColors,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.isDark,
    required this.startOfDay,
    required this.unit,
    required this.horizontalLines,
    required this.checkAlert,
    required this.alertColor,
    this.yInterval,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? const Color(0xFF2C2C2E) : Colors.white,
              tooltipRoundedRadius: 10,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dt = startOfDay.add(
                    Duration(milliseconds: (spot.x * 3600000).round()),
                  );
                  final timeStr = DateFormat('HH:mm').format(dt);
                  return LineTooltipItem(
                    '$timeStr\n${spot.y.toStringAsFixed(1)}$unit',
                    AppTextStyles.bodyMedium(color: lineColor),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval ?? (maxY - minY) / 5,
            getDrawingHorizontalLine: (_) => FlLine(
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
                interval: yInterval ?? (maxY - minY) / 4,
                reservedSize: 32.w,
                getTitlesWidget: (value, meta) {
                  // Luôn hiển thị mốc
                  return Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: AppTextStyles.labelSmall(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                reservedSize: 30.h,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}h',
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
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white24 : Colors.black26,
                width: 1,
              ),
              left: BorderSide(
                color: isDark ? Colors.white24 : Colors.black26,
                width: 1,
              ),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => checkAlert(spot.y),
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: alertColor,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(horizontalLines: horizontalLines),
        ),
      ),
    );
  }
}
