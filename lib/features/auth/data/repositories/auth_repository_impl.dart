import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/data/models/user_model.dart';
import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<UserEntity> signIn(String email, String password) async {
    // Repository gọi Data Source để lấy UserModel
    final userModel = await authDataSource.signIn(email, password);
    // Vì UserModel kế thừa từ UserEntity, ta có thể trả về trực tiếp
    return userModel;
  }

  @override
  Future<UserEntity> signUp(String email, String password) async {
    final userModel = await authDataSource.signUp(email, password);
    return userModel;
  }

  @override
  Future<void> signOut() async {
    await authDataSource.signOut();
  }

  @override
  Future<UserEntity> changePassword(UserEntity user, String password) async {
    // Trong thực tế có thể cần ép kiểu hoặc chuyển đổi từ Entity sang Model
    // nếu Data Source yêu cầu UserModel
    final userModel = await authDataSource.changePassword(
      UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        avatar: user.avatar,
      ),
      password,
    );
    return userModel;
  }
}
