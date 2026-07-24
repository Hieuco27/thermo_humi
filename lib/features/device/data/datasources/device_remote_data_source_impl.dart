import 'package:dio/dio.dart';
import 'package:thermo_humi/core/constants/api_endpoints.dart';
import 'package:thermo_humi/features/device/data/datasources/device_remote_data_source.dart';
import 'package:thermo_humi/features/device/data/models/device_model.dart';

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio _dio;

  DeviceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<DeviceModel>> getAllDevices(String userId) async {
    final response = await _dio.post(
      ApiEndpoints.deviceQuery,
      data: {"type": 1},
    );

    if (response.statusCode == 200 && response.data != null) {
      final body = response.data;
      if (body['success'] == true && body['data'] != null) {
        final dataObj = body['data'];
        final List<DeviceModel> allDevices = [];

        // Lấy danh sách thiết bị đã được gán vào phòng
        if (dataObj['locations'] is List) {
          final List locations = dataObj['locations'];
          for (final location in locations) {
            final String? roomName = location['name'] as String?;

            if (location['devices'] is List) {
              final List devicesList = location['devices'];
              for (final d in devicesList) {
                final device = DeviceModel.fromJson(d as Map<String, dynamic>);
                allDevices.add(
                  DeviceModel(
                    id: device.id,
                    name: device.name,
                    roomId: device.roomId,
                    roomName: roomName,
                    serialNumber: device.serialNumber,
                    status: device.status,
                    connectivity: device.connectivity,
                    sensors: device.sensors,
                    lastUpdatedAt: device.lastUpdatedAt,
                  ),
                );
              }
            }
          }
        }

        // Lấy danh sách thiết bị chưa gán phòng
        if (dataObj['deviceUnassgin'] is List) {
          final List unassignedList = dataObj['deviceUnassgin'];
          for (final d in unassignedList) {
            final device = DeviceModel.fromJson(d as Map<String, dynamic>);
            allDevices.add(
              DeviceModel(
                id: device.id,
                name: device.name,
                roomId: device.roomId,
                roomName: null, // Chưa gán phòng
                serialNumber: device.serialNumber,
                status: device.status,
                connectivity: device.connectivity,
                sensors: device.sensors,
                lastUpdatedAt: device.lastUpdatedAt,
              ),
            );
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
