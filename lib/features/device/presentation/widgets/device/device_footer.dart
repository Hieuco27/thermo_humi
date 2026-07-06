import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DeviceFooter extends StatelessWidget {
  final Color cardBg;

  const DeviceFooter({super.key, required this.cardBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterItem(
            icon: Icons.signal_cellular_alt,
            title: '4G Signal Strength',
            value: 'Weak',
            valueColor: const Color(0xFFFF3B30),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          _buildFooterItem(
            icon: Icons.battery_charging_full,
            title: 'Battery',
            value: '65%',
            valueColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 28.sp),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodySmall(color: Colors.grey)),
            SizedBox(height: 4.h),
            Text(value, style: AppTextStyles.titleMedium(color: valueColor)),
          ],
        ),
      ],
    );
  }
}
