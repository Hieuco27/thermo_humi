import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/data/models/user_model.dart';
import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
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
  Future<UserEntity> changePassword(UserEntity user, String password) async {
    final userModel = await authDataSource.changePassword(
      UserModel(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        avatar: user.avatar,
      ),
      password,
    );
    return userModel;
  }
}
