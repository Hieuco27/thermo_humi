/// Error Interceptor — map HTTP status code → custom exception
library;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:thermo_humi/core/error/exceptions.dart';

@singleton
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
        ),
      );
      return;
    }

    if (response == null) {
      handler.reject(err);
      return;
    }

    final statusCode = response.statusCode ?? 0;
    final message = _extractMessage(response);

    final exception = switch (statusCode) {
      401 => UnauthorizedException(message: message),
      403 => ForbiddenException(message: message),
      404 => NotFoundException(message: message),
      422 => ValidationException(
          message: message,
          errors: _extractValidationErrors(response),
        ),
      _ => ServerException(message: message, statusCode: statusCode),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: response,
        error: exception,
      ),
    );
  }

  String _extractMessage(Response response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['title'] as String? ??
            'Đã xảy ra lỗi từ máy chủ.';
      }
    } catch (_) {}
    return 'Đã xảy ra lỗi từ máy chủ.';
  }

  Map<String, List<String>> _extractValidationErrors(Response response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic> && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        return errors.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => e.toString()).toList(),
          ),
        );
      }
    } catch (_) {}
    return {};
  }
}
