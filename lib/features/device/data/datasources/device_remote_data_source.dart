/// Abstract interface — Device Remote DataSource
/// Định nghĩa contract cho tất cả các lời gọi HTTP liên quan đến thiết bị.
library;

import 'package:thermo_humi/features/room/data/models/device_model.dart';

abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getAllDevices(String userId);

  /// Thêm thiết bị mới theo [imei], [deviceName], [userId].
  Future<void> addDevice({
    required String imei,
    required String deviceName,
    required String userId,
  });
}
