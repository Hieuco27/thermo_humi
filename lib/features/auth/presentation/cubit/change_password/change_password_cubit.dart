import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/auth/domain/usecases/change_pasword_usecase.dart';
import 'package:thermo_humi/features/auth/presentation/cubit/change_password/change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordCubit({required this.changePasswordUseCase})
      : super(ChangePasswordInitial());

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) {
      emit(const ChangePasswordFailure('Mật khẩu xác nhận không khớp.'));
      return;
    }
    if (newPassword.length < 6) {
      emit(const ChangePasswordFailure('Mật khẩu mới phải có ít nhất 6 ký tự.'));
      return;
    }
    emit(ChangePasswordLoading());
    final result = await changePasswordUseCase.execute(
      oldPassword,
      newPassword,
      confirmPassword,
    );
    result.fold(
      (failure) => emit(ChangePasswordFailure(failure.message)),
      (_) => emit(ChangePasswordSuccess()),
    );
  }
}
