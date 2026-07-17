import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

class RoomWithDevices extends Equatable {
  final RoomEntity room;
  final List<DeviceEntity> devices;
  const RoomWithDevices({required this.room, required this.devices});

  @override
  List<Object?> get props => [room, devices];
}
