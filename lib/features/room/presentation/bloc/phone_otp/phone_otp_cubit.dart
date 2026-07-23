import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room/domain/repositories/phone_alert_repository.dart';
import 'phone_otp_state.dart';

class PhoneOtpCubit extends Cubit<PhoneOtpState> {
  final PhoneAlertRepository _repository;
  final String roomId;

  Timer? _countdownTimer;

  PhoneOtpCubit({
    required PhoneAlertRepository repository,
    required this.roomId,
  }) : _repository = repository,
       super(const PhoneOtpState());

  // BƯỚC 1: Gửi OTP
  // Chỉ nơi DUY NHẤT chuyển step → enterOtp

  Future<void> sendOtp({required String phone, required String note}) async {
    if (state.isSendingOtp) return;

    emit(
      state.copyWith(
        status: PhoneOtpStatus.sendingOtp,
        phone: phone,
        note: note,
        clearError: true,
      ),
    );

    final result = await _repository.sendOtp(phone: phone);

    result.fold(
      (error) {
        // Thất bại: giữ nguyên bước 1, hiện lỗi
        emit(state.copyWith(status: PhoneOtpStatus.error, errorMessage: error));
      },
      (_) {
        // Thành công: chuyển sang bước 2, bắt đầu đếm ngược
        emit(
          state.copyWith(
            status: PhoneOtpStatus.idle,
            step: PhoneOtpStep.enterOtp,
            countdown: 60,
            clearError: true,
          ),
        );
        _startCountdown();
      },
    );
  }

  // BƯỚC 2: Xác minh OTP
  // Anti-spam: check verifying trước khi thực thi

  Future<void> verifyOtp({required String otp}) async {
    // Khoá: nếu đang verify thì bỏ qua (tránh gọi trùng khi paste OTP)
    if (state.isVerifying) return;

    emit(state.copyWith(status: PhoneOtpStatus.verifying, clearError: true));

    final result = await _repository.verifyOtp(
      roomId: roomId,
      phone: state.phone,
      otp: otp,
      note: state.note.isNotEmpty ? state.note : null,
    );

    result.fold(
      (error) {
        // Thất bại: xóa OTP, focus lại ô đầu, hiện lỗi — KHÔNG quay về bước 1
        emit(state.copyWith(status: PhoneOtpStatus.error, errorMessage: error));
      },
      (_) {
        // Thành công: phát signal verified để UI đóng sheet
        _cancelCountdown();
        emit(state.copyWith(status: PhoneOtpStatus.verified, clearError: true));
      },
    );
  }

  // Quay về bước 1 (giữ nguyên SĐT & ghi chú)

  void backToPhoneStep() {
    _cancelCountdown();
    emit(
      state.copyWith(
        step: PhoneOtpStep.enterPhone,
        status: PhoneOtpStatus.idle,
        clearError: true,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Gửi lại mã (reset countdown, gọi lại API)
  // ─────────────────────────────────────────────────────────────

  Future<void> resendOtp() async {
    if (!state.canResend) return;
    _cancelCountdown();
    emit(state.copyWith(countdown: 60, clearError: true));
    await sendOtp(phone: state.phone, note: state.note);
    // Sau khi gửi lại thành công, sendOtp sẽ gọi _startCountdown()
    // nhưng step không thay đổi (vẫn ở enterOtp)
  }

  // ─────────────────────────────────────────────────────────────
  // Xóa lỗi khi người dùng bắt đầu nhập lại
  // ─────────────────────────────────────────────────────────────

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true, status: PhoneOtpStatus.idle));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Timer helpers — private
  // ─────────────────────────────────────────────────────────────

  void _startCountdown() {
    _cancelCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.countdown - 1;
      if (next <= 0) {
        _cancelCountdown();
        emit(state.copyWith(countdown: 0));
      } else {
        emit(state.copyWith(countdown: next));
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // ─────────────────────────────────────────────────────────────
  // Đảm bảo timer được huỷ khi sheet bị đóng (tránh memory leak)
  // ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _cancelCountdown();
    return super.close();
  }
}
