import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_history_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/hourly_report_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

abstract class DeviceRepository {
  Future<Either<String, DeviceHistoryDataEntity>> getDeviceHistory(
    String deviceId, {
    String range = '24h',
  });

  Future<Either<String, List<RoomEntity>>> getRooms();

  Future<Either<String, List<DeviceEntity>>> getRoomDevices(String roomId);

  Future<Either<String, List<HourlyReportEntity>>> getDeviceReport(
    String deviceId,
    DateTime date,
  );

  Future<Either<String, PaginatedDeviceResult>> getDevices({
    String? roomId,
    String? search,
    String? sortOrder,
    String? statusFilter,
    int page = 1,
    int limit = 20,
  });
}
