import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ChartContainerWidget extends StatelessWidget {
  final List<ChartLegendItem> legendItems;
  final Widget chart;

  const ChartContainerWidget({super.key, required this.legendItems, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 14.w,
          runSpacing: 6.h,
          alignment: WrapAlignment.center,
          children: legendItems.map((item) => item.build()).toList(),
        ),
        SizedBox(height: 12.h),
        chart,
      ],
    );
  }
}

class ChartLegendItem {
  final String label;
  final Color color;
  final bool isDashed;

  const ChartLegendItem(this.label, this.color, {this.isDashed = false});

  Widget build() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18.w,
          height: 10.h,
          child: isDashed
              ? CustomPaint(painter: _DashedPainter(color))
              : Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: AppTextStyles.labelSmall(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  _DashedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 4, dashSpace = 3, startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset((startX + dashWidth).clamp(0, size.width), y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
