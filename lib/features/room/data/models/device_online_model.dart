/// DTO — Device lồng trong Location Response
/// Mapping từ API: /device-online/query
/// Mỗi location (phòng) chứa danh sách device dạng này.
library;

import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class DeviceOnlineModel {
  final int deviceId;
  final String imei;
  final String userId;
  final String name;
  final String locationId;
  final DateTime? timeStamp;
  final double temperatureMin;
  final double temperatureMax;
  final double humidityMin;
  final double humidityMax;
  final DateTime? lastUpdate;

  const DeviceOnlineModel({
    required this.deviceId,
    required this.imei,
    required this.userId,
    required this.name,
    required this.locationId,
    this.timeStamp,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.humidityMin,
    required this.humidityMax,
    this.lastUpdate,
  });

  /// Parse từ JSON (API response)
  factory DeviceOnlineModel.fromJson(Map<String, dynamic> json) {
    return DeviceOnlineModel(
      deviceId: json['deviceId'] as int,
      imei: json['imei'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      timeStamp: json['timeStamp'] != null
          ? DateTime.tryParse(json['timeStamp'] as String)
          : null,
      temperatureMin: (json['temperatureMin'] as num?)?.toDouble() ?? 0.0,
      temperatureMax: (json['temperatureMax'] as num?)?.toDouble() ?? 0.0,
      humidityMin: (json['humidityMin'] as num?)?.toDouble() ?? 0.0,
      humidityMax: (json['humidityMax'] as num?)?.toDouble() ?? 0.0,
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.tryParse(json['lastUpdate'] as String)
          : null,
    );
  }

  /// Chuyển DTO → Domain Entity để các layer trên dùng
  DeviceEntity toEntity() {
    return DeviceEntity(
      id: deviceId.toString(),
      name: name,
      roomId: locationId,
      serialNumber: imei,
      // API /device-online/query → thiết bị được coi là online
      status: DeviceStatus.online,
      connectivity: ConnectivityStatus.strong,
      threshold: ThresholdEntity(
        tempLow: temperatureMin,
        tempHigh: temperatureMax,
        humidLow: humidityMin,
        humidHigh: humidityMax,
      ),
      lastUpdatedAt: lastUpdate,
    );
  }
}
