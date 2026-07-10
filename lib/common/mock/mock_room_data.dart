/// Mock dữ liệu phòng và thiết bị — dùng chung toàn app cho đến khi có API thật
library;

import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

const _threshold = ThresholdEntity(
  tempHigh: 35,
  tempLow: 10,
  humidHigh: 80,
  humidLow: 30,
);

List<RoomWithDevices> buildMockRooms() {
  return [
    RoomWithDevices(
      room: RoomEntity(
        id: 'r1',
        name: 'Khu vực A',
        description: '15 thiết bị',
        totalDevices: 15,
        onlineDevices: 14,
        alertCount: 1,
        createdAt: DateTime(2024, 1, 10),
      ),
      devices: [
        DeviceEntity(
          id: 'd1',
          name: 'Thiết bị 01',
          roomId: 'r1',
          serialNumber: '24:42:E3:04:41:D2',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.strong,
          currentTemperature: 22.1,
          currentHumidity: 65,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        DeviceEntity(
          id: 'd2',
          name: 'Thiết bị 02',
          roomId: 'r1',
          serialNumber: '24:42:E3:04:41:D3',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.strong,
          currentTemperature: 22.1,
          currentHumidity: 65,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        DeviceEntity(
          id: 'd3',
          name: 'Thiết bị 03',
          roomId: 'r1',
          serialNumber: '24:42:E3:04:41:D4',
          status: DeviceStatus.offline,
          connectivity: ConnectivityStatus.none,
          currentTemperature: 35.4,
          currentHumidity: 88,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ],
    ),
    RoomWithDevices(
      room: RoomEntity(
        id: 'r2',
        name: 'Kho lạnh 1',
        description: '4 thiết bị',
        totalDevices: 4,
        onlineDevices: 4,
        alertCount: 0,
        createdAt: DateTime(2024, 2, 5),
      ),
      devices: [
        DeviceEntity(
          id: 'd4',
          name: 'HMS 01',
          roomId: 'r2',
          serialNumber: '24:42:E3:04:41:D2',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.strong,
          currentTemperature: 22.1,
          currentHumidity: 65,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        DeviceEntity(
          id: 'd5',
          name: 'HMS 02',
          roomId: 'r2',
          serialNumber: '24:42:E3:04:41:D3',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.strong,
          currentTemperature: 35.4,
          currentHumidity: 88,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        DeviceEntity(
          id: 'd6',
          name: 'HMS 03',
          roomId: 'r2',
          serialNumber: '24:42:E3:04:41:D4',
          status: DeviceStatus.offline,
          connectivity: ConnectivityStatus.none,
          currentTemperature: null,
          currentHumidity: null,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        DeviceEntity(
          id: 'd7',
          name: 'HMS 04',
          roomId: 'r2',
          serialNumber: '24:42:E3:04:41:D5',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.medium,
          currentTemperature: 18.5,
          currentHumidity: 55,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
      ],
    ),
    RoomWithDevices(
      room: RoomEntity(
        id: 'r3',
        name: 'Storage Zone C',
        description: '2 thiết bị',
        totalDevices: 2,
        onlineDevices: 1,
        alertCount: 0,
        createdAt: DateTime(2024, 3, 1),
      ),
      devices: [
        DeviceEntity(
          id: 'd8',
          name: 'Phòng 01',
          roomId: 'r3',
          serialNumber: 'SN-00301',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.strong,
          currentTemperature: 18.5,
          currentHumidity: 55,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        DeviceEntity(
          id: 'd9',
          name: 'Phòng 02',
          roomId: 'r3',
          serialNumber: 'SN-00302',
          status: DeviceStatus.offline,
          connectivity: ConnectivityStatus.none,
          currentTemperature: null,
          currentHumidity: null,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    // Phòng chưa có thiết bị — để test trạng thái rỗng
    RoomWithDevices(
      room: RoomEntity(
        id: 'r4',
        name: 'Phòng trống',
        totalDevices: 0,
        onlineDevices: 0,
        alertCount: 0,
        createdAt: DateTime(2024, 4, 1),
      ),
      devices: [],
    ),
  ];
}

/// Danh sách thiết bị chưa được gán phòng nào (unassigned)
List<DeviceEntity> buildUnassignedDevices() {
  return [
    DeviceEntity(
      id: 'u1',
      name: 'Thiết bị chưa gán 01',
      roomId: '',
      serialNumber: 'AA:BB:CC:11:22:33',
      status: DeviceStatus.online,
      connectivity: ConnectivityStatus.strong,
      currentTemperature: 25.0,
      currentHumidity: 70,
      threshold: _threshold,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    DeviceEntity(
      id: 'u2',
      name: 'Thiết bị chưa gán 02',
      roomId: '',
      serialNumber: 'AA:BB:CC:11:22:44',
      status: DeviceStatus.offline,
      connectivity: ConnectivityStatus.none,
      currentTemperature: null,
      currentHumidity: null,
      threshold: _threshold,
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DeviceEntity(
      id: 'u3',
      name: 'Cảm biến dự phòng',
      roomId: '',
      serialNumber: 'CC:DD:EE:55:66:77',
      status: DeviceStatus.online,
      connectivity: ConnectivityStatus.medium,
      currentTemperature: 28.5,
      currentHumidity: 60,
      threshold: _threshold,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];
}
