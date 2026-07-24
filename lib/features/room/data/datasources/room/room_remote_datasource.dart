import 'package:thermo_humi/features/room/data/models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> getRooms(String userId);
  Future<void> addRoom(String name);
}
