import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

enum SystemStatus { normal, disconnected, unstable }

class SystemStatusCard extends StatelessWidget {
  final SystemStatus status;

  const SystemStatusCard({super.key, this.status = SystemStatus.normal});
  // Hàm phụ trợ để lấy màu sắc theo trạng thái
  Color get _statusColor {
    switch (status) {
      case SystemStatus.normal:
        return AppColors.dashboardSuccess;
      case SystemStatus.unstable:
        return AppColors.dashboardWarning; // Ví dụ màu cam
      case SystemStatus.disconnected:
        return Colors.red; // Ví dụ màu đỏ
    }
  }

  // Hàm phụ trợ để lấy Icon theo trạng thái
  IconData get _statusIcon {
    switch (status) {
      case SystemStatus.normal:
        return Icons.check;
      case SystemStatus.unstable:
        return Icons.warning_amber_rounded;
      case SystemStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  // Hàm phụ trợ để lấy Text hiển thị
  String get _statusText {
    switch (status) {
      case SystemStatus.normal:
        return 'OK';
      case SystemStatus.unstable:
        return 'Cảnh báo';
      case SystemStatus.disconnected:
        return 'Mất kết nối';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkmark Circle
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.dashboardSuccess,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 24.r),
          ),
          SizedBox(width: 12.w),
          // Text Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Trạng thái hệ thống', style: AppTextStyles.bodyLarge()),
              SizedBox(height: 4.h),
              Text(
                'OK',
                style: AppTextStyles.headlineSmall().copyWith(
                  color: AppColors.dashboardSuccess,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
