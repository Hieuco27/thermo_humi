import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository authRepository;

  SignInUseCase(this.authRepository);

  Future<UserEntity> execute(
    String email,
    String password,
    bool rememberMe,
  ) async {
    return await authRepository.signIn(email, password, rememberMe);
  }
}
