import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/hourly_report_entity.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final _mockRooms = buildMockRooms();

  @override
  Future<Either<String, DeviceHistoryDataEntity>> getDeviceHistory(
    String deviceId, {
    String range = '24h',
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final now = DateTime.now();
      final random = Random();
      final List<DeviceHistoryPoint> points = [];

      for (int i = 24; i >= 0; i--) {
        final time = now.subtract(Duration(hours: i));
        final temp = 15 + random.nextDouble() * 25;
        final humid = 40 + random.nextDouble() * 50;

        points.add(
          DeviceHistoryPoint(
            timestamp: time,
            temperature: temp,
            humidity: humid,
          ),
        );
      }

      const threshold = ThresholdEntity(
        tempHigh: 35.0,
        tempLow: 18.0,
        humidHigh: 80.0,
        humidLow: 45.0,
      );

      return Right(
        DeviceHistoryDataEntity(points: points, threshold: threshold),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<RoomEntity>>> getRooms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_mockRooms.map((r) => r.room).toList());
  }

  @override
  Future<Either<String, List<DeviceEntity>>> getRoomDevices(
    String roomId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final room = _mockRooms.where((r) => r.room.id == roomId).firstOrNull;
    if (room != null) {
      return Right(room.devices);
    }
    return Left('Room not found');
  }

  @override
  Future<Either<String, List<HourlyReportEntity>>> getDeviceReport(
    String deviceId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Find the device to get its thresholds
      DeviceEntity? targetDevice;
      for (final room in _mockRooms) {
        final device = room.devices.where((d) => d.id == deviceId).firstOrNull;
        if (device != null) {
          targetDevice = device;
          break;
        }
      }

      final maxTemp = targetDevice?.threshold?.tempHigh ?? 35.0;
      final maxHumid = targetDevice?.threshold?.humidHigh ?? 80.0;

      final random = Random();
      final List<HourlyReportEntity> reportData = [];

      // Generate 24 records for the specified date (from 00:00 to 23:00)
      for (int i = 0; i < 24; i++) {
        final time = DateTime(date.year, date.month, date.day, i, 0);

        // Randomly generate values around thresholds to show alerts
        final temp =
            maxTemp - 10 + random.nextDouble() * 20; // Some will exceed
        final humid =
            maxHumid - 20 + random.nextDouble() * 40; // Some will exceed

        // Random signal strength (-50 to -110)
        final signalStr = -50 - random.nextInt(60);

        ConnectionStatus status;
        if (signalStr > -70) {
          status = ConnectionStatus.stable;
        } else if (signalStr > -90) {
          status = ConnectionStatus.weak;
        } else {
          status = ConnectionStatus.disconnected;
        }

        reportData.add(
          HourlyReportEntity(
            time: time,
            temperature: temp,
            humidity: humid,
            signalStrength: status == ConnectionStatus.disconnected
                ? null
                : signalStr,
            connectionStatus: status,
            maxTemperature: maxTemp,
            maxHumidity: maxHumid,
          ),
        );
      }

      return Right(reportData);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, PaginatedDeviceResult>> getDevices({
    String? roomId,
    String? search,
    String? sortOrder,
    String? statusFilter,
    int page = 1,
    int limit = 20,
  }) async {
    // Giả lập network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      List<DeviceEntity> allDevices = [];

      // Phẳng hoá danh sách thiết bị từ các phòng và gán tên phòng
      for (final roomWithDevices in buildMockRooms()) {
        for (final device in roomWithDevices.devices) {
          allDevices.add(device.copyWith(roomName: roomWithDevices.room.name));
        }
      }
      
      // Thêm các thiết bị chưa gán phòng
      for (final device in buildUnassignedDevices()) {
         allDevices.add(device.copyWith(roomName: null));
      }

      // 1. Lọc theo phòng (nếu có)
      if (roomId != null && roomId.isNotEmpty) {
        allDevices = allDevices.where((d) => d.roomId == roomId).toList();
      }

      // 2. Lọc theo trạng thái
      if (statusFilter != null && statusFilter != 'all') {
        if (statusFilter == 'online') {
          allDevices = allDevices.where((d) => d.status == DeviceStatus.online).toList();
        } else if (statusFilter == 'offline') {
          allDevices = allDevices.where((d) => d.status == DeviceStatus.offline).toList();
        }
      }

      // 3. Tìm kiếm theo tên
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        allDevices = allDevices.where((d) => d.name.toLowerCase().contains(q)).toList();
      }

      // 4. Sắp xếp
      // Mặc định là A-Z
      allDevices.sort((a, b) => a.name.compareTo(b.name));
      if (sortOrder == 'Z-A') {
        allDevices = allDevices.reversed.toList();
      }

      // 5. Phân trang
      final totalCount = allDevices.length;
      final startIndex = (page - 1) * limit;
      
      List<DeviceEntity> pagedDevices = [];
      if (startIndex < totalCount) {
        final endIndex = min(startIndex + limit, totalCount);
        pagedDevices = allDevices.sublist(startIndex, endIndex);
      }

      return Right(PaginatedDeviceResult(devices: pagedDevices, totalCount: totalCount));
    } catch (e) {
      return Left(e.toString());
    }
  }
}
