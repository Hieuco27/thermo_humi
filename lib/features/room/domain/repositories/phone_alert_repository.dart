/// Abstract interface — Phone Alert Repository (domain layer)
/// Không biết gì về HTTP / Dio. Chỉ định nghĩa contract thuần túy.
library;

import 'package:dartz/dartz.dart';

abstract class PhoneAlertRepository {
  Future<Either<String, void>> sendOtp({required String phone});

  Future<Either<String, void>> verifyOtp({
    required String roomId,
    required String phone,
    required String otp,
    String? note,
  });
}
