import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

@lazySingleton
class MockAlertDataSource {
  final List<AlertModel> _mockAlerts = [];
  final StreamController<AlertModel> _socketStreamController =
      StreamController<AlertModel>.broadcast();
  Timer? _mockSocketTimer;

  // Cache danh sách phòng & thiết bị để dùng
  late final List<RoomEntity> _rooms;
  late final List<DeviceEntity> _devices;

  MockAlertDataSource() {
    _initMockDataFromRooms();
    _generateInitialMockData();
    // Simulate real-time events every 30 seconds
    _mockSocketTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_devices.isEmpty) return;
      // Lấy ngẫu nhiên thiết bị đầu tiên để giả lập alert mới
      final device = _devices.first;
      final room = _rooms.firstWhere(
        (r) => r.id == device.roomId,
        orElse: () => _rooms.first,
      );

      final newAlert = AlertModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AlertType.thresholdExceeded,
        title: 'Vượt ngưỡng nhiệt độ',
        description: '${device.name} tại ${room.name} đang ở mức cảnh báo.',
        createdAt: DateTime.now(),
        isResolved: false,
        deviceId: device.id,
        roomId: room.id,
      );
      _mockAlerts.insert(0, newAlert);
      _socketStreamController.add(newAlert);
    });
  }

  void dispose() {
    _mockSocketTimer?.cancel();
    _socketStreamController.close();
  }

  void _initMockDataFromRooms() {
    final mockRoomsWithDevices = buildMockRooms();
    _rooms = mockRoomsWithDevices.map((e) => e.room).toList();
    _devices = mockRoomsWithDevices.expand((e) => e.devices).toList();
  }

  void _generateInitialMockData() {
    if (_devices.isEmpty) return;

    final now = DateTime.now();

    // Lấy 1 số thiết bị mẫu từ list
    final d1 = _devices.isNotEmpty ? _devices[0] : null;
    final r1 = d1 != null ? _rooms.firstWhere((r) => r.id == d1.roomId) : null;

    final d2 = _devices.length > 1 ? _devices[1] : null;
    final r2 = d2 != null ? _rooms.firstWhere((r) => r.id == d2.roomId) : null;

    final d3 = _devices.length > 2 ? _devices[2] : null;
    final r3 = d3 != null ? _rooms.firstWhere((r) => r.id == d3.roomId) : null;

    if (d1 != null && r1 != null) {
      _mockAlerts.add(
        AlertModel(
          id: '${now.millisecondsSinceEpoch}_1',
          type: AlertType.thresholdExceeded,
          title: 'Vượt ngưỡng nhiệt độ',
          description: '${d1.name} tại ${r1.name} đang ở 35.4°C, vượt ngưỡng.',
          createdAt: now.subtract(const Duration(minutes: 5)),
          isResolved: false,
          deviceId: d1.id,
          roomId: r1.id,
        ),
      );
    }

    if (d2 != null && r2 != null) {
      _mockAlerts.add(
        AlertModel(
          id: '${now.millisecondsSinceEpoch}_2',
          type: AlertType.humidityAbnormal,
          title: 'Độ ẩm bất thường',
          description: '${d2.name} tại ${r2.name} đã trở lại 78%, dưới ngưỡng',
          createdAt: now.subtract(const Duration(hours: 3)),
          isResolved: true,
          deviceId: d2.id,
          roomId: r2.id,
        ),
      );
    }

    if (d3 != null && r3 != null) {
      _mockAlerts.add(
        AlertModel(
          id: '${now.millisecondsSinceEpoch}_3',
          type: AlertType.deviceOffline,
          title: 'Mất kết nối thiết bị',
          description: '${d3.name} tại ${r3.name} đã ngắt kết nối',
          createdAt: now.subtract(const Duration(days: 1)),
          isResolved: false,
          deviceId: d3.id,
          roomId: r3.id,
        ),
      );
    }

    // Sort by createdAt descending
    _mockAlerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<AlertModel>> getAlerts({String? cursor, int limit = 20}) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    int startIndex = 0;
    if (cursor != null) {
      final index = _mockAlerts.indexWhere((element) => element.id == cursor);
      if (index != -1) {
        startIndex = index + 1;
      }
    }

    if (startIndex >= _mockAlerts.length) return [];

    final endIndex = (startIndex + limit < _mockAlerts.length)
        ? startIndex + limit
        : _mockAlerts.length;

    return _mockAlerts.sublist(startIndex, endIndex);
  }

  Future<void> resolveAlert(String id) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final index = _mockAlerts.indexWhere((element) => element.id == id);
    if (index != -1) {
      _mockAlerts[index] = _mockAlerts[index].copyWith(isResolved: true);
    } else {
      throw Exception('Alert not found');
    }
  }

  Stream<AlertModel> watchAlertEvents() {
    return _socketStreamController.stream;
  }
}
