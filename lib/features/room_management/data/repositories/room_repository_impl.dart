/// RoomRepositoryImpl — mock implementation (Data layer)
/// Thay bằng API thực khi BE sẵn sàng
library;

import 'package:thermo_humi/features/room_management/domain/repositories/room_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  /// Mock: Tạo phòng mới + gán thiết bị cùng lúc.
  /// Khi BE sẵn sàng: gọi 1 API endpoint duy nhất.
  /// Nếu BE chỉ hỗ trợ 2 API riêng, cần compensating transaction:
  ///   bước 1: createRoom → lấy roomId
  ///   bước 2: assignDevice(roomId, deviceCode)
  ///   nếu bước 2 lỗi → deleteRoom(roomId) để rollback
  @override
  Future<String> createRoomWithDevice({
    required String roomName,
    required String deviceCode,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock: trả về roomId giả
    // TODO: thay bằng API call thực
    // Ví dụ:
    // final response = await dio.post('/rooms', data: {
    //   'name': roomName,
    //   'deviceCode': deviceCode,
    // });
    // return response.data['roomId'];
    return 'room_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Mock: Gán thiết bị vào phòng đã tồn tại.
  @override
  Future<void> assignDeviceToRoom({
    required String roomId,
    required String deviceCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: thay bằng API call thực
    // Ví dụ:
    // await dio.post('/rooms/$roomId/devices', data: {
    //   'deviceCode': deviceCode,
    // });

    // Mock error simulation (comment out khi dùng thực):
    // if (deviceCode == 'ERR_TEST') {
    //   throw Exception('Thiết bị đã được gán cho phòng khác');
    // }
  }
}
