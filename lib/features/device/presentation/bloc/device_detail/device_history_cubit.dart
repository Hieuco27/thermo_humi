import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_detail/device_history_state.dart';

class DeviceHistoryCubit extends Cubit<DeviceHistoryState> {
  final DeviceRepository repository;

  DeviceHistoryCubit({required this.repository}) : super(DeviceHistoryInitial());

  Future<void> fetchHistory(String deviceId) async {
    emit(DeviceHistoryLoading());
    
    final result = await repository.getDeviceHistory(deviceId);
    
    result.fold(
      (error) => emit(DeviceHistoryError(error)),
      (data) => emit(DeviceHistoryLoaded(data)),
    );
  }
}
