import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository authRepository;

  SignUpUseCase(this.authRepository);

  Future<UserEntity> execute(
    String userName,
    String password,
    String fullname,
  ) async {
    return await authRepository.signUp(userName, password, fullname);
  }
}
