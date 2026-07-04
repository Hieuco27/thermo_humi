import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_report_entity.dart';

abstract class DeviceRepository {
  Future<Either<String, DeviceHistoryDataEntity>> getDeviceHistory(
    String deviceId, {
    String range = '24h',
  });

  Future<Either<String, DeviceReportDataEntity>> getDeviceReport(
    String deviceId, {
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  });
}
