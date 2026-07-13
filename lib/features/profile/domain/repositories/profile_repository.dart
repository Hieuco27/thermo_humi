import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity?> getUserProfile();
}
