import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';

abstract class DeviceHistoryState extends Equatable {
  const DeviceHistoryState();

  @override
  List<Object?> get props => [];
}

class DeviceHistoryInitial extends DeviceHistoryState {}

class DeviceHistoryLoading extends DeviceHistoryState {}

class DeviceHistoryLoaded extends DeviceHistoryState {
  final DeviceHistoryDataEntity data;

  const DeviceHistoryLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class DeviceHistoryError extends DeviceHistoryState {
  final String message;

  const DeviceHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
