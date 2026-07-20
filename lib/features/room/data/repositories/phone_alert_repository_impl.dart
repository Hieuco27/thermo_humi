/// Implementation — Phone Alert Repository
/// Bridge giữa Domain và Data layer.
library;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thermo_humi/features/room/data/datasources/phone_alert_remote_datasource.dart';
import 'package:thermo_humi/features/room/domain/repositories/phone_alert_repository.dart';

class PhoneAlertRepositoryImpl implements PhoneAlertRepository {
  final PhoneAlertRemoteDataSource _remoteDataSource;

  PhoneAlertRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, void>> sendOtp({required String phone}) async {
    try {
      await _remoteDataSource.sendOtp(phone: phone);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> verifyOtp({
    required String roomId,
    required String phone,
    required String otp,
    String? note,
  }) async {
    try {
      await _remoteDataSource.verifyOtp(
        roomId: roomId,
        phone: phone,
        otp: otp,
        note: note,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
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
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          return data['message'] as String;
        }
        if (statusCode == 401) return 'Phiên đăng nhập hết hạn.';
        if (statusCode == 403) return 'Bạn không có quyền truy cập.';
        if (statusCode != null && statusCode >= 500) {
          return 'Lỗi máy chủ, vui lòng thử lại sau.';
        }
        return 'Lỗi không xác định (${statusCode ?? 'unknown'}).';
      default:
        return 'Đã xảy ra lỗi, vui lòng thử lại.';
    }
  }
}
