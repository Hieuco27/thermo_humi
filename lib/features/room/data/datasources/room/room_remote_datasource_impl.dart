import 'package:dio/dio.dart';
import 'package:thermo_humi/core/constants/api_endpoints.dart';
import 'package:thermo_humi/core/config/app_config.dart';
import 'package:thermo_humi/features/room/data/datasources/room/room_remote_datasource.dart';
import 'package:thermo_humi/features/room/data/models/room_model.dart';

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio _dio;

  RoomRemoteDataSourceImpl(this._dio);

  @override
  Future<List<RoomModel>> getRooms(String userId) async {
    final response = await _dio.post(
      ApiEndpoints.deviceQuery,
      data: {"type": 1},
    );

    if (response.statusCode == 200 && response.data != null) {
      final body = response.data;
      if (body['success'] == true && body['data'] != null) {
        final dataObj = body['data'];
        if (dataObj['locations'] is List) {
          final List locations = dataObj['locations'];
          final List<RoomModel> allRooms = [];

          for (final loc in locations) {
            // Chỉ lấy các phòng có tên (bỏ qua phòng không tên / UNASSIGNED nếu có)
            if (loc['name'] != null &&
                loc['name'].toString().trim().isNotEmpty) {
              allRooms.add(RoomModel.fromJson(loc as Map<String, dynamic>));
            }
          }

          return allRooms;
        }
      }
    }
    return [];
  }

  @override
  Future<void> addRoom(String name) async {
    final response = await _dio.post(
      ApiEndpoints.locationUpdate,
      data: {
        "actionType": 4,
        "info": {"name": name},
      },
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        response.data != null) {
      final body = response.data;
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Lỗi khi tạo phòng mới');
      }
    } else {
      throw Exception('Lỗi kết nối máy chủ khi tạo phòng');
    }
  }
}
