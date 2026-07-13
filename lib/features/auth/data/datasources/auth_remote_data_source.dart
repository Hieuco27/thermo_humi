import 'package:thermo_humi/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password, bool rememberMe);
  Future<UserModel> signUp(String userName, String password, String fullname);
  Future<void> signOut();
  Future<UserModel> changePassword(UserModel user, String password);
}
