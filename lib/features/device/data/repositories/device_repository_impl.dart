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
}
