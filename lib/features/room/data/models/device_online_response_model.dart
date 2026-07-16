/// DTO — Toàn bộ Response của API: GET /device-online/query
/// Bao gồm: success, message, data (list of locations)
library;

import 'package:thermo_humi/features/room/data/models/location_model.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

class DeviceOnlineResponseModel {
  final bool success;
  final String message;
  final List<LocationModel> data;

  const DeviceOnlineResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  /// Parse toàn bộ JSON response từ API
  factory DeviceOnlineResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final locationList = (rawData is List)
        ? rawData
            .whereType<Map<String, dynamic>>()
            .map(LocationModel.fromJson)
            .toList()
        : <LocationModel>[];

    return DeviceOnlineResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: locationList,
    );
  }

  /// Chuyển toàn bộ response → `List<RoomWithDevices>` để dùng ở presentation
  List<RoomWithDevices> toRoomWithDevicesList() {
    return data.map((location) => location.toRoomWithDevices()).toList();
  }
}
