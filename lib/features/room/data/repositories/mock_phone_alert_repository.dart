/// Mock Implementation — Phone Alert Repository
/// Dùng để phát triển và test giao diện khi chưa có BE thật.
/// Khi BE hoàn thiện, chỉ cần thay thế bằng [PhoneAlertRepositoryImpl] trong injection_container.dart.
library;

import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/room/domain/repositories/phone_alert_repository.dart';

class MockPhoneAlertRepository implements PhoneAlertRepository {
  /// Giả lập gửi OTP thành công sau 1.5 giây
  @override
  Future<Either<String, void>> sendOtp({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    return const Right(null);
  }

  @override
  Future<Either<String, void>> verifyOtp({
    required String roomId,
    required String phone,
    required String otp,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    if (otp == '123456') {
      return const Right(null);
    }

    // ── Giả lập lỗi mã sai ──
    return const Left('Mã xác nhận không đúng. Vui lòng thử lại.');
  }
}
