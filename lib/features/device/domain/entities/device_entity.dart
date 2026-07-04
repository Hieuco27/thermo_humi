/// Device Entity — thiết bị cảm biến
library;

import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final String roomId;
  final String? serialNumber;
  final DeviceStatus status;
  final ConnectivityStatus connectivity;
  final double? currentTemperature;
  final double? currentHumidity;
  final ThresholdEntity? threshold;
  final DateTime? lastUpdatedAt;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.roomId,
    this.serialNumber,
    required this.status,
    required this.connectivity,
    this.currentTemperature,
    this.currentHumidity,
    this.threshold,
    this.lastUpdatedAt,
  });

  bool get isOnline => status == DeviceStatus.online;

  bool get isTemperatureAlert {
    if (threshold == null || currentTemperature == null) return false;
    return currentTemperature! > threshold!.tempHigh ||
        currentTemperature! < threshold!.tempLow;
  }

  bool get isHumidityAlert {
    if (threshold == null || currentHumidity == null) return false;
    return currentHumidity! > threshold!.humidHigh ||
        currentHumidity! < threshold!.humidLow;
  }

  bool get hasAlert => isTemperatureAlert || isHumidityAlert;

  @override
  List<Object?> get props => [id, name, roomId, status];
}

enum DeviceStatus { online, offline, unknown }

enum ConnectivityStatus {
  strong,  // 4G tốt
  medium,  // 4G trung bình
  weak,    // 4G yếu
  none,    // Không kết nối
}

class ThresholdEntity extends Equatable {
  final double tempHigh;
  final double tempLow;
  final double humidHigh;
  final double humidLow;

  const ThresholdEntity({
    required this.tempHigh,
    required this.tempLow,
    required this.humidHigh,
    required this.humidLow,
  });

  @override
  List<Object?> get props => [tempHigh, tempLow, humidHigh, humidLow];
}
