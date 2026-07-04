import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';

class DeviceEmptyState extends StatelessWidget {
  final DeviceFilterType filter;

  const DeviceEmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final String message;
    final IconData icon;

    switch (filter) {
      case DeviceFilterType.online:
        icon = Icons.wifi_off_rounded;
        message = 'Không có thiết bị online';
        break;
      case DeviceFilterType.offline:
        icon = Icons.sensors_off_rounded;
        message = 'Không có thiết bị offline';
        break;
      case DeviceFilterType.alert:
        icon = Icons.check_circle_outline_rounded;
        message = 'Không có cảnh báo nào!';
        break;
      default:
        icon = Icons.device_hub_rounded;
        message = 'Phòng chưa có thiết bị';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56.sp, color: const Color(0xFFD1D1D6)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFAEAEB2),
            ),
          ),
        ],
      ),
    );
  }
}
