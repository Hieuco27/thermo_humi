import 'package:dio/dio.dart';
import 'package:thermo_humi/core/constants/api_endpoints.dart';
import 'package:thermo_humi/features/device/data/datasources/device_remote_data_source.dart';
import 'package:thermo_humi/features/room/data/models/device_model.dart';

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio _dio;

  DeviceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<DeviceModel>> getAllDevices(String userId) async {
    final response = await _dio.post(
      ApiEndpoints.deviceQuery,
      data: {"type": 2, "userId": userId},
    );

    if (response.statusCode == 200 && response.data != null) {
      final body = response.data;
      if (body['success'] == true && body['data'] is List) {
        final List locations = body['data'];
        final List<DeviceModel> allDevices = [];

        for (final location in locations) {
          final isUnassigned = location['locationId'] == 'UNASSIGNED';
          // Phòng thật có tên, UNASSIGNED dùng null để tile hiện "Chưa gán phòng"
          final String? roomName = isUnassigned ? null : location['name'] as String?;

          if (location['devices'] is List) {
            final List devicesList = location['devices'];
            for (final d in devicesList) {
              final device = DeviceModel.fromJson(d as Map<String, dynamic>);
              // Gán roomName vào device (dùng copyWith từ DeviceEntity)
              allDevices.add(
                DeviceModel(
                  id: device.id,
                  name: device.name,
                  roomId: device.roomId,
                  roomName: roomName,
                  serialNumber: device.serialNumber,
                  status: device.status,
                  connectivity: device.connectivity,
                  currentTemperature: device.currentTemperature,
                  currentHumidity: device.currentHumidity,
                  threshold: device.threshold,
                  lastUpdatedAt: device.lastUpdatedAt,
                ),
              );
            }
          }
        }

        return allDevices;
      }
      throw Exception(body['message'] ?? 'Lỗi dữ liệu từ máy chủ');
    }
    throw Exception('Lỗi máy chủ: ${response.statusCode}');
  }

  /// POST thêm thiết bị mới.
  @override
  Future<void> addDevice({
    required String imei,
    required String deviceName,
    required String userId,
  }) async {
    final now = DateTime.now().toUtc();
    final timeStamp =
        "${now.toIso8601String().split('.').first}.${now.millisecond.toString().padLeft(3, '0')}Z";

    final response = await _dio.post(
      '/device/update',
      data: {
        "actionType": 1,
        "info": {
          "id": "",
          "deviceId": 0,
          "imei": imei,
          "companyId": "",
          "deviceName": deviceName,
          "userId": userId,
          "locationId": "",
          "timeStamp": timeStamp,
          "isActive": true,
          "sensors": [],
        },
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Thêm thiết bị thất bại');
      }
      return;
    }
    throw Exception('Lỗi kết nối: ${response.statusCode}');
  }
}
