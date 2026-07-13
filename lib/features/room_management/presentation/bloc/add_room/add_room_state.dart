/// AddRoomState — trạng thái màn AddRoomScreen
library;

import 'package:equatable/equatable.dart';

enum AddRoomStatus { idle, submitting, success, error }

class AddRoomState extends Equatable {
  /// null = chế độ tạo phòng mới; có giá trị = chế độ chỉ thêm thiết bị
  final String? existingRoomId;

  /// Tên phòng (chỉ dùng ở chế độ tạo mới)
  final String roomName;

  /// Raw text đang nhập trong ô IMEI
  final String imeiInput;

  /// Mã thiết bị đã được nhận diện (từ QR hoặc IMEI hợp lệ)
  final String? deviceCode;

  /// Nguồn nhận diện: 'qr' | 'imei' | null
  final String? deviceSource;

  final AddRoomStatus status;

  /// Lỗi từ API (hiển thị sau khi bấm Kích hoạt)
  final String? errorMessage;

  /// Lỗi validate realtime (QR sai định dạng, IMEI sai)
  final String? validationError;

  const AddRoomState({
    this.existingRoomId,
    this.roomName = '',
    this.imeiInput = '',
    this.deviceCode,
    this.deviceSource,
    this.status = AddRoomStatus.idle,
    this.errorMessage,
    this.validationError,
  });

  // ── Computed getters ──────────────────────────────────────────────────────

  /// true = chế độ tạo phòng mới
  bool get isNewRoomMode => existingRoomId == null;

  /// true = đủ điều kiện bấm nút Kích hoạt
  bool get canActivate {
    if (status == AddRoomStatus.submitting) return false;
    if (deviceCode == null || deviceCode!.isEmpty) return false;
    if (isNewRoomMode) return roomName.trim().isNotEmpty;
    return true;
  }

  /// true = đang gửi API
  bool get isSubmitting => status == AddRoomStatus.submitting;

  AddRoomState copyWith({
    String? existingRoomId,
    bool clearExistingRoomId = false,
    String? roomName,
    String? imeiInput,
    String? deviceCode,
    bool clearDeviceCode = false,
    String? deviceSource,
    bool clearDeviceSource = false,
    AddRoomStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? validationError,
    bool clearValidationError = false,
  }) {
    return AddRoomState(
      existingRoomId: clearExistingRoomId ? null : existingRoomId ?? this.existingRoomId,
      roomName: roomName ?? this.roomName,
      imeiInput: imeiInput ?? this.imeiInput,
      deviceCode: clearDeviceCode ? null : deviceCode ?? this.deviceCode,
      deviceSource: clearDeviceSource ? null : deviceSource ?? this.deviceSource,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      validationError: clearValidationError ? null : validationError ?? this.validationError,
    );
  }

  @override
  List<Object?> get props => [
        existingRoomId,
        roomName,
        imeiInput,
        deviceCode,
        deviceSource,
        status,
        errorMessage,
        validationError,
      ];
}
