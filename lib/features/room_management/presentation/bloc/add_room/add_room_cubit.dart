/// AddRoomCubit — điều phối toàn bộ logic màn AddRoomScreen
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room_management/domain/entities/add_room_result.dart';
import 'package:thermo_humi/features/room_management/domain/repositories/room_repository.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/add_room/add_room_state.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/utils/device_code_validator.dart';

class AddRoomCubit extends Cubit<AddRoomState> {
  final RoomRepository _repository;
  Timer? _debounceTimer;

  AddRoomCubit({required RoomRepository repository, String? existingRoomId})
    : _repository = repository,
      super(AddRoomState(existingRoomId: existingRoomId));

  // ── Room Name ──────────────────────────────────────────────────────────────
  void updateRoomName(String value) {
    emit(state.copyWith(roomName: value, clearErrorMessage: true));
  }

  // ── QR Scanned (từ camera hoặc thư viện ảnh) ───────────────────────────────
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

  // ── Activate ───────────────────────────────────────────────────────────────
  /// Gọi khi bấm nút "Kích hoạt". Trả về AddRoomResult để View dùng Navigator.pop().
  Future<AddRoomResult?> activate() async {
    if (!state.canActivate) return null;

    emit(
      state.copyWith(status: AddRoomStatus.submitting, clearErrorMessage: true),
    );

    try {
      if (state.isNewRoomMode) {
        return await _createRoomWithDevice();
      } else {
        return await _assignDeviceToRoom();
      }
    } catch (e) {
      final message = _parseErrorMessage(e);
      emit(state.copyWith(status: AddRoomStatus.error, errorMessage: message));
      return null;
    }
  }

  Future<AddRoomResult> _createRoomWithDevice() async {
    final roomId = await _repository.createRoomWithDevice(
      roomName: state.roomName.trim(),
      deviceCode: state.deviceCode!,
    );

    emit(state.copyWith(status: AddRoomStatus.success));

    return AddRoomResult(
      roomId: roomId,
      roomName: state.roomName.trim(),
      deviceCode: state.deviceCode!,
      isNewRoom: true,
    );
  }

  Future<AddRoomResult> _assignDeviceToRoom() async {
    await _repository.assignDeviceToRoom(
      roomId: state.existingRoomId!,
      deviceCode: state.deviceCode!,
    );

    emit(state.copyWith(status: AddRoomStatus.success));

    return AddRoomResult(
      roomId: state.existingRoomId!,
      roomName: '', // Màn trước đã biết tên phòng
      deviceCode: state.deviceCode!,
      isNewRoom: false,
    );
  }

  // ── Error Parsing ──────────────────────────────────────────────────────────
  String _parseErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('đã được gán'))
      return 'Thiết bị đã được gán cho phòng khác.';
    if (msg.contains('không tồn tại'))
      return 'Mã thiết bị không tồn tại trong hệ thống.';
    if (msg.contains('timeout')) return 'Hết thời gian chờ. Vui lòng thử lại.';
    // Fallback cụ thể hơn "Có lỗi xảy ra"
    return 'Kích hoạt thất bại. Vui lòng kiểm tra lại mã thiết bị và thử lại.';
  }

  // ── Clear ──────────────────────────────────────────────────────────────────
  void clearError() {
    emit(state.copyWith(clearErrorMessage: true, status: AddRoomStatus.idle));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
