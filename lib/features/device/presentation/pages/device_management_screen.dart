import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/device_management/device_management_cubit.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import '../widgets/device_management/device_search_bar.dart';
import '../widgets/device_management/device_filter_row.dart';
import '../widgets/device_management/device_filter_chips.dart';
import '../widgets/device_management/device_list_view.dart';
import '../widgets/device_management/device_management_app_bar.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<DeviceManagementCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeviceManagementCubit>()..loadInitialDevices(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const DeviceManagementAppBar(),
        body: Builder(
          builder: (context) {
            return Column(
              children: [
                DeviceSearchBar(controller: _searchCtrl),
                const DeviceFilterRow(),
                const DeviceFilterChips(),
                SizedBox(height: 8.h),
                Expanded(child: DeviceListView(scrollController: _scrollCtrl)),
              ],
            );
          },
        ),
      ),
    );
  }
}
