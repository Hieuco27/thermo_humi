/// Room Repository — abstract interface (Domain layer)
library;

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
}
