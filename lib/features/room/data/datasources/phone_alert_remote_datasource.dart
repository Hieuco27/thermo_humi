/// Abstract interface — Phone Alert Remote DataSource
library;

abstract class PhoneAlertRemoteDataSource {
  /// Ném Exception nếu thất bại.
  Future<void> sendOtp({required String phone});

  /// Ném Exception nếu thất bại.
  Future<void> verifyOtp({
    required String roomId,
    required String phone,
    required String otp,
    String? note,
  });
}
