import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:thermo_humi/core/error/failure.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<UserEntity> signIn(
    String email,
    String password,
    bool rememberMe,
  ) async {
    final userModel = await authDataSource.signIn(email, password, rememberMe);
    return userModel;
  }

  @override
  Future<UserEntity> signUp(
    String userName,
    String password,
    String fullname,
  ) async {
    final userModel = await authDataSource.signUp(userName, password, fullname);
    return userModel;
  }

  @override
  Future<void> signOut() async {
    await authDataSource.signOut();
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await authDataSource.changePassword(
        oldPassword,
        newPassword,
        confirmPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
