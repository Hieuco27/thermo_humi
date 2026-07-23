import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thermo_humi/features/room/data/datasources/room/room_remote_datasource.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource _remoteDataSource;

  RoomRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, List<RoomEntity>>> getRooms(String userId) async {
    try {
      final rooms = await _remoteDataSource.getRooms(userId);
      return Right(rooms);
    } on DioException catch (e) {
      String? message;
      final data = e.response?.data;
      if (data is Map) {
        message = data['message'] as String?;
      }
      return Left(message ?? _mapDioError(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Kết nối mạng chậm, vui lòng thử lại.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến máy chủ.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'Phiên đăng nhập hết hạn.';
        if (statusCode == 403) return 'Bạn không có quyền truy cập.';
        if (statusCode == 404) return 'Không tìm thấy dữ liệu.';
        if (statusCode != null && statusCode >= 500) {
          return 'Lỗi máy chủ, vui lòng thử lại sau.';
        }
        return 'Lỗi không xác định (${statusCode ?? 'unknown'}).';
      default:
        return 'Đã xảy ra lỗi, vui lòng thử lại.';
    }
  }
}
