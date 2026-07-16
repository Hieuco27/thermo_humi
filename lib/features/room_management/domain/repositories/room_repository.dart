/// Room Repository — abstract interface (Domain layer)
library;

import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

abstract class RoomRepository {
  /// Tạo phòng mới và gán thiết bị đầu tiên cùng lúc.
  /// Trả về roomId vừa tạo.
  Future<String> createRoomWithDevice({
    required String roomName,
    required String deviceCode,
  });

  /// Gán thiết bị vào phòng đã tồn tại.
  Future<void> assignDeviceToRoom({
    required String roomId,
    required String deviceCode,
  });

  /// Tạo phòng mới không kèm gán thiết bị.
  /// Trả về roomId vừa tạo.
  Future<String> createRoomOnly({required String roomName});

  /// Lấy danh sách phòng để hiển thị trong RoomPickerSheet (mode flexible).
  /// Tải lazy — chỉ gọi khi người dùng bấm mở picker lần đầu.
  Future<List<RoomEntity>> getAvailableRooms();

  /// Tạo thiết bị độc lập, không gán vào phòng nào.
  /// Dùng ở mode flexible khi selectedRoomId == null.
  Future<void> createUnassignedDevice({required String deviceCode});
}

