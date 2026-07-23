import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.roomId,
    super.roomName,
    super.serialNumber,
    required super.status,
    required super.connectivity,
    super.currentTemperature,
    super.currentHumidity,
    super.threshold,
    super.lastUpdatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    // Parse Threshold
    ThresholdEntity? parsedThreshold;
    if (json['threshold'] != null && json['threshold'] is Map) {
      final t = json['threshold'];
      parsedThreshold = ThresholdEntity(
        tempLow: (t['minTemperature'] as num?)?.toDouble() ?? 0.0,
        tempHigh: (t['maxTemperature'] as num?)?.toDouble() ?? 0.0,
        humidLow: (t['minHumidity'] as num?)?.toDouble() ?? 0.0,
        humidHigh: (t['maxHumidity'] as num?)?.toDouble() ?? 0.0,
      );
    }

    // Parse Status — hỗ trợ: status (string) hoặc isActive (bool)
    DeviceStatus parsedStatus = DeviceStatus.unknown;
    final statusStr = json['status']?.toString().toLowerCase();
    if (statusStr == 'normal' || statusStr == 'online') {
      parsedStatus = DeviceStatus.online;
    } else if (statusStr == 'offline') {
      parsedStatus = DeviceStatus.offline;
    } else if (json['isActive'] == true) {
      // API unassigned dùng isActive thay vì status
      parsedStatus = DeviceStatus.online;
    }

    // Parse Connectivity
    ConnectivityStatus parsedConn = ConnectivityStatus.none;
    final connStr = json['connectivity']?.toString().toLowerCase();
    if (connStr == 'online') {
      parsedConn = ConnectivityStatus.strong;
    } else if (connStr == 'offline') {
      parsedConn = ConnectivityStatus.none;
    }

    // Tên thiết bị: API rooms dùng 'name', API unassigned dùng 'deviceName'
    final name = (json['name'] as String?)?.trim().isNotEmpty == true
        ? json['name'] as String
        : (json['deviceName'] as String? ?? '');

    // Room ID: API rooms dùng 'roomId', API unassigned dùng 'locationId'
    final roomId = (json['roomId'] as String?)?.trim().isNotEmpty == true
        ? json['roomId'] as String
        : (json['locationId'] as String? ?? '');

    return DeviceModel(
      id: json['id'] as String? ?? '',
      name: name,
      roomId: roomId,
      roomName: json['roomName'] as String?,
      serialNumber: json['serialNumber'] as String? ?? json['imei'] as String?,
      status: parsedStatus,
      connectivity: parsedConn,
      currentTemperature: (json['currentTemperature'] as num?)?.toDouble(),
      currentHumidity: (json['currentHumidity'] as num?)?.toDouble(),
      threshold: parsedThreshold,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'])
          : null,
    );
  }
}
