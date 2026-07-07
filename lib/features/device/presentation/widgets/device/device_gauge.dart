import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DeviceGauge extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final String unit;
  final bool hasAlert;
  final bool isDark;

  const DeviceGauge({
    super.key,
    required this.title,
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.unit,
    this.hasAlert = false,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final alertColor = const Color(0xFFFF3B30);
    final normalColor = const Color(0xFF007AFF);
    final color = hasAlert ? alertColor : normalColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.bodyLarge(color: Colors.black)),
        SizedBox(height: 16.h),
        SizedBox(
          width: 130.w,
          height: 60.w,
          child: CustomPaint(
            painter: _HalfCircleGaugePainter(
              value: value,
              min: min,
              max: max,
              color: color,
              bgColor: AppColors.textFieldHint,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: AppTextStyles.titleLarge(color: color),
        ),
        if (hasAlert)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Cảnh báo cao',
              style: AppTextStyles.bodySmall(color: alertColor),
            ),
          ),
      ],
    );
  }
}

class _HalfCircleGaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color color;
  final Color bgColor;

  _HalfCircleGaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final strokeWidth = 12.w;

    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Calculate sweep angle
    final double clampedValue = value.clamp(min, max);
    final double percentage = (clampedValue - min) / (max - min);
    final double sweepAngle = percentage * pi;

    // Draw value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      valuePaint,
    );

    // Draw Needle
    final needlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final needleAngle = pi + sweepAngle;
    final needleLength = radius - strokeWidth;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    // Needle base
    canvas.drawCircle(center, 6.r, Paint()..color = const Color(0xFF333333));
    canvas.drawLine(center, needleEnd, needlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
