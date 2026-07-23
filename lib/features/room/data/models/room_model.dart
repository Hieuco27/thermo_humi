import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/data/models/device_model.dart';

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
    return RoomModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      totalDevices: json['totalDevices'] as int? ?? 0,
      onlineDevices: json['onlineDevices'] as int? ?? 0,
      alertCount: json['alertCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      devices:
          (json['devices'] as List?)
              ?.map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
