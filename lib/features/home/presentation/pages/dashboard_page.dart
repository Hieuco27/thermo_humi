import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/home/presentation/widgets/area_list_item.dart';
import 'package:thermo_humi/features/home/presentation/widgets/metric_card.dart';
import 'package:thermo_humi/features/home/presentation/widgets/network_signal_card.dart';
import 'package:thermo_humi/features/home/presentation/widgets/system_status_card.dart';
import 'package:thermo_humi/features/home/presentation/widgets/dashboard_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/shared/mock/mock_room_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Dùng chung mock data từ shared/mock
  final List<RoomWithDevices> _rooms = buildMockRooms();

  Future<void> _onRefresh() async {
    // Giả lập thời gian load API 1 giây
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dữ liệu đã được làm mới!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const DashboardAppBar(),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.dashboardSuccess,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SystemStatusCard(),
                SizedBox(height: 10.h),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: MetricCard(
                                title: 'Thiết bị',
                                value: '45 / 48',
                                subtitle: '(Online)',
                                valueColor: AppColors.dashboardSuccess,
                                subtitleColor: AppColors.dashboardSuccess,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Expanded(
                              child: MetricCard(
                                title: 'Cảnh báo',
                                value: '3',
                                subtitle: '(Active)',
                                valueColor: AppColors.dashboardWarning,
                                subtitleColor: AppColors.dashboardWarning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(child: NetworkSignalCard()),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Areas', style: AppTextStyles.titleMediumBlack()),
                SizedBox(height: 12.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rooms.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return AreaListItem(rwd: _rooms[index]);
                  },
                ),
                SizedBox(height: 20.h), // Padding cho bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
