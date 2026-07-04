import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/device_report_entity.dart';

abstract class DeviceReportState extends Equatable {
  const DeviceReportState();

  @override
  List<Object?> get props => [];
}

class DeviceReportInitial extends DeviceReportState {}

class DeviceReportLoading extends DeviceReportState {}

class DeviceReportLoaded extends DeviceReportState {
  final DeviceReportDataEntity data;

  const DeviceReportLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class DeviceReportError extends DeviceReportState {
  final String message;

  const DeviceReportError(this.message);

  @override
  List<Object?> get props => [message];
}
