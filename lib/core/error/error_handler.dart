library;

import 'package:thermo_humi/core/error/exceptions.dart';
import 'package:thermo_humi/core/error/failure.dart';

Failure mapExceptionToFailure(Object exception) {
  return switch (exception) {
    UnauthorizedException() => const UnauthorizedFailure(),
    ForbiddenException() => const ForbiddenFailure(),
    NotFoundException() => const NotFoundFailure(),
    ValidationException e => ValidationFailure(
      message: e.message,
      errors: e.errors,
    ),
    ServerException e => ServerFailure(message: e.message, code: e.statusCode),
    NetworkException() => const NetworkFailure(),
    CacheException e => CacheFailure(message: e.message),
    _ => const UnexpectedFailure(),
  };
}
