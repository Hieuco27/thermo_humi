import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/access_request_state.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/device_access_request_list_cubit.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/room_access_request_list_cubit.dart';
import 'package:thermo_humi/features/request_access/presentation/widgets/access_request_list/access_request_tile.dart';

class AccessRequestListScreen extends StatelessWidget {
  const AccessRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DeviceAccessRequestListCubit>()..fetchRequests(),
        ),
        BlocProvider(
          create: (_) => sl<RoomAccessRequestListCubit>()..fetchRequests(),
        ),
      ],
      child: const _AccessRequestTabController(),
    );
  }
}

class _AccessRequestTabController extends StatelessWidget {
  const _AccessRequestTabController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const _AccessRequestAppBar(),
          body: Column(
            children: [
              const _AccessRequestTabBar(),
              const Expanded(
                child: TabBarView(
                  children: [_DeviceRequestsTab(), _RoomRequestsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessRequestAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _AccessRequestAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.gradientEnd,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 22.sp),
      ),
      title: Text(
        'Yêu cầu truy cập',
        style: AppTextStyles.titleMedium(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AccessRequestTabBar extends StatelessWidget {
  const _AccessRequestTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(100.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: AppTextStyles.bodyMedium().copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium().copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Thiết bị'),
          Tab(text: 'Phòng'),
        ],
      ),
    );
  }
}

class _DeviceRequestsTab extends StatelessWidget {
  const _DeviceRequestsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceAccessRequestListCubit, AccessRequestListState>(
      builder: (context, state) {
        return _RequestListContent(
          state: state,
          onRefresh: () async =>
              context.read<DeviceAccessRequestListCubit>().fetchRequests(),
          onItemTap: (req) {
            context.push('/request-access/${req.id}?type=device').then((_) {
              if (context.mounted) {
                context.read<DeviceAccessRequestListCubit>().fetchRequests();
              }
            });
          },
        );
      },
    );
  }
}

class _RoomRequestsTab extends StatelessWidget {
  const _RoomRequestsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomAccessRequestListCubit, AccessRequestListState>(
      builder: (context, state) {
        return _RequestListContent(
          state: state,
          onRefresh: () async =>
              context.read<RoomAccessRequestListCubit>().fetchRequests(),
          onItemTap: (req) {
            context.push('/request-access/${req.id}?type=room').then((_) {
              if (context.mounted) {
                context.read<RoomAccessRequestListCubit>().fetchRequests();
              }
            });
          },
        );
      },
    );
  }
}

class _RequestListContent extends StatelessWidget {
  final AccessRequestListState state;
  final Future<void> Function() onRefresh;
  final Function(dynamic) onItemTap;

  const _RequestListContent({
    required this.state,
    required this.onRefresh,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == AccessRequestListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == AccessRequestListStatus.error) {
      return Center(
        child: Text(
          state.errorMessage ?? 'Có lỗi xảy ra',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (state.requests.isEmpty) {
      return Center(
        child: Text(
          'Không có yêu cầu nào',
          style: AppTextStyles.bodyMedium(color: Colors.grey),
        ),
      );
    }

    final groups = state.groupedByDate;
    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final items = groups[date]!
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          String dateTitle;
          final now = DateTime.now();
          if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day) {
            dateTitle = 'Hôm nay';
          } else if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day - 1) {
            dateTitle = 'Hôm qua';
          } else {
            dateTitle = DateFormat('dd/MM/yyyy').format(date);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Text(
                  dateTitle,
                  style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
                ),
              ),
              ...items.map(
                (req) => AccessRequestTile(
                  request: req,
                  onTap: () => onItemTap(req),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
