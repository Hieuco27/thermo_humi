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
      '${AppConfig.baseUrl}${ApiEndpoints.locationQuery}',
      data: {"type": 4},
    );

    dynamic data = response.data;
    if (data is Map && data.containsKey('data')) {
      data = data['data'];
    }

    if (data is List) {
      return data.map((e) => RoomModel.fromJson(e)).toList();
    }
    return [];
  }
}
