import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class DeviceHistoryPoint extends Equatable {
  final DateTime timestamp;
  final double temperature;
  final double humidity;

  const DeviceHistoryPoint({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
  });

  @override
  List<Object?> get props => [timestamp, temperature, humidity];
}

class DeviceHistoryDataEntity extends Equatable {
  final List<DeviceHistoryPoint> points;
  final ThresholdEntity threshold;

  const DeviceHistoryDataEntity({
    required this.points,
    required this.threshold,
  });

  @override
  List<Object?> get props => [points, threshold];
}
