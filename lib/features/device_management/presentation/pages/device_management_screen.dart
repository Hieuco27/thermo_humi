import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/device_management/device_management_cubit.dart';
import 'package:thermo_humi/features/device_management/presentation/widgets/device_filter_chips.dart';
import 'package:thermo_humi/features/device_management/presentation/widgets/device_filter_row.dart';
import 'package:thermo_humi/features/device_management/presentation/widgets/device_list_view.dart';
import 'package:thermo_humi/features/device_management/presentation/widgets/device_management_app_bar.dart';
import 'package:thermo_humi/features/device_management/presentation/widgets/device_search_bar.dart';
import 'package:thermo_humi/core/di/injection_container.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final DeviceManagementCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DeviceManagementCubit>()..loadInitialDevices();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: DeviceManagementAppBar(
          onAddPressed: () async {
            await context.pushNamed('add-device');
            if (mounted) {
              // Thêm 1 khoảng trễ nhỏ để backend kịp đồng bộ dữ liệu sau khi thêm
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                _cubit.loadInitialDevices();
              }
            }
          },
        ),
        body: Column(
          children: [
            DeviceSearchBar(controller: _searchCtrl),
            const DeviceFilterRow(),
            const DeviceFilterChips(),
            SizedBox(height: 8.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _cubit.loadInitialDevices();
                  // Đợi cho đến khi hết loading
                  await _cubit.stream.firstWhere((s) => !s.isLoading);
                },
                child: DeviceListView(scrollController: _scrollCtrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
