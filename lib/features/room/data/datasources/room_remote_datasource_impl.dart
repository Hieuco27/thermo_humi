/// Implementation — Room Remote DataSource
/// Thực hiện gọi HTTP thực tế đến API backend.
library;

import 'package:dio/dio.dart';
import 'package:thermo_humi/core/constants/api_endpoints.dart';
import 'package:thermo_humi/features/room/data/datasources/room_remote_datasource.dart';
import 'package:thermo_humi/features/room/data/models/device_online_response_model.dart';

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio _dio;

  RoomRemoteDataSourceImpl(this._dio);

  @override
  Future<DeviceOnlineResponseModel> getDeviceOnline() async {
    final response = await _dio.post(
      ApiEndpoints.deviceOnlineQuery,
      data: {'type': 1},
    );

    if (response.data == null) {
      throw Exception('Response rỗng từ /device-online/query');
    }

    // Kiểm tra success từ API
    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Lấy danh sách thiết bị thất bại',
      );
    }

    return DeviceOnlineResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
