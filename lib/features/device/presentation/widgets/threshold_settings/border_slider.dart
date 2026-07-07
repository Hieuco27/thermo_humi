import 'package:flutter/material.dart';

class BorderedRangeSliderThumbShape extends RangeSliderThumbShape {
  final double thumbRadius;
  final double borderWidth;
  final Color borderColor;

  const BorderedRangeSliderThumbShape({
    this.thumbRadius = 8.0,
    this.borderWidth = 2.0,
    this.borderColor = Colors.red,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paintFill);

    final paintBorder = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, thumbRadius, paintBorder);
  }
}
