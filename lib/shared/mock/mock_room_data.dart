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
          serialNumber: 'SN-00101',
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
          serialNumber: 'SN-00102',
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
          serialNumber: 'SN-00103',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.medium,
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
        name: 'Warehouse A',
        description: '15 sensors',
        totalDevices: 15,
        onlineDevices: 13,
        alertCount: 1,
        createdAt: DateTime(2024, 2, 5),
      ),
      devices: [
        DeviceEntity(
          id: 'd4',
          name: 'Thiết bị 01',
          roomId: 'r2',
          serialNumber: 'SN-00201',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.strong,
          currentTemperature: 22.1,
          currentHumidity: 65,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        DeviceEntity(
          id: 'd5',
          name: 'Thiết bị 02',
          roomId: 'r2',
          serialNumber: 'SN-00202',
          status: DeviceStatus.online,
          connectivity: ConnectivityStatus.weak,
          currentTemperature: 35.4,
          currentHumidity: 88,
          threshold: _threshold,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ],
    ),
    RoomWithDevices(
      room: RoomEntity(
        id: 'r3',
        name: 'Storage Zone C',
        description: '8 sensors',
        totalDevices: 8,
        onlineDevices: 8,
        alertCount: 0,
        createdAt: DateTime(2024, 3, 1),
      ),
      devices: [
        DeviceEntity(
          id: 'd6',
          name: 'Thiết bị 01',
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
          id: 'd7',
          name: 'Sensor Cool 02',
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
  ];
}
