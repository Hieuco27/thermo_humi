/// DTO — Location (phòng) trong Response của API: /device-online/query
/// Một location chứa thông tin phòng + danh sách thiết bị đang online.
library;

import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/data/models/device_online_model.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

class LocationModel {
  final String locationId;
  final String userId;
  final String name;
  final List<DeviceOnlineModel> devices;

  const LocationModel({
    required this.locationId,
    required this.userId,
    required this.name,
    required this.devices,
  });

  /// Parse từ JSON (1 phần tử trong mảng "data")
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final rawDevices = json['devices'];
    final deviceList = (rawDevices is List)
        ? rawDevices
            .whereType<Map<String, dynamic>>()
            .map(DeviceOnlineModel.fromJson)
            .toList()
        : <DeviceOnlineModel>[];

    return LocationModel(
      locationId: json['locationId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      devices: deviceList,
    );
  }

  /// Chuyển DTO → Domain Entity (RoomEntity)
  RoomEntity toRoomEntity() {
    return RoomEntity(
      id: locationId,
      name: name,
      // Tổng thiết bị = số thiết bị trả về (đều đang online)
      totalDevices: devices.length,
      onlineDevices: devices.length,
      alertCount: 0, // Sẽ tính lại sau khi map devices
      createdAt: DateTime.now(),
    );
  }

  /// Chuyển DTO → list DeviceEntity
  List<DeviceEntity> toDeviceEntities() {
    return devices.map((d) => d.toEntity()).toList();
  }

  /// Chuyển DTO → RoomWithDevices (presentation model đã có sẵn)
  RoomWithDevices toRoomWithDevices() {
    final deviceEntities = toDeviceEntities();
    final alertCount = deviceEntities.where((d) => d.hasAlert).length;

    return RoomWithDevices(
      room: RoomEntity(
        id: locationId,
        name: name,
        totalDevices: deviceEntities.length,
        onlineDevices: deviceEntities.length,
        alertCount: alertCount,
        createdAt: DateTime.now(),
      ),
      devices: deviceEntities,
    );
  }
}
