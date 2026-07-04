import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/data/repositories/device_repository_impl.dart';
import 'package:thermo_humi/features/device/domain/entities/device_report_entity.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_report/device_report_cubit.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_report/device_report_state.dart';

class DeviceReportPage extends StatelessWidget {
  final String deviceId;
  final String deviceName;

  const DeviceReportPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceReportCubit(
        repository: DeviceRepositoryImpl(),
      )..fetchReport(deviceId),
      child: _DeviceReportView(deviceName: deviceName, deviceId: deviceId),
    );
  }
}

class _DeviceReportView extends StatelessWidget {
  final String deviceName;
  final String deviceId;

  const _DeviceReportView({required this.deviceName, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final Color cardBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết báo cáo',
          style: AppTextStyles.titleMedium(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: BlocBuilder<DeviceReportCubit, DeviceReportState>(
        builder: (context, state) {
          if (state is DeviceReportLoading || state is DeviceReportInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DeviceReportError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is DeviceReportLoaded) {
            final points = state.data.points;
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DeviceReportCubit>().fetchReport(deviceId);
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: points.length,
                itemBuilder: (context, index) {
                  final point = points[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(point.timestamp),
                              style: AppTextStyles.bodyMedium(color: isDark ? Colors.white : Colors.black),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                _InfoBadge(
                                  label: '${point.temperature.toStringAsFixed(1)}°C',
                                  color: const Color(0xFF007AFF),
                                  icon: Icons.thermostat,
                                ),
                                SizedBox(width: 8.w),
                                _InfoBadge(
                                  label: '${point.humidity.toStringAsFixed(1)}%',
                                  color: const Color(0xFF34C759),
                                  icon: Icons.water_drop,
                                ),
                              ],
                            ),
                          ],
                        ),
                        _StatusBadge(status: point.status),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _InfoBadge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(label, style: AppTextStyles.bodySmall(color: color)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (status) {
      case ReportStatus.normal:
        color = const Color(0xFF34C759);
        label = 'Normal';
        break;
      case ReportStatus.highAlert:
        color = const Color(0xFFFF3B30);
        label = 'High Alert';
        break;
      case ReportStatus.lowAlert:
        color = const Color(0xFF5AC8FA);
        label = 'Low Alert';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium(color: color),
      ),
    );
  }
}
