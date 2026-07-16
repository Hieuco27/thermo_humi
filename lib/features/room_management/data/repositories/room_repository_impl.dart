library;

import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
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
    return 'room_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Mock: Gán thiết bị vào phòng đã tồn tại.
  @override
  Future<void> assignDeviceToRoom({
    required String roomId,
    required String deviceCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<String> createRoomOnly({required String roomName}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return 'room_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Mock: Lấy danh sách phòng cho RoomPickerSheet.
  /// TODO: thay bằng API call thực, ví dụ:
  ///   final response = await dio.get('/rooms');
  ///   return (response.data['rooms'] as List).map(RoomEntity.fromJson).toList();
  @override
  Future<List<RoomEntity>> getAvailableRooms() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      RoomEntity(
        id: 'room_001',
        name: 'Phòng khách',
        totalDevices: 2,
        onlineDevices: 1,
        alertCount: 0,
        createdAt: now,
      ),
      RoomEntity(
        id: 'room_002',
        name: 'Phòng ngủ',
        totalDevices: 1,
        onlineDevices: 1,
        alertCount: 0,
        createdAt: now,
      ),
      RoomEntity(
        id: 'room_003',
        name: 'Nhà bếp',
        totalDevices: 0,
        onlineDevices: 0,
        alertCount: 0,
        createdAt: now,
      ),
      RoomEntity(
        id: 'room_003',
        name: 'Nhà bếp',
        totalDevices: 0,
        onlineDevices: 0,
        alertCount: 0,
        createdAt: now,
      ),
      RoomEntity(
        id: 'room_003',
        name: 'Nhà bếp',
        totalDevices: 0,
        onlineDevices: 0,
        alertCount: 0,
        createdAt: now,
      ),
    ];
  }

  /// Mock: Tạo thiết bị độc lập, không gán phòng.
  /// TODO: thay bằng API call thực, ví dụ:
  ///   await dio.post('/devices', data: {'deviceCode': deviceCode});
  @override
  Future<void> createUnassignedDevice({required String deviceCode}) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}
