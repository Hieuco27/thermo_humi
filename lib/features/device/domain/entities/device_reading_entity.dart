/// DeviceReading Entity — 1 điểm dữ liệu đọc từ cảm biến
library;

import 'package:equatable/equatable.dart';

class DeviceReadingEntity extends Equatable {
  final String id;
  final String deviceId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  const DeviceReadingEntity({
    required this.id,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, deviceId, timestamp];
}
