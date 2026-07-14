import 'package:dartz/dartz.dart';
import 'package:thermo_humi/core/error/failure.dart';
import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password, bool rememberMe);

  Future<UserEntity> signUp(String userName, String password, String fullname);
  Future<void> signOut();
  Future<Either<Failure, void>> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  );
}
