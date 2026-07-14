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
  Future<UserModel> signIn(
    String phone,
    String password,
    bool rememberMe,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'Phone': phone, 'Password': password},
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Đăng nhập thất bại');
    }

    final data = response.data['data'];

    String accessToken = '';
    String refreshToken = '';
    String userName = phone;
    String fullName = phone;

    if (data is Map) {
      accessToken = data['accessToken'] ?? '';
      refreshToken = data['refreshToken'] ?? '';
      userName = data['userName'] ?? userName;
      fullName = data['fullName'] ?? data['FullName'] ?? fullName;
      phone = data['phone'] ?? data['phoneNumber'] ?? phone;
    }

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
          if (claims['FullName'] != null || claims['fullName'] != null) {
            fullName = (claims['FullName'] ?? claims['fullName']).toString();
          }
          if (claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone'] !=
              null) {
            phone =
                claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone']
                    .toString();
          } else if (claims['phone'] != null) {
            phone = claims['phone'].toString();
          }
        }
      } catch (e) {
        // Ignored, fallback to userName
      }
      await _secureStorage.write(AppConstants.kAccessToken, accessToken);
      if (refreshToken.isNotEmpty) {
        await _secureStorage.write(AppConstants.kRefreshToken, refreshToken);
      }
      await _secureStorage.write('remember_me', rememberMe ? 'true' : 'false');
    }

    final user = UserModel(
      id: realUserId,
      fullName: fullName,
      email: phone,
      phone: phone,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Lưu thông tin người dùng vào SecureStorage
    await _secureStorage.write(
      AppConstants.kUserData,
      jsonEncode(user.toJson()),
    );

    return user;
  }

  @override
  Future<UserModel> signUp(
    String userName,
    String password,
    String fullname,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {'UserName': userName, 'Password': password, 'FullName': fullname},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Đăng ký thất bại');
    }

    final data = response.data['data'];
    String returnedUserName = userName;
    if (data is Map) {
      returnedUserName = data['FullName'] ?? userName;
    }

    String realUserId = returnedUserName;

    return UserModel(
      id: realUserId,
      fullName: fullname,
      email: returnedUserName,
      phone: returnedUserName,
    );
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.change_password,
      data: {'OldPassword': oldPassword, 'Password': newPassword},
    );
    if (response.data != null && response.data['success'] == false) {
      throw Exception(response.data['message'] ?? 'Đổi mật khẩu thất bại');
    }
  }
}
