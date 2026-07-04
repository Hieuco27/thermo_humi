/// Custom exceptions - tầng Data ném ra, tầng Domain không biết đến
library;

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({this.message = 'Unauthorized'});
}

class ForbiddenException implements Exception {
  final String message;

  const ForbiddenException({this.message = 'Forbidden'});
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({this.message = 'Not Found'});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  const ValidationException({required this.message, this.errors = const {}});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error'});
}
