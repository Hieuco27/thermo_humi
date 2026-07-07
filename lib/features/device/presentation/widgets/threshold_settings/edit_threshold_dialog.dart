import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class EditThresholdDialog extends StatefulWidget {
  final double currentValue;
  final bool isMin;
  final RangeValues currentRange;
  final String suffixText;
  final Color primaryColor;
  final void Function(double newMin, double newMax) onSave;

  const EditThresholdDialog({
    super.key,
    required this.currentValue,
    required this.isMin,
    required this.currentRange,
    required this.suffixText,
    required this.primaryColor,
    required this.onSave,
  });

  @override
  State<EditThresholdDialog> createState() => _EditThresholdDialogState();
}

class _EditThresholdDialogState extends State<EditThresholdDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentValue.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      title: Text(
        widget.isMin ? 'Nhập ngưỡng thấp' : 'Nhập ngưỡng cao',
        style: AppTextStyles.bodyLarge(),
      ),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          suffixText: widget.suffixText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.primaryColor),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final double? newValue = double.tryParse(
              _controller.text.replaceAll(',', '.'),
            );
            if (newValue != null) {
              double newMin = widget.isMin
                  ? newValue
                  : widget.currentRange.start;
              double newMax = widget.isMin ? widget.currentRange.end : newValue;

              if (newMin > newMax) {
                if (widget.isMin) {
                  newMax = newMin;
                } else {
                  newMin = newMax;
                }
              }

              widget.onSave(newMin.clamp(0.0, 100.0), newMax.clamp(0.0, 100.0));
            }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: const Text(
            'Lưu',
            style: TextStyle(color: AppColors.background),
          ),
        ),
      ],
    );
  }
}
