import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/data/models/sensor_model.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.roomId,
    super.roomName,
    super.serialNumber,
    required super.status,
    required super.connectivity,
    super.sensors,
    super.lastUpdatedAt,
    super.temperatureMin = 0.0,
    super.temperatureMax = 0.0,
    super.humidityMin = 0.0,
    super.humidityMax = 0.0,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    // Parse Sensors
    List<SensorModel> parsedSensors = [];
    if (json['sensors'] != null && json['sensors'] is List) {
      parsedSensors = (json['sensors'] as List)
          .map((e) => SensorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse Status — hỗ trợ: số (0, 1, 2), chuỗi ('normal', 'online', 'offline') hoặc isActive
    DeviceStatus parsedStatus = DeviceStatus.unknown;
    final statusRaw = json['status'];
    if (statusRaw != null) {
      final statusStr = statusRaw.toString().toLowerCase();
      final statusInt = int.tryParse(statusStr);
      if (statusInt != null &&
          statusInt >= 0 &&
          statusInt < DeviceStatus.values.length) {
        parsedStatus = DeviceStatus.values[statusInt];
      } else if (statusStr == 'normal' || statusStr == 'online') {
        parsedStatus = DeviceStatus.online;
      } else if (statusStr == 'offline') {
        parsedStatus = DeviceStatus.offline;
      }
    } else if (json['isActive'] == true) {
      // API unassigned dùng isActive thay vì status
      parsedStatus = DeviceStatus.online;
    }

    // Parse Connectivity — hỗ trợ: số (0, 1, 2, 3) hoặc chuỗi
    ConnectivityStatus parsedConn = ConnectivityStatus.none;
    final connRaw = json['connectivity'];
    if (connRaw != null) {
      final connStr = connRaw.toString().toLowerCase();
      final connInt = int.tryParse(connStr);
      if (connInt != null &&
          connInt >= 0 &&
          connInt < ConnectivityStatus.values.length) {
        parsedConn = ConnectivityStatus.values[connInt];
      } else if (connStr == 'online') {
        parsedConn = ConnectivityStatus.strong;
      } else if (connStr == 'offline') {
        parsedConn = ConnectivityStatus.none;
      }
    }

    // Tên thiết bị: API rooms dùng 'name', API unassigned dùng 'deviceName'
    final name = (json['name'] as String?)?.trim().isNotEmpty == true
        ? json['name'] as String
        : (json['deviceName'] as String? ?? '');

    // Room ID: API rooms dùng 'roomId', API unassigned dùng 'locationId'
    final roomId = (json['roomId'] as String?)?.trim().isNotEmpty == true
        ? json['roomId'] as String
        : (json['locationId'] as String? ?? '');

    // ID thiết bị: có thể là 'id' hoặc 'deviceId' (kiểu int hoặc string)
    final idRaw = json['id'] ?? json['deviceId'];
    final id = idRaw?.toString() ?? '';

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return DeviceModel(
      id: id,
      name: name,
      roomId: roomId,
      roomName: json['roomName'] as String?,
      serialNumber: json['serialNumber'] as String? ?? json['imei'] as String?,
      status: parsedStatus,
      connectivity: parsedConn,
      sensors: parsedSensors,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'])
          : (json['lastUpdate'] != null
                ? DateTime.tryParse(json['lastUpdate'])
                : null),
      temperatureMin: parseDouble(json['temperatureMin']) ?? 0.0,
      temperatureMax: parseDouble(json['temperatureMax']) ?? 0.0,
      humidityMin: parseDouble(json['humidityMin']) ?? 0.0,
      humidityMax: parseDouble(json['humidityMax']) ?? 0.0,
    );
  }
}
