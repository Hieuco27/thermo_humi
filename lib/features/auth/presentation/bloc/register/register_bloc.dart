import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      // Mock API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Validation
      if (event.name.isEmpty ||
          event.email.isEmpty ||
          event.phone.isEmpty ||
          event.password.isEmpty ||
          event.confirmPassword.isEmpty) {
        emit(const RegisterError('All fields are required.'));
        return;
      }

      if (event.password != event.confirmPassword) {
        emit(const RegisterError('Passwords do not match.'));
        return;
      }

      // Success
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }
}
