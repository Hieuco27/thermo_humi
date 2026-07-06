import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/data/repositories/device_repository_impl.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_detail/device_history_cubit.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_detail/device_history_state.dart';
import 'package:thermo_humi/features/report/presentation/pages/report_page.dart';
import 'package:thermo_humi/features/device/presentation/widgets/device/device_gauge.dart';
import 'package:thermo_humi/features/device/presentation/widgets/chart/history_tab_chart.dart';
import 'package:thermo_humi/features/device/presentation/widgets/device/device_footer.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';

class DeviceDetailPage extends StatelessWidget {
  final String deviceId;
  final String deviceName;

  const DeviceDetailPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    // Provide Cubit
    return BlocProvider(
      create: (context) => DeviceHistoryCubit(
        repository: DeviceRepositoryImpl(), // Mock Repo
      )..fetchHistory(deviceId),
      child: _DeviceDetailView(deviceName: deviceName, deviceId: deviceId),
    );
  }
}

class _DeviceDetailView extends StatelessWidget {
  final String deviceName;
  final String deviceId;

  const _DeviceDetailView({required this.deviceName, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final Color cardBg = AppColors.gradientEnd;
    final Color backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
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
        title: Column(
          children: [
            Text(
              'Chi tiết thiết bị',
              style: AppTextStyles.titleMediumAppBar(
                color: AppColors.background,
              ),
            ),
            Text(
              '($deviceName)',
              style: AppTextStyles.bodySmall(color: AppColors.background),
            ),
          ],
        ),
      ),
      body: BlocBuilder<DeviceHistoryCubit, DeviceHistoryState>(
        builder: (context, state) {
          if (state is DeviceHistoryLoading || state is DeviceHistoryInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DeviceHistoryError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is DeviceHistoryLoaded) {
            final data = state.data;
            final latestPoint = data.points.last;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gauges Card
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: backgroundColor,
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
                            value: latestPoint.temperature,
                            unit: '°C',
                            hasAlert:
                                latestPoint.temperature >
                                data.threshold.tempHigh,
                          ),
                        ),
                        Expanded(
                          child: DeviceGauge(
                            title: 'Độ ẩm:',
                            value: latestPoint.humidity,
                            unit: '%',
                            hasAlert:
                                latestPoint.humidity > data.threshold.humidHigh,
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
                      color: backgroundColor,
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
                              style: AppTextStyles.titleMedium(
                                color: Colors.black,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReportPage(initialDeviceId: deviceId),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.list_alt, size: 14),
                              label: const Text('Báo cáo'),
                            ),
                          ],
                        ),
                        HistoryTabChart(historyData: data),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Footer
                  DeviceFooter(cardBg: backgroundColor),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
