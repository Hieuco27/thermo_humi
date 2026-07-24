import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/data/repositories/device_repository_impl.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_detail/device_history_cubit.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_detail/device_history_state.dart';
import 'package:thermo_humi/features/report/presentation/pages/report_page.dart';
import 'package:thermo_humi/features/device/presentation/widgets/device/device_gauge.dart';
import 'package:thermo_humi/features/device/presentation/widgets/chart/history_tab_chart.dart';
import 'package:thermo_humi/features/device/presentation/widgets/device/device_footer.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/sharing/presentation/pages/share_page.dart';

class DeviceDetailPage extends StatelessWidget {
  final DeviceEntity device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // Provide Cubit
    return BlocProvider(
      create: (context) =>
          DeviceHistoryCubit(repository: DeviceRepositoryImpl(sl()))
            ..fetchHistory(device.id),
      child: _DeviceDetailView(device: device),
    );
  }
}

class _DeviceDetailView extends StatelessWidget {
  final DeviceEntity device;

  const _DeviceDetailView({required this.device});

  @override
  Widget build(BuildContext context) {
    final Color cardBg = AppColors.gradientEnd;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 24.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                device.name,
                style: AppTextStyles.titleMediumAppBar(color: Colors.white),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 22.sp,
              ),
              onPressed: () {
                // TODO: Navigate to ThresholdSettingsScreen
              },
            ),
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 22.sp,
              ),
              onPressed: () {
                // Navigate to SharePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SharePage(initialDeviceIds: [device.id]),
                  ),
                );
              },
            ),
            SizedBox(width: 4.w),
          ],
        ),
        body: BlocBuilder<DeviceHistoryCubit, DeviceHistoryState>(
          builder: (context, state) {
            if (state is DeviceHistoryLoading ||
                state is DeviceHistoryInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DeviceHistoryError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is DeviceHistoryLoaded) {
              final data = state.data;

              return SingleChildScrollView(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gauges Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DeviceGauge(
                              title: 'Nhiệt độ:',
                              value: device.currentTemperature ?? 0.0,
                              unit: '°C',
                              hasAlert: device.isTemperatureAlert,
                            ),
                          ),
                          Expanded(
                            child: DeviceGauge(
                              title: 'Độ ẩm:',
                              value: device.currentHumidity ?? 0.0,
                              unit: '%',
                              hasAlert: device.isHumidityAlert,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // History Chart Card
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Biểu đồ',
                                style: AppTextStyles.labelLarge(
                                  color: Colors.black,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportPage(
                                        initialDeviceId: device.id,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.list_alt,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  'Báo cáo',
                                  style: AppTextStyles.labelLarge(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          HistoryTabChart(historyData: data),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Footer
                    DeviceFooter(cardBg: Colors.white),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
