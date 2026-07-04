import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_report_entity.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
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
      
      // Generate 24 hours of data (1 point per hour for simplicity, or 24 points)
      for (int i = 24; i >= 0; i--) {
        final time = now.subtract(Duration(hours: i));
        // Base temp around 22, sometimes goes up to 40 (to simulate alert)
        final temp = 15 + random.nextDouble() * 25; // 15 to 40
        // Base humidity around 60, sometimes goes up to 90
        final humid = 40 + random.nextDouble() * 50; // 40 to 90
        
        points.add(DeviceHistoryPoint(
          timestamp: time,
          temperature: temp,
          humidity: humid,
        ));
      }

      const threshold = ThresholdEntity(
        tempHigh: 35.0,
        tempLow: 18.0,
        humidHigh: 80.0,
        humidLow: 45.0,
      );

      return Right(DeviceHistoryDataEntity(points: points, threshold: threshold));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, DeviceReportDataEntity>> getDeviceReport(
    String deviceId, {
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final now = DateTime.now();
      final random = Random();
      final List<DeviceReportPoint> points = [];
      
      for (int i = 0; i < pageSize; i++) {
        final time = now.subtract(Duration(minutes: i * 30 + (page - 1) * pageSize * 30));
        final temp = 15 + random.nextDouble() * 25;
        final humid = 40 + random.nextDouble() * 50;
        
        ReportStatus status = ReportStatus.normal;
        if (temp > 35.0 || humid > 80.0) {
          status = ReportStatus.highAlert;
        } else if (temp < 18.0 || humid < 45.0) {
          status = ReportStatus.lowAlert;
        }

        points.add(DeviceReportPoint(
          timestamp: time,
          temperature: temp,
          humidity: humid,
          status: status,
        ));
      }

      return Right(DeviceReportDataEntity(
        points: points,
        totalRecords: 100, // mock total
        currentPage: page,
      ));
    } catch (e) {
      return Left(e.toString());
    }
  }
}
