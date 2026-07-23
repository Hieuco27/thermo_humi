import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/report/presentation/bloc/report/device_report_cubit.dart';
import 'package:thermo_humi/features/report/presentation/bloc/report/device_report_state.dart';
import 'package:thermo_humi/features/report/presentation/widgets/report_data_row.dart';
import 'package:thermo_humi/features/report/presentation/widgets/report_filter_section.dart';
import 'package:thermo_humi/features/report/presentation/widgets/report_table_header.dart';

class ReportPage extends StatelessWidget {
  final String? initialDeviceId;

  const ReportPage({super.key, this.initialDeviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DeviceReportCubit(repository: sl(), getRoomsUseCase: sl())
            ..loadFilters(initialDeviceId: initialDeviceId),
      child: const _ReportView(),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.gradientEnd,
          elevation: 0,
          centerTitle: true,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
          title: Text(
            'Báo cáo',
            style: AppTextStyles.titleMediumAppBar(color: Colors.white),
          ),
        ),
        body: BlocBuilder<DeviceReportCubit, DeviceReportState>(
          builder: (context, state) {
            // Loading filters (chỉ hiện full màn hình khi load lần đầu tiên)
            if (state.status == DeviceReportStatus.initial ||
                (state.status == DeviceReportStatus.loadingFilters &&
                    state.rooms.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            // Error
            if (state.status == DeviceReportStatus.error) {
              return Center(
                child: Text(
                  'Lỗi: ${state.errorMessage}',
                  style: AppTextStyles.bodyMedium(color: Colors.red),
                ),
              );
            }

            return Column(
              children: [
                ReportFilterSection(state: state),
                SizedBox(height: 16.h),
                Expanded(child: _ReportDataTable(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReportDataTable extends StatelessWidget {
  final DeviceReportState state;

  const _ReportDataTable({required this.state});

  @override
  Widget build(BuildContext context) {
    // Đang tải dữ liệu báo cáo
    if (state.status == DeviceReportStatus.loadingReport) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    // Nếu chưa có dữ liệu báo cáo nào (hoặc dữ liệu rỗng)
    if (state.reportData.isEmpty) {
      // Chưa chọn thiết bị
      if (state.selectedDevice == null) {
        return Center(
          child: Text(
            'Vui lòng chọn thiết bị để xem báo cáo',
            style: AppTextStyles.bodyMedium(color: Colors.grey),
          ),
        );
      }

      // Chưa bấm xem báo cáo (hoặc vừa đổi bộ lọc)
      if (state.status == DeviceReportStatus.filtersLoaded) {
        return Center(
          child: Text(
            'Bấm "Xem báo cáo" để tải dữ liệu',
            style: AppTextStyles.bodyMedium(color: Colors.grey),
          ),
        );
      }

      // Đã bấm "Xem báo cáo" nhưng API trả về mảng rỗng
      return Center(
        child: Text(
          'Không có dữ liệu',
          style: AppTextStyles.bodyMedium(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Nếu đã có dữ liệu cũ, BẤT CHẤP việc vừa đổi phòng hay chưa chọn thiết bị,
    // Vẫn hiển thị bảng dữ liệu cũ
    return Column(
      children: [
        const ReportTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: state.reportData.length,
            itemBuilder: (_, index) =>
                ReportDataRow(item: state.reportData[index]),
          ),
        ),
      ],
    );
  }
}
