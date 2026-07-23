import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';

part 'add_device_state.dart';

class AddDeviceCubit extends Cubit<AddDeviceState> {
  final DeviceRepository _repository;

  AddDeviceCubit({required DeviceRepository repository})
      : _repository = repository,
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
      final storage = sl<SecureStorage>();
      final userDataStr = await storage.read(AppConstants.kUserData);
      if (userDataStr != null) {
        final Map<String, dynamic> userJson = jsonDecode(userDataStr);
        return userJson['id']?.toString();
      }
    } catch (_) {}
    return null;
  }
}
