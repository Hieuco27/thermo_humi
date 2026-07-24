import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/sensor_entity.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final String roomId;
  final String? roomName;
  final String? serialNumber;
  final DeviceStatus status;
  final ConnectivityStatus connectivity;
  final List<SensorEntity> sensors;
  final DateTime? lastUpdatedAt;
  final double temperatureMin;
  final double temperatureMax;
  final double humidityMin;
  final double humidityMax;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.roomId,
    this.roomName,
    this.serialNumber,
    required this.status,
    required this.connectivity,
    this.sensors = const [],
    this.lastUpdatedAt,
    this.temperatureMin = 0.0,
    this.temperatureMax = 0.0,
    this.humidityMin = 0.0,
    this.humidityMax = 0.0,
  });

  double? get currentTemperature =>
      sensors.isNotEmpty ? sensors.first.temperature : null;
  double? get currentHumidity =>
      sensors.isNotEmpty ? sensors.first.humidity : null;

  ThresholdEntity? get threshold {
    return ThresholdEntity(
      tempHigh: temperatureMax,
      tempLow: temperatureMin,
      humidHigh: humidityMax,
      humidLow: humidityMin,
    );
  }

  bool get isOnline => status == DeviceStatus.online;
  bool get isOffline =>
      status == DeviceStatus.offline || connectivity == ConnectivityStatus.none;

  bool get isTemperatureAlert {
    if (sensors.isEmpty) return false;
    for (final s in sensors) {
      if (s.temperature != null) {
        if (s.temperature! > temperatureMax ||
            s.temperature! < temperatureMin) {
          return true;
        }
      }
    }
    return false;
  }

  bool get isHumidityAlert {
    if (sensors.isEmpty) return false;
    for (final s in sensors) {
      if (s.humidity != null) {
        if (s.humidity! > humidityMax || s.humidity! < humidityMin) {
          return true;
        }
      }
    }
    return false;
  }

  bool get hasAlert => isTemperatureAlert || isHumidityAlert;

  DeviceEntity copyWith({
    String? id,
    String? name,
    String? roomId,
    String? roomName,
    String? serialNumber,
    DeviceStatus? status,
    ConnectivityStatus? connectivity,
    List<SensorEntity>? sensors,
    DateTime? lastUpdatedAt,
    double? temperatureMin,
    double? temperatureMax,
    double? humidityMin,
    double? humidityMax,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      connectivity: connectivity ?? this.connectivity,
      sensors: sensors ?? this.sensors,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      temperatureMin: temperatureMin ?? this.temperatureMin,
      temperatureMax: temperatureMax ?? this.temperatureMax,
      humidityMin: humidityMin ?? this.humidityMin,
      humidityMax: humidityMax ?? this.humidityMax,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    roomId,
    roomName,
    status,
    connectivity,
    sensors,
    lastUpdatedAt,
    temperatureMin,
    temperatureMax,
    humidityMin,
    humidityMax,
  ];
}

enum DeviceStatus { online, offline, unknown }

enum ConnectivityStatus {
  strong, // 4G tốt
  medium, // 4G trung bình
  weak, // 4G yếu
  none, // Không kết nối
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

class PaginatedDeviceResult extends Equatable {
  final List<DeviceEntity> devices;
  final int totalCount;

  const PaginatedDeviceResult({
    required this.devices,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [devices, totalCount];
}
