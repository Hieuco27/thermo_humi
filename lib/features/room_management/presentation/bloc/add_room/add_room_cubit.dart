/// AddRoomCubit — điều phối toàn bộ logic màn AddRoomScreen
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room_management/domain/repositories/room_repository.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/add_room/add_room_state.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/utils/device_code_validator.dart';

class AddRoomCubit extends Cubit<AddRoomState> {
  final RoomRepository _repository;
  Timer? _debounceTimer;

  AddRoomCubit({
    required RoomRepository repository,
    String? existingRoomId,
    bool isFlexible = false,
  }) : _repository = repository,
       super(
         AddRoomState(
           existingRoomId: existingRoomId,
           isFlexibleMode: isFlexible,
         ),
       );

  // QR Scanned (từ camera hoặc thư viện ảnh)
  /// Hàm xử lý chung cho cả camera scan và image picker.
  /// Gọi sau khi nhận raw QR string từ mobile_scanner hoặc image_picker.
  void handleScannedCode(String rawValue) {
    final parsed = DeviceCodeValidator.parseQrPayload(rawValue);
    if (parsed != null) {
      emit(
        state.copyWith(
          deviceCode: parsed,
          deviceSource: 'qr',
          imeiInput: '',
          clearValidationError: true,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          clearDeviceCode: true,
          clearDeviceSource: true,
          validationError:
              'Mã QR không đúng định dạng thiết bị. Vui lòng thử lại.',
        ),
      );
    }
  }

  //  IMEI Input
  void updateImeiInput(String value) {
    // Reset device code ngay khi người dùng thay đổi input
    emit(
      state.copyWith(
        imeiInput: value,
        clearDeviceCode: true,
        clearDeviceSource: true,
        clearValidationError: true,
      ),
    );

    // Debounce validate 300ms
    _debounceTimer?.cancel();
    if (value.trim().isEmpty) return;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validateImeiAndUpdate(value);
    });
  }

  void _validateImeiAndUpdate(String value) {
    final clean = value.trim();

    // Nếu độ dài < 15: đang nhập, không show lỗi, không set deviceCode
    if (clean.length < 15) return;

    final error = DeviceCodeValidator.imeiError(clean);
    if (error == null) {
      // IMEI hợp lệ
      emit(
        state.copyWith(
          deviceCode: clean,
          deviceSource: 'imei',
          clearValidationError: true,
        ),
      );
    } else {
      emit(state.copyWith(clearDeviceCode: true, validationError: error));
    }
  }
}
