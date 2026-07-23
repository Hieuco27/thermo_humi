import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

abstract class RoomLocalDataSource {
  Future<void> saveRoomsWithDevices(List<RoomEntity> rooms);
  Future<List<RoomEntity>> getRoomsWithDevices();
}
