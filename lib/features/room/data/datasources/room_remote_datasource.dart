/// Abstract interface — Room Remote DataSource
/// Định nghĩa contract gọi API liên quan đến phòng & thiết bị online.
library;

import 'package:thermo_humi/features/room/data/models/device_online_response_model.dart';

abstract class RoomRemoteDataSource {
  /// Lấy danh sách phòng kèm thiết bị đang online.
  /// API: GET /device-online/query
  Future<DeviceOnlineResponseModel> getDeviceOnline();
}
