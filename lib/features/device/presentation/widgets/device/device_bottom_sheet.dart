import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/presentation/pages/device_detail_page.dart';
import 'package:thermo_humi/features/report/presentation/pages/report_page.dart';
import '../../pages/threshold_settings/threshold_settings_screen.dart';

class DeviceBottomSheet extends StatelessWidget {
  final DeviceEntity device;

  const DeviceBottomSheet({super.key, required this.device});

  static Future<void> show(BuildContext context, DeviceEntity device) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true, // Thêm dòng này để đè lên Navbar
      builder: (_) => DeviceBottomSheet(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header tên thiết bị
            Padding(
              padding: EdgeInsets.only(
                left: 10.w,
                right: 20.w,
                top: 10.h,
                bottom: 8.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(device.name, style: AppTextStyles.labelLarge()),
                  ),
                ],
              ),
            ),
            // Grid menu
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                children: [
                  _MenuItem(
                    iconPath: 'assets/icons/room/dieuChinh.svg',
                    iconColor: const Color(0xFF6366F1),
                    label: 'Cấu hình',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ThresholdSettingsScreen(device: device),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    iconPath: 'assets/icons/room/detail.svg',
                    iconColor: AppColors.primary,
                    label: 'Chi tiết',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeviceDetailPage(
                            deviceId: device.id,
                            deviceName: device.name,
                          ),
                        ),
                      );
                    },
                  ),

                  _MenuItem(
                    iconPath: 'assets/icons/navbar/report.svg',
                    iconColor: const Color(0xFF34C759), // Green
                    label: 'Xem báo cáo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReportPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

// Menu item widget
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.iconPath,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.backgroundColor.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 36.r,
                height: 36.r,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: AppTextStyles.label13(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
