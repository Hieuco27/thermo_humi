import 'package:equatable/equatable.dart';

/// Phân biệt 2 bước hiển thị trong sheet
enum PhoneOtpStep { enterPhone, enterOtp }

/// Trạng thái loading/error từng bước
enum PhoneOtpStatus {
  idle,
  sendingOtp,   // Đang gọi API gửi OTP (bước 1)
  verifying,    // Đang gọi API xác minh OTP (bước 2)
  verified,     // Xác minh thành công → đóng sheet
  error,        // Có lỗi ở bất kỳ bước nào
}

class PhoneOtpState extends Equatable {
  /// Bước hiện tại (nhập SĐT hoặc nhập OTP)
  final PhoneOtpStep step;

  /// Trạng thái của action đang thực hiện
  final PhoneOtpStatus status;

  /// Đếm ngược (giây) cho nút "Gửi lại mã"
  final int countdown;

  /// Thông báo lỗi (nếu có), hiển thị trực tiếp trong sheet
  final String? errorMessage;

  /// Số điện thoại đã nhập ở bước 1 (giữ nguyên khi back về)
  final String phone;

  /// Ghi chú tùy chọn (giữ nguyên khi back về bước 1)
  final String note;

  const PhoneOtpState({
    this.step = PhoneOtpStep.enterPhone,
    this.status = PhoneOtpStatus.idle,
    this.countdown = 60,
    this.errorMessage,
    this.phone = '',
    this.note = '',
  });

  PhoneOtpState copyWith({
    PhoneOtpStep? step,
    PhoneOtpStatus? status,
    int? countdown,
    String? errorMessage,
    bool clearError = false,
    String? phone,
    String? note,
  }) {
    return PhoneOtpState(
      step: step ?? this.step,
      status: status ?? this.status,
      countdown: countdown ?? this.countdown,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      phone: phone ?? this.phone,
      note: note ?? this.note,
    );
  }

  bool get isSendingOtp => status == PhoneOtpStatus.sendingOtp;
  bool get isVerifying => status == PhoneOtpStatus.verifying;
  bool get isVerified => status == PhoneOtpStatus.verified;
  bool get canResend => countdown == 0 && status == PhoneOtpStatus.idle;

  @override
  List<Object?> get props => [
        step,
        status,
        countdown,
        errorMessage,
        phone,
        note,
      ];
}
