import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';
import 'package:thermo_humi/core/error/exceptions.dart';

class SignInUseCase {
  final AuthRepository authRepository;

  SignInUseCase(this.authRepository);

  Future<UserEntity> execute(
    String email,
    String password,
    bool rememberMe,
  ) async {
    final Map<String, List<String>> errors = {};
    final phoneRegex = RegExp(r'^\d{10}$');
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      errors['email'] = ['Số điện thoại không được để trống.'];
    } else if (!phoneRegex.hasMatch(trimmedEmail)) {
      errors['email'] = ['Số điện thoại phải bao gồm đúng 10 chữ số.'];
    }
    if (password.trim().isEmpty) {
      errors['password'] = ['Mật khẩu không được để trống.'];
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        message: 'Dữ liệu không hợp lệ.',
        errors: errors,
      );
    }

    return await authRepository.signIn(email, password, rememberMe);
  }
}
