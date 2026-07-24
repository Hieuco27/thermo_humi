import 'package:hive/hive.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class DeviceHiveModel extends HiveObject {
  final String id;
  final String name;
  final String roomId;
  final String? roomName;
  final String? serialNumber;

  DeviceHiveModel({
    required this.id,
    required this.name,
    required this.roomId,
    this.roomName,
    this.serialNumber,
  });

  factory DeviceHiveModel.fromEntity(DeviceEntity entity) {
    return DeviceHiveModel(
      id: entity.id,
      name: entity.name,
      roomId: entity.roomId,
      roomName: entity.roomName,
      serialNumber: entity.serialNumber,
    );
  }

  DeviceEntity toEntity() {
    return DeviceEntity(
      id: id,
      name: name,
      roomId: roomId,
      roomName: roomName,
      serialNumber: serialNumber,
      status: DeviceStatus.unknown, // Default for offline cache
      connectivity: ConnectivityStatus.none,
      sensors: const [],
      lastUpdatedAt: null,
      temperatureMin: 0.0,
      temperatureMax: 0.0,
      humidityMin: 0.0,
      humidityMax: 0.0,
    );
  }
}

class DeviceHiveModelAdapter extends TypeAdapter<DeviceHiveModel> {
  @override
  final int typeId = 1;

  @override
  DeviceHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      roomId: fields[2] as String,
      roomName: fields[3] as String?,
      serialNumber: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.roomId)
      ..writeByte(3)
      ..write(obj.roomName)
      ..writeByte(4)
      ..write(obj.serialNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
