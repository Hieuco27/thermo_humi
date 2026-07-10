import 'package:dio/dio.dart';
import 'package:thermo_humi/core/config/app_config.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/network/interceptors/auth_interceptor.dart';
import 'package:thermo_humi/core/network/interceptors/error_interceptor.dart';

class DioClient {
  static Dio createDio(
    AuthInterceptor authInterceptor,
    ErrorInterceptor errorInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      authInterceptor,
      errorInterceptor,
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
      ),
    ]);

    return dio;
  }
}
