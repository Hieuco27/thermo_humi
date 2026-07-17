/// Auth Interceptor — đính kèm Bearer token vào mọi request
library;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';

@singleton
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  bool _isRefreshing = false;
  final Dio _dioForRefresh = Dio(
    BaseOptions(
      baseUrl: 'http://103.249.158.28:8999',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(AppConstants.kAccessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.read(
        AppConstants.kRefreshToken,
      );

      if (refreshToken != null && refreshToken.isNotEmpty) {
        if (!_isRefreshing) {
          _isRefreshing = true;
          try {
            final response = await _dioForRefresh.post(
              '/auth/refresh-token',
              data: {'RefreshToken': refreshToken},
            );

            final data = response.data['data'];
            String newAccessToken = '';
            String newRefreshToken = '';

            if (data is Map) {
              newAccessToken = data['accessToken'] ?? '';
              newRefreshToken = data['refreshToken'] ?? '';
            } else if (data is String) {
              newAccessToken = data;
            }

            if (newAccessToken.isNotEmpty) {
              await _secureStorage.write(
                AppConstants.kAccessToken,
                newAccessToken,
              );
              if (newRefreshToken.isNotEmpty) {
                await _secureStorage.write(
                  AppConstants.kRefreshToken,
                  newRefreshToken,
                );
              }

              // Gọi lại request ban đầu với token mới
              err.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await _dioForRefresh.request(
                err.requestOptions.path,
                options: Options(
                  method: err.requestOptions.method,
                  headers: err.requestOptions.headers,
                ),
                data: err.requestOptions.data,
                queryParameters: err.requestOptions.queryParameters,
              );
              _isRefreshing = false;
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            // Refresh thất bại (có thể do refresh token hết hạn)
            await _secureStorage.delete(AppConstants.kAccessToken);
            await _secureStorage.delete(AppConstants.kRefreshToken);
          } finally {
            _isRefreshing = false;
          }
        } else {
          // Hiện tại nếu có nhiều request cùng lỗi 401 thì request sau sẽ văng lỗi luôn.
        }
      } else {
        // Không có refresh token (ví dụ do không tick Duy trì đăng nhập)
        await _secureStorage.delete(AppConstants.kAccessToken);
      }
    }
    handler.next(err);
  }
}
