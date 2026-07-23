import 'package:hive/hive.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/data/models/hive/device_hive_model.dart';

class RoomHiveModel extends HiveObject {
  final String id;
  final String name;
  final String? description;
  final int totalDevices;
  final DateTime createdAt;
  final List<DeviceHiveModel> devices;

  RoomHiveModel({
    required this.id,
    required this.name,
    this.description,
    required this.totalDevices,
    required this.createdAt,
    required this.devices,
  });

  factory RoomHiveModel.fromEntity(RoomEntity entity) {
    return RoomHiveModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      totalDevices: entity.totalDevices,
      createdAt: entity.createdAt,
      devices: entity.devices
          .map((d) => DeviceHiveModel.fromEntity(d))
          .toList(),
    );
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      name: name,
      description: description,
      totalDevices: totalDevices,
      onlineDevices: 0, // Default for offline cache
      alertCount: 0, // Default for offline cache
      createdAt: createdAt,
    );
  }
}

class RoomHiveModelAdapter extends TypeAdapter<RoomHiveModel> {
  @override
  final int typeId = 0;

  @override
  RoomHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      totalDevices: fields[3] as int,
      createdAt: fields[4] as DateTime,
      devices: (fields[5] as List).cast<DeviceHiveModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, RoomHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.totalDevices)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.devices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
