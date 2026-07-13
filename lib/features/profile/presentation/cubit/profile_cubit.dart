import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/auth/data/models/user_model.dart';
import 'package:thermo_humi/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:thermo_humi/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;

  ProfileCubit(this._getUserProfileUseCase) : super(ProfileInitial());

  Future<void> loadUser() async {
    emit(ProfileLoading());
    try {
      final user = await _getUserProfileUseCase.execute();
      if (user != null) {
        emit(ProfileLoaded(user as UserModel));
      } else {
        emit(const ProfileError('Không tìm thấy thông tin người dùng'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void clearUser() {
    emit(ProfileInitial());
  }
}
