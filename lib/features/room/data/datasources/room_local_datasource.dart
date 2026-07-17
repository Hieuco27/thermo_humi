import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

abstract class RoomLocalDataSource {
  Future<void> saveRoomsWithDevices(List<RoomWithDevices> rooms);
  Future<List<RoomWithDevices>> getRoomsWithDevices();
}
