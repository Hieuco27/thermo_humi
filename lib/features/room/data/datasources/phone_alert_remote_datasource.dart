/// Abstract interface — Phone Alert Remote DataSource
library;

abstract class PhoneAlertRemoteDataSource {
  /// Gọi API gửi OTP đến [phone].
  /// Ném Exception nếu thất bại.
  Future<void> sendOtp({required String phone});

  /// Gọi API xác minh OTP và lưu số điện thoại vào danh sách nhận cảnh báo.
  /// Ném Exception nếu thất bại.
  Future<void> verifyOtp({
    required String roomId,
    required String phone,
    required String otp,
    String? note,
  });
}
