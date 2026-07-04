import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_report/device_report_state.dart';

class DeviceReportCubit extends Cubit<DeviceReportState> {
  final DeviceRepository repository;

  DeviceReportCubit({required this.repository}) : super(DeviceReportInitial());

  Future<void> fetchReport(String deviceId, {int page = 1}) async {
    emit(DeviceReportLoading());
    
    final result = await repository.getDeviceReport(deviceId, page: page);
    
    result.fold(
      (error) => emit(DeviceReportError(error)),
      (data) => emit(DeviceReportLoaded(data)),
    );
  }
}
