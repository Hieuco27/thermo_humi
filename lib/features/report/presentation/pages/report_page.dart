import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/data/repositories/device_repository_impl.dart';
import 'package:thermo_humi/features/report/presentation/bloc/report/device_report_cubit.dart';
import 'package:thermo_humi/features/report/presentation/bloc/report/device_report_state.dart';
import 'package:thermo_humi/features/report/presentation/widgets/report_data_row.dart';
import 'package:thermo_humi/features/report/presentation/widgets/report_filter_section.dart';
import 'package:thermo_humi/features/report/presentation/widgets/report_table_header.dart';

/// Trang Báo cáo Nhiệt độ - Độ ẩm.
/// Hỗ trợ 2 luồng vào:
///   1. Từ navbar → [initialDeviceId] = null, hiển thị form trống.
///   2. Từ trang chi tiết thiết bị → truyền [initialDeviceId], tự chọn phòng/thiết bị.
class ReportPage extends StatelessWidget {
  final String? initialDeviceId;

  const ReportPage({super.key, this.initialDeviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DeviceReportCubit(repository: DeviceRepositoryImpl())
            ..loadFilters(initialDeviceId: initialDeviceId),
      child: const _ReportView(),
    );
  }
}

// ---------------------------------------------------------------------------
// Private: View chính
// ---------------------------------------------------------------------------
class _ReportView extends StatelessWidget {
  const _ReportView();

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Báo cáo',
          style: AppTextStyles.titleMediumAppBar(color: Colors.black),
        ),
      ),
      body: BlocBuilder<DeviceReportCubit, DeviceReportState>(
        builder: (context, state) {
          // Loading filters
          if (state.status == DeviceReportStatus.initial ||
              state.status == DeviceReportStatus.loadingFilters) {
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
    );
  }
}

// ---------------------------------------------------------------------------
// Private: Bảng dữ liệu theo giờ
// ---------------------------------------------------------------------------
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

    // Chưa chọn thiết bị
    if (state.selectedDevice == null) {
      return Center(
        child: Text(
          'Vui lòng chọn thiết bị để xem báo cáo',
          style: AppTextStyles.bodyMedium(color: Colors.grey),
        ),
      );
    }

    // Chưa bấm "Xem báo cáo" hoặc không có dữ liệu
    if (state.reportData.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu — hãy nhấn "Xem báo cáo"',
          style: AppTextStyles.bodyMedium(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

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
