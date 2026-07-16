/// Error Interceptor — map HTTP status code → custom exception
library;

import 'dart:convert';

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

    final validationErrors = _extractValidationErrors(response);

    final exception = switch (statusCode) {
      401 => UnauthorizedException(message: message),
      403 => ForbiddenException(message: message),
      404 => NotFoundException(message: message),
      422 => ValidationException(message: message, errors: validationErrors),
      400 when validationErrors.isNotEmpty => ValidationException(
        message: message,
        errors: validationErrors,
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
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      final errorsMap = <String, List<String>>{};

      if (data is List) {
        // Handle root array of IdentityError objects: [{"code": "...", "description": "..."}]
        for (var item in data) {
          if (item is Map &&
              item['code'] != null &&
              item['description'] != null) {
            final key = item['code'].toString();
            final desc = item['description'].toString();
            errorsMap.putIfAbsent(key, () => []).add(desc);
          }
        }
      } else if (data is Map) {
        // Check if there is an "errors" field
        final errorsField = data['errors'];

        if (errorsField is Map) {
          // Standard ProblemDetails: {"errors": {"Password": ["err1", "err2"]}}
          errorsField.forEach((key, value) {
            if (value is List) {
              errorsMap[key.toString()] = value
                  .map((e) => e.toString())
                  .toList();
            } else {
              errorsMap[key.toString()] = [value.toString()];
            }
          });
        } else if (errorsField is List) {
          // Wrapper with list of objects: {"errors": [{"code": "...", "description": "..."}]}
          for (var item in errorsField) {
            if (item is Map &&
                item['code'] != null &&
                item['description'] != null) {
              final key = item['code'].toString();
              final desc = item['description'].toString();
              errorsMap.putIfAbsent(key, () => []).add(desc);
            } else if (item is Map && item.keys.length == 1) {
              // Sometimes {"Password": "Error"} in a list
              final key = item.keys.first.toString();
              final desc = item.values.first.toString();
              errorsMap.putIfAbsent(key, () => []).add(desc);
            }
          }
        }
      }
      return errorsMap;
    } catch (_) {}
    return {};
  }
}
