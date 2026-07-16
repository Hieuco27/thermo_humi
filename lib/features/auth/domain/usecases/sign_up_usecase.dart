import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';
import 'package:thermo_humi/core/error/exceptions.dart';

class SignUpUseCase {
  final AuthRepository authRepository;

  SignUpUseCase(this.authRepository);

  Future<UserEntity> execute(
    String userName,
    String password,
    String fullname,
  ) async {
    final Map<String, List<String>> errors = {};
    final phoneRegex = RegExp(r'^\d{10}$');
    final trimmedPhone = userName.trim();
    if (trimmedPhone.isEmpty) {
      errors['phone'] = ['Số điện thoại không được để trống.'];
    } else if (!phoneRegex.hasMatch(trimmedPhone)) {
      errors['phone'] = ['Số điện thoại phải bao gồm đúng 10 chữ số.'];
    }
    if (password.trim().isEmpty) {
      errors['password'] = ['Mật khẩu không được để trống.'];
    } else if (password.length < 6) {
      errors['password'] = ['Mật khẩu phải có ít nhất 6 ký tự.'];
    }
    if (fullname.trim().isEmpty) {
      errors['name'] = ['Họ và tên không được để trống.'];
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        message: 'Dữ liệu không hợp lệ.',
        errors: errors,
      );
    }

    return await authRepository.signUp(userName, password, fullname);
  }
}
