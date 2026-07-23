import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import '../../../domain/entities/device_entity.dart';
import '../../bloc/threshold_settings/threshold_settings_cubit.dart';
import '../../bloc/threshold_settings/threshold_settings_state.dart';
import '../../widgets/threshold_settings/temperature_threshold_card.dart';
import '../../widgets/threshold_settings/humidity_threshold_card.dart';

class ThresholdSettingsScreen extends StatelessWidget {
  final DeviceEntity device;

  const ThresholdSettingsScreen({super.key, required this.device});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThresholdSettingsCubit(device),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: AppColors.gradientEnd,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 22.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'Cấu hình nhiệt độ & độ ẩm',
                  style: AppTextStyles.titleMediumAppBar(color: Colors.white),
                ),
                Text(
                  '(${device.name})',
                  style: AppTextStyles.bodySmall(color: AppColors.background),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: BlocListener<ThresholdSettingsCubit, ThresholdSettingsState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == ThresholdSettingsStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings applied successfully!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                } else if (state.status == ThresholdSettingsStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ?? 'An error occurred'),
                      backgroundColor: Color(0xFFF44336),
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    _buildAlertBanner(device),
                    TemperatureThresholdCard(
                      currentTemperature: device.currentTemperature,
                    ),
                    SizedBox(height: 16.h),
                    HumidityThresholdCard(
                      currentHumidity: device.currentHumidity,
                    ),
                    SizedBox(height: 32.h),
                    _buildPrimaryButton(),
                    SizedBox(height: 16.h),
                    _buildSecondaryButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return BlocBuilder<ThresholdSettingsCubit, ThresholdSettingsState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        final isLoading = state.status == ThresholdSettingsStatus.loading;
        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<ThresholdSettingsCubit>().applySettings(device.id);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 24.h,
                    width: 24.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Lưu cho thiết bị ${device.name}',
                    style: AppTextStyles.labelLarge(color: Colors.white),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButton() {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton.icon(
            onPressed: () => _showConfirmationDialog(context),
            icon: Icon(
              Icons.devices,
              color: const Color(0xFF1976D2),
              size: 18.w,
            ),
            label: Text(
              'Áp dụng cho tất cả các thiết bị',
              style: AppTextStyles.labelLarge(color: Colors.black),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final blocContext = context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Áp dụng cho tất cả các thiết bị',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        content: Text(
          'Bạn có chắc chắn muốn áp dụng cài đặt này cho tất cả các thiết bị?',
          style: TextStyle(fontSize: 15.sp, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF616161)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              blocContext.read<ThresholdSettingsCubit>().applyToAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(DeviceEntity device) {
    if (!device.hasAlert) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${device.name} đang vượt ngưỡng',
                  style: AppTextStyles.labelMedium(
                    color: Colors.red,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                if (device.isTemperatureAlert)
                  Text(
                    '· Nhiệt độ: ${device.currentTemperature}°C (ngưỡng ${device.threshold!.tempLow}°C–${device.threshold!.tempHigh}°C)',
                    style: AppTextStyles.titleSmall2(
                      color: Colors.red,
                    ).copyWith(height: 1.5),
                  ),
                if (device.isHumidityAlert)
                  Text(
                    '· Độ ẩm: ${device.currentHumidity}% (ngưỡng ${device.threshold!.humidLow}%–${device.threshold!.humidHigh}%)',
                    style: AppTextStyles.titleSmall2(
                      color: Colors.red,
                    ).copyWith(height: 1.5),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
