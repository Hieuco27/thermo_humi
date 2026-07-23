import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/features/device/data/datasources/device_remote_data_source.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/hourly_report_entity.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _dataSource;

  DeviceRepositoryImpl(this._dataSource);

  // ─────────────────────────────────────────────────────────────
  // getDeviceHistory — mock (chưa có API thật)
  // ─────────────────────────────────────────────────────────────
  @override
  Future<Either<String, DeviceHistoryDataEntity>> getDeviceHistory(
    String deviceId, {
    String range = '24h',
  }) async {
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

  // ─────────────────────────────────────────────────────────────
  // getDeviceReport — mock (chưa có API thật)
  // ─────────────────────────────────────────────────────────────
  @override
  Future<Either<String, List<HourlyReportEntity>>> getDeviceReport(
    String deviceId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      const maxTemp = 35.0;
      const maxHumid = 80.0;
      final random = Random();
      final List<HourlyReportEntity> reportData = [];

      for (int i = 0; i < 24; i++) {
        final time = DateTime(date.year, date.month, date.day, i, 0);
        final temp = maxTemp - 10 + random.nextDouble() * 20;
        final humid = maxHumid - 20 + random.nextDouble() * 40;
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

  // ─────────────────────────────────────────────────────────────
  // getDevices — 1 API call duy nhất lấy tất cả thiết bị
  // ─────────────────────────────────────────────────────────────
  @override
  Future<Either<String, PaginatedDeviceResult>> getDevices({
    String? roomId,
    String? search,
    String? sortOrder,
    String? statusFilter,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // 1. Lấy userId từ SecureStorage
      final storage = sl<SecureStorage>();
      final userDataStr = await storage.read(AppConstants.kUserData);
      String? userId;
      if (userDataStr != null) {
        final Map<String, dynamic> userJson = jsonDecode(userDataStr);
        userId = userJson['id']?.toString();
      }

      if (userId == null) {
        return const Right(PaginatedDeviceResult(devices: [], totalCount: 0));
      }

      // 2. Một API call duy nhất — trả về tất cả devices (có phòng + chưa gán)
      List<DeviceEntity> allDevices = await _dataSource.getAllDevices(userId);

      // 3. Lọc theo phòng
      if (roomId != null && roomId.isNotEmpty) {
        allDevices = allDevices.where((d) => d.roomId == roomId).toList();
      }

      // 4. Lọc theo trạng thái
      if (statusFilter != null && statusFilter != 'all') {
        if (statusFilter == 'online') {
          allDevices = allDevices
              .where((d) => d.status == DeviceStatus.online)
              .toList();
        } else if (statusFilter == 'offline') {
          allDevices = allDevices
              .where((d) => d.status == DeviceStatus.offline)
              .toList();
        }
      }

      // 5. Tìm kiếm theo tên
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        allDevices = allDevices
            .where((d) => d.name.toLowerCase().contains(q))
            .toList();
      }

      // 6. Sắp xếp A-Z (mặc định) hoặc Z-A
      allDevices.sort((a, b) => a.name.compareTo(b.name));
      if (sortOrder == 'Z-A') {
        allDevices = allDevices.reversed.toList();
      }

      // 7. Phân trang
      final totalCount = allDevices.length;
      final startIndex = (page - 1) * limit;
      List<DeviceEntity> pagedDevices = [];
      if (startIndex < totalCount) {
        final endIndex = min(startIndex + limit, totalCount);
        pagedDevices = allDevices.sublist(startIndex, endIndex);
      }

      return Right(
        PaginatedDeviceResult(devices: pagedDevices, totalCount: totalCount),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────
  // addDevice — delegate sang datasource
  // ─────────────────────────────────────────────────────────────
  @override
  Future<Either<String, void>> addDevice({
    required String imei,
    required String deviceName,
    required String userId,
  }) async {
    try {
      await _dataSource.addDevice(
        imei: imei,
        deviceName: deviceName,
        userId: userId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left('Lỗi kết nối: ${e.message}');
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────
  // getUnassignedDevices — lấy tất cả rồi lọc chưa gán phòng
  // ─────────────────────────────────────────────────────────────
  @override
  Future<Either<String, List<DeviceEntity>>> getUnassignedDevices(
    String userId,
  ) async {
    try {
      final all = await _dataSource.getAllDevices(userId);
      // Lọc ra thiết bị không có roomName = chưa gán phòng
      final unassigned = all.where((d) => d.roomName == null).toList();
      return Right(unassigned);
    } on DioException catch (e) {
      return Left('Lỗi kết nối: ${e.message}');
    } catch (e) {
      return Left('Đã có lỗi xảy ra: $e');
    }
  }
}
