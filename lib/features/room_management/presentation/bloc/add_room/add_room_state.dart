/// AddRoomState — trạng thái màn AddRoomScreen
library;

import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

enum AddRoomStatus { idle, submitting, success, error }

class AddRoomState extends Equatable {
  /// null = chế độ tạo phòng mới; có giá trị = chế độ chỉ thêm thiết bị
  final String? existingRoomId;

  /// true = mode flexible (điều hướng từ DeviceManagementScreen)
  final bool isFlexibleMode;

  /// Tên phòng (chỉ dùng ở chế độ forceNewRoom)
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

  // ── Flexible mode fields ──────────────────────────────────────────────────

  /// Phòng đã chọn trong picker (null = "Chưa gán phòng")
  final String? selectedRoomId;
  final String? selectedRoomName;

  /// Danh sách phòng cho RoomPickerSheet — tải lazy khi bấm mở picker lần đầu
  final List<RoomEntity> availableRooms;

  /// Loading riêng cho việc tải danh sách phòng (không dùng chung AddRoomStatus)
  final bool isLoadingRooms;

  const AddRoomState({
    this.existingRoomId,
    this.isFlexibleMode = false,
    this.roomName = '',
    this.imeiInput = '',
    this.deviceCode,
    this.deviceSource,
    this.status = AddRoomStatus.idle,
    this.errorMessage,
    this.validationError,
    this.selectedRoomId,
    this.selectedRoomName,
    this.availableRooms = const [],
    this.isLoadingRooms = false,
  });

  // ── Computed getters ──────────────────────────────────────────────────────

  /// true = chế độ tạo phòng mới (forceNewRoom)
  bool get isNewRoomMode => existingRoomId == null && !isFlexibleMode;

  /// roomId hiệu quả để gọi assignDeviceToRoom():
  ///   lockedToRoom → existingRoomId
  ///   flexible đã chọn phòng → selectedRoomId
  String? get effectiveRoomId => existingRoomId ?? selectedRoomId;

  /// true = đủ điều kiện bấm nút Kích hoạt
  bool get canActivate {
    if (status == AddRoomStatus.submitting) return false;

    if (isFlexibleMode) {
      // flexible: chỉ cần deviceCode hợp lệ — chọn phòng hay "Chưa gán" đều OK
      return deviceCode != null && deviceCode!.isNotEmpty;
    }

    if (isNewRoomMode) {
      // forceNewRoom: chỉ cần tên phòng — thiết bị là tùy chọn
      return roomName.trim().isNotEmpty;
    }

    // lockedToRoom: bắt buộc phải có deviceCode
    return deviceCode != null && deviceCode!.isNotEmpty;
  }

  /// true = đang gửi API
  bool get isSubmitting => status == AddRoomStatus.submitting;

  /// true = danh sách phòng đã được tải ít nhất 1 lần
  bool get roomsLoaded => availableRooms.isNotEmpty || !isLoadingRooms;

  AddRoomState copyWith({
    String? existingRoomId,
    bool clearExistingRoomId = false,
    bool? isFlexibleMode,
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
    String? selectedRoomId,
    bool clearSelectedRoomId = false,
    String? selectedRoomName,
    bool clearSelectedRoomName = false,
    List<RoomEntity>? availableRooms,
    bool? isLoadingRooms,
  }) {
    return AddRoomState(
      existingRoomId: clearExistingRoomId ? null : existingRoomId ?? this.existingRoomId,
      isFlexibleMode: isFlexibleMode ?? this.isFlexibleMode,
      roomName: roomName ?? this.roomName,
      imeiInput: imeiInput ?? this.imeiInput,
      deviceCode: clearDeviceCode ? null : deviceCode ?? this.deviceCode,
      deviceSource: clearDeviceSource ? null : deviceSource ?? this.deviceSource,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      validationError: clearValidationError ? null : validationError ?? this.validationError,
      selectedRoomId: clearSelectedRoomId ? null : selectedRoomId ?? this.selectedRoomId,
      selectedRoomName: clearSelectedRoomName ? null : selectedRoomName ?? this.selectedRoomName,
      availableRooms: availableRooms ?? this.availableRooms,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
    );
  }

  @override
  List<Object?> get props => [
        existingRoomId,
        isFlexibleMode,
        roomName,
        imeiInput,
        deviceCode,
        deviceSource,
        status,
        errorMessage,
        validationError,
        selectedRoomId,
        selectedRoomName,
        availableRooms,
        isLoadingRooms,
      ];
}
