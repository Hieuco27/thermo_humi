import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int totalDevices;
  final int onlineDevices;
  final int alertCount;
  final DateTime createdAt;
  final List<DeviceEntity> devices;
  const RoomEntity({
    required this.id,
    required this.name,
    this.description,
    required this.totalDevices,
    required this.onlineDevices,
    required this.alertCount,
    required this.createdAt,
    this.devices = const [],
  });

  int get offlineDevices => totalDevices - onlineDevices;
  bool get hasAlert => alertCount > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    devices,
    totalDevices,
    onlineDevices,
    alertCount,
  ];

  RoomEntity copyWith({
    String? id,
    String? name,
    String? description,
    int? totalDevices,
    int? onlineDevices,
    int? alertCount,
    DateTime? createdAt,
    List<DeviceEntity>? devices,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalDevices: totalDevices ?? this.totalDevices,
      onlineDevices: onlineDevices ?? this.onlineDevices,
      alertCount: alertCount ?? this.alertCount,
      createdAt: createdAt ?? this.createdAt,
      devices: devices ?? this.devices,
    );
  }
}
