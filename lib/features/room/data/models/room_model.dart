import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/device/data/models/device_model.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.name,
    super.description,
    required super.totalDevices,
    required super.onlineDevices,
    required super.alertCount,
    required super.createdAt,
    super.devices,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final roomId = json['id'] as String? ?? json['locationId'] as String? ?? '';
    final String roomName = (json['name'] as String?)?.isNotEmpty == true
        ? json['name'] as String
        : (roomId == 'UNASSIGNED' ? 'Chưa gán phòng' : '');

    final parsedDevices =
        (json['devices'] as List?)?.map((e) {
          final deviceMap = Map<String, dynamic>.from(e as Map);
          if (!deviceMap.containsKey('roomId') ||
              deviceMap['roomId'] == null ||
              (deviceMap['roomId'] as String).isEmpty) {
            deviceMap['roomId'] = roomId;
          }
          if (!deviceMap.containsKey('roomName') ||
              deviceMap['roomName'] == null ||
              (deviceMap['roomName'] as String).isEmpty) {
            deviceMap['roomName'] = roomId == 'UNASSIGNED' ? null : roomName;
          }
          return DeviceModel.fromJson(deviceMap);
        }).toList() ??
        const [];

    final int totalDevices =
        json['totalDevices'] as int? ?? parsedDevices.length;
    final int onlineDevices =
        json['onlineDevices'] as int? ??
        parsedDevices.where((d) => d.status == DeviceStatus.online).length;

    final int alertCount =
        json['alertCount'] as int? ??
        parsedDevices
            .where((d) => d.status == DeviceStatus.offline || d.hasAlert)
            .length;

    return RoomModel(
      id: roomId,
      name: roomName,
      description: json['description'] as String?,
      totalDevices: totalDevices,
      onlineDevices: onlineDevices,
      alertCount: alertCount,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      devices: parsedDevices,
    );
  }
}
