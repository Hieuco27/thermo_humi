import 'package:flutter/material.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/home/presentation/widgets/area_list_item.dart';
import 'package:thermo_humi/features/home/presentation/widgets/metric_card.dart';
import 'package:thermo_humi/features/home/presentation/widgets/home_appbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  // Dùng chung mock data từ shared/mock
  final List<RoomWithDevices> _rooms = buildMockRooms();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const HomeAppBar(),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  SizedBox(width: 10.w),
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
              SizedBox(height: 12.h),
              Text('Khu vực', style: AppTextStyles.titleMediumBlack()),
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
    );
  }
}
