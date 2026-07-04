import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> signIn(String email, String password) async {
    // Giả lập delay mạng 1 giây
    await Future.delayed(const Duration(seconds: 1));

    // Giả lập trả về user thành công
    return UserModel(
      id: '1',
      name: 'HMS User',
      email: email,
      phone: '0123456789',
      avatar: null,
      accessToken: 'dummy_access_token',
      refreshToken: 'dummy_refresh_token',
    );
  }

  @override
  Future<UserModel> signUp(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> changePassword(UserModel user, String password) {
    throw UnimplementedError();
  }
}
