/// Abstract interface — Phone Alert Repository (domain layer)
/// Không biết gì về HTTP / Dio. Chỉ định nghĩa contract thuần túy.
library;

import 'package:dartz/dartz.dart';

abstract class PhoneAlertRepository {
  /// Gửi OTP đến số điện thoại để xác minh.
  /// Trả về [Right(null)] nếu gửi thành công.
  /// Trả về [Left(String)] (message lỗi) nếu thất bại.
  Future<Either<String, void>> sendOtp({required String phone});

  /// Xác minh OTP và lưu số điện thoại vào danh sách nhận cảnh báo của phòng.
  /// [roomId]   — ID phòng cần gắn số điện thoại vào.
  /// [phone]    — Số điện thoại đã nhập.
  /// [otp]      — Mã OTP 6 số người dùng nhập vào.
  /// [note]     — Ghi chú tùy chọn (tên người, chức vụ…).
  /// Trả về [Right(null)] nếu xác minh thành công.
  /// Trả về [Left(String)] (message lỗi) nếu thất bại.
  Future<Either<String, void>> verifyOtp({
    required String roomId,
    required String phone,
    required String otp,
    String? note,
  });
}
