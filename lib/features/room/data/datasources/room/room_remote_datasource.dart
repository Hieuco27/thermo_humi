/// Abstract interface — Room Remote DataSource
/// Định nghĩa contract gọi API liên quan đến phòng & thiết bị online.
library;

import 'package:thermo_humi/features/room/data/models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> getRooms(String userId);
}
