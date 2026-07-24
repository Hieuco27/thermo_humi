import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'package:thermo_humi/features/profile/domain/usecases/get_user_profile_usecase.dart';

part 'add_device_state.dart';

class AddDeviceCubit extends Cubit<AddDeviceState> {
  final DeviceRepository _repository;
  final GetUserProfileUseCase _getUserProfileUseCase;

  AddDeviceCubit({
    required DeviceRepository repository,
    required GetUserProfileUseCase getUserProfileUseCase,
  })  : _repository = repository,
        _getUserProfileUseCase = getUserProfileUseCase,
        super(const AddDeviceState());

  Future<void> submitDevice({
    required String imei,
    required String deviceName,
  }) async {
    if (imei.isEmpty || deviceName.isEmpty) {
      emit(state.copyWith(
        status: AddDeviceStatus.error,
        errorMessage: 'Vui lòng nhập đầy đủ IMEI và Tên thiết bị',
      ));
      return;
    }

    emit(state.copyWith(status: AddDeviceStatus.loading));

    final userId = await _getUserId();
    if (userId == null) {
      emit(state.copyWith(
        status: AddDeviceStatus.error,
        errorMessage: 'Không tìm thấy thông tin người dùng',
      ));
      return;
    }

    final result = await _repository.addDevice(
      imei: imei,
      deviceName: deviceName,
      userId: userId,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AddDeviceStatus.error,
        errorMessage: error,
      )),
      (_) => emit(state.copyWith(status: AddDeviceStatus.success)),
    );
  }

  Future<String?> _getUserId() async {
    try {
      final user = await _getUserProfileUseCase.execute();
      return user?.id;
    } catch (_) {
      return null;
    }
  }
}
