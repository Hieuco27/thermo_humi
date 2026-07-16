import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:thermo_humi/core/error/exceptions.dart';
import 'package:dio/dio.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SignUpUseCase signUpUseCase;

  RegisterBloc({required this.signUpUseCase}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      if (event.password != event.confirmPassword) {
        emit(
          const RegisterError(
            'Dữ liệu không hợp lệ.',
            fieldErrors: {'confirmPassword': 'Mật khẩu không khớp.'},
          ),
        );
        return;
      }

      // API Call
      await signUpUseCase.execute(event.phone, event.password, event.name);

      // Success
      emit(RegisterSuccess());
    } on ValidationException catch (e) {
      emit(
        RegisterError(e.message, fieldErrors: _mapValidationErrors(e.errors)),
      );
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        emit(
          const RegisterError('Không có kết nối mạng. Vui lòng kiểm tra lại.'),
        );
      } else if (e.error is UnauthorizedException) {
        emit(
          const RegisterError(
            'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
          ),
        );
      } else if (e.error is ServerException) {
        emit(RegisterError((e.error as ServerException).message));
      } else if (e.error is ValidationException) {
        final validationException = e.error as ValidationException;
        emit(
          RegisterError(
            validationException.message,
            fieldErrors: _mapValidationErrors(validationException.errors),
          ),
        );
      } else {
        emit(const RegisterError('Đã xảy ra lỗi kết nối. Vui lòng thử lại.'));
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      emit(RegisterError(errorMessage));
    }
  }

  Map<String, String> _mapValidationErrors(Map<String, List<String>> errors) {
    final fieldErrors = <String, String>{};
    errors.forEach((key, value) {
      if (value.isNotEmpty) {
        final errorMsg = value.first;
        final lowerKey = key.toLowerCase();
        if (lowerKey == 'userme' ||
            lowerKey == 'phone' ||
            lowerKey.contains('username') ||
            lowerKey.contains('phone')) {
          fieldErrors['phone'] = errorMsg;
        } else if (lowerKey == 'fullname' || lowerKey == 'name') {
          fieldErrors['name'] = errorMsg;
        } else if (lowerKey == 'password' || lowerKey.contains('password')) {
          fieldErrors['password'] = errorMsg;
        } else {
          final camelKey = key.isNotEmpty
              ? key[0].toLowerCase() + key.substring(1)
              : key;
          fieldErrors[camelKey] = errorMsg;
        }
      }
    });
    return fieldErrors;
  }
}
