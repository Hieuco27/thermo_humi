import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:thermo_humi/core/error/exceptions.dart';
import 'package:dio/dio.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUseCase signInUseCase;

  LoginBloc({required this.signInUseCase}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await signInUseCase.execute(
        event.email,
        event.password,
        event.rememberMe,
      );
      emit(LoginSuccess(user));
    } on ValidationException catch (e) {
      emit(LoginError(e.message, fieldErrors: _mapValidationErrors(e.errors)));
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        emit(LoginError('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      } else if (e.error is UnauthorizedException) {
        emit(LoginError('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'));
      } else if (e.error is ServerException) {
        emit(LoginError((e.error as ServerException).message));
      } else if (e.error is ValidationException) {
        final validationException = e.error as ValidationException;
        emit(
          LoginError(
            validationException.message, 
            fieldErrors: _mapValidationErrors(validationException.errors)
          ),
        );
      } else {
        emit(LoginError('Đã xảy ra lỗi kết nối. Vui lòng thử lại.'));
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      
      if (errorMessage.toLowerCase().contains('incorrect password') || 
          errorMessage.toLowerCase().contains('mật khẩu không chính xác') ||
          errorMessage.toLowerCase().contains('sai mật khẩu')) {
        errorMessage = 'Mật khẩu không chính xác.';
      }
      
      emit(LoginError(errorMessage));
    }
  }

  Map<String, String> _mapValidationErrors(Map<String, List<String>> errors) {
    final fieldErrors = <String, String>{};
    errors.forEach((key, value) {
      if (value.isNotEmpty) {
        final errorMsg = value.first;
        final lowerKey = key.toLowerCase();
        
        if (lowerKey == 'email' ||
            lowerKey == 'phone' ||
            lowerKey == 'username' ||
            lowerKey.contains('username') ||
            lowerKey.contains('email') ||
            lowerKey.contains('phone')) {
          fieldErrors['email'] = errorMsg;
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
