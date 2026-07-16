/// Kết quả trả về khi AddRoomScreen hoàn thành (pop về màn trước)
library;

class AddRoomResult {
  /// roomId của phòng vừa tạo hoặc phòng đã có sẵn
  final String roomId;

  /// Tên phòng (dùng để màn ngoài cập nhật list mà không cần gọi lại API)
  final String roomName;

  /// Mã thiết bị vừa được gán
  final String? deviceCode;

  /// true = phòng mới vừa được tạo, false = chỉ gán thiết bị vào phòng cũ
  final bool isNewRoom;

  const AddRoomResult({
    required this.roomId,
    required this.roomName,
    this.deviceCode,
    required this.isNewRoom,
  });
}
