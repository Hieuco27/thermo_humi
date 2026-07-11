import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/auth/domain/usecases/sign_up_usecase.dart';
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
      // Validation
      if (event.name.isEmpty ||
          event.phone.isEmpty ||
          event.password.isEmpty ||
          event.confirmPassword.isEmpty) {
        emit(const RegisterError('Vui lòng nhập đầy đủ thông tin.'));
        return;
      }

      if (event.password != event.confirmPassword) {
        emit(const RegisterError('Mật khẩu không khớp.'));
        return;
      }

      // API Call
      await signUpUseCase.execute(event.phone, event.password, event.name);

      // Success
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }
}
