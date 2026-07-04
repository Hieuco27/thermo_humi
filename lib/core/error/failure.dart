/// Failure - sealed class đại diện cho mọi lỗi trong app
/// Domain layer sử dụng, không phụ thuộc vào Flutter hay Dio
library;

import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Lỗi từ server (4xx, 5xx)
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Lỗi kết nối mạng (không có internet)
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
  });
}

/// Lỗi xác thực (401 - token hết hạn, không hợp lệ)
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
    super.code = 401,
  });
}

/// Lỗi không có quyền (403)
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'Bạn không có quyền thực hiện thao tác này.',
    super.code = 403,
  });
}

/// Lỗi không tìm thấy (404)
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Không tìm thấy dữ liệu.',
    super.code = 404,
  });
}

/// Lỗi validation từ server (422)
final class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure({
    required super.message,
    this.errors = const {},
    super.code = 422,
  });

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Lỗi cache / local storage
final class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Lỗi đọc dữ liệu cục bộ.'});
}

/// Lỗi không xác định
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Đã xảy ra lỗi không mong muốn.',
  });
}
