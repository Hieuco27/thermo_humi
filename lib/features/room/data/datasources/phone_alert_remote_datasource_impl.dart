/// Implementation — Phone Alert Remote DataSource
/// Thực hiện gọi HTTP thực tế đến API backend qua Dio.
library;

import 'package:dio/dio.dart';
import 'package:thermo_humi/core/constants/api_endpoints.dart';
import 'package:thermo_humi/features/room/data/datasources/phone_alert_remote_datasource.dart';

class PhoneAlertRemoteDataSourceImpl implements PhoneAlertRemoteDataSource {
  final Dio _dio;

  PhoneAlertRemoteDataSourceImpl(this._dio);

  @override
  Future<void> sendOtp({required String phone}) async {
    final response = await _dio.post(
      ApiEndpoints.phoneAlertSendOtp,
      data: {'phone': phone},
    );

    if (response.data == null) {
      throw Exception('Response rỗng từ API gửi OTP');
    }

    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Gửi mã xác nhận thất bại',
      );
    }
  }

  @override
  Future<void> verifyOtp({
    required String roomId,
    required String phone,
    required String otp,
    String? note,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.phoneAlertVerifyOtp,
      data: {
        'roomId': roomId,
        'phone': phone,
        'otp': otp,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );

    if (response.data == null) {
      throw Exception('Response rỗng từ API xác nhận OTP');
    }

    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Mã xác nhận không đúng',
      );
    }
  }
}
