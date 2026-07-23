import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/home/presentation/widgets/area_list_item.dart';
import 'package:thermo_humi/features/home/presentation/widgets/metric_card.dart';
import 'package:thermo_humi/features/home/presentation/widgets/home_appbar.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_cubit.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Tái sử dụng RoomListCubit từ DI — nếu đã có provider ở cấp cao hơn
      // thì có thể đổi sang BlocProvider.value
      create: (_) => sl<RoomListCubit>()..loadRooms(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const HomeAppBar(),
        body: BlocBuilder<RoomListCubit, RoomListState>(
          builder: (context, state) {
            // Tính toán metric từ dữ liệu thực
            final rooms = state.rooms;
            final int totalDevices = rooms.fold(
              0,
              (sum, r) => sum + r.totalDevices,
            );
            final int totalOnline = rooms.fold(
              0,
              (sum, r) => sum + r.onlineDevices,
            );
            final int totalAlerts = rooms.fold(
              0,
              (sum, r) => sum + r.alertCount,
            );

            return RefreshIndicator(
              onRefresh: () => context.read<RoomListCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Metric cards ──
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Thiết bị',
                            value: state.isLoading
                                ? '...'
                                : '$totalOnline / $totalDevices',
                            subtitle: '(Online)',
                            valueColor: AppColors.dashboardSuccess,
                            subtitleColor: AppColors.dashboardSuccess,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: MetricCard(
                            title: 'Cảnh báo',
                            value: state.isLoading ? '...' : '$totalAlerts',
                            subtitle: '(Active)',
                            valueColor: totalAlerts > 0
                                ? AppColors.dashboardWarning
                                : AppColors.dashboardSuccess,
                            subtitleColor: totalAlerts > 0
                                ? AppColors.dashboardWarning
                                : AppColors.dashboardSuccess,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),
                    Text('Khu vực', style: AppTextStyles.titleMediumBlack()),
                    SizedBox(height: 12.h),

                    // ── Loading ──
                    if (state.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    // ── Lỗi ──
                    else if (state.isFailure)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_off_rounded,
                                size: 48.sp,
                                color: Colors.white38,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                state.errorMessage ?? 'Đã xảy ra lỗi',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body13().copyWith(),
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.read<RoomListCubit>().refresh(),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      )
                    // ── Trống ──
                    else if (state.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Text(
                            'Chưa có khu vực nào',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      )
                    // Danh sách khu vực
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return AreaListItem(room: rooms[index]);
                        },
                      ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
