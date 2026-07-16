import 'package:dartz/dartz.dart';
import 'package:thermo_humi/core/error/failure.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase({required this.repository});

  Future<Either<Failure, void>> execute(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) => repository.changePassword(oldPassword, newPassword, confirmPassword);
}
