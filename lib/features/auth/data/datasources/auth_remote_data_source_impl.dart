import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:thermo_humi/core/constants/api_endpoints.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final SecureStorage _secureStorage;

  AuthRemoteDataSourceImpl(this._dio, this._secureStorage);

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'UserName': email, 'Password': password},
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Đăng nhập thất bại');
    }

    final data = response.data['data'];
    final accessToken = data['accessToken'] ?? '';
    final refreshToken = data['refreshToken'] ?? '';
    final userName = data['userName'] ?? '';

    String realUserId = userName;
    if (accessToken.isNotEmpty) {
      try {
        final parts = accessToken.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final claims = json.decode(decoded);

          if (claims['sub'] != null) {
            realUserId = claims['sub'].toString();
          }
        }
      } catch (e) {
        // Ignored, fallback to userName
      }
      await _secureStorage.write(AppConstants.kAccessToken, accessToken);
    }

    return UserModel(
      id: realUserId, // Đã lấy đúng sub (ID) từ JWT
      name: userName, // Nếu API không trả về name, dùng tạm userName
      email: email,
      phone: userName,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<UserModel> signUp(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> changePassword(UserModel user, String password) {
    throw UnimplementedError();
  }
}
