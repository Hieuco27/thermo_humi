import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

enum ChartTab { temperature, humidity }

class ChartTabSelector extends StatelessWidget {
  final ChartTab selected;
  final ValueChanged<ChartTab> onChanged;

  const ChartTabSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 35.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabItem(
            label: 'Nhiệt độ',
            icon: Icons.thermostat_rounded,
            isSelected: selected == ChartTab.temperature,
            activeColor: const Color(0xFFFF6B35),
            onTap: () => onChanged(ChartTab.temperature),
          ),
          _TabItem(
            label: 'Độ ẩm',
            icon: Icons.water_drop_rounded,
            isSelected: selected == ChartTab.humidity,
            activeColor: const Color(0xFF007AFF),
            onTap: () => onChanged(ChartTab.humidity),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              SizedBox(width: 3.w),
              Text(
                label,
                style:
                    AppTextStyles.labelLarge(
                      color: isSelected ? Colors.white : Colors.grey,
                    ).copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
