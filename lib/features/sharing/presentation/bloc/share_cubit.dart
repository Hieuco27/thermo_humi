import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  Timer? _qrTimer;

  ShareCubit({
    required List<String> initialDeviceIds,
    String? roomId,
  }) : super(ShareState(
          selectedDeviceIds: initialDeviceIds,
          roomId: roomId,
          scope: initialDeviceIds.isNotEmpty ? ShareScope.single : ShareScope.room,
        ));

  void toggleScope(ShareScope scope) {
    if (state.scope == scope) return;
    emit(state.copyWith(scope: scope));
  }

  void toggleMethod(ShareMethod method) {
    if (state.method == method) return;
    emit(state.copyWith(method: method));
  }

  void toggleEditPermission(bool allow) {
    emit(state.copyWith(allowEdit: allow));
  }

  void updateInviteInput(String input) {
    emit(state.copyWith(inviteInput: input));
  }

  Future<void> submitShare() async {
    if (state.method == ShareMethod.emailPhone) {
      if (state.inviteInput.trim().isEmpty) {
        emit(state.copyWith(
          status: ShareStatus.failure,
          errorMessage: 'Vui lòng nhập số điện thoại hoặc email',
        ));
        emit(state.copyWith(status: ShareStatus.initial));
        return;
      }
      
      emit(state.copyWith(status: ShareStatus.loading));
      
      // Giả lập API gọi lên server để share qua email/sđt
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(status: ShareStatus.success));
    } else {
      // Logic tạo QR code
      generateQrCode();
    }
  }

  void generateQrCode() {
    _qrTimer?.cancel();
    
    emit(state.copyWith(status: ShareStatus.loading));
    
    // Giả lập API gọi lên server lấy token chia sẻ
    Future.delayed(const Duration(milliseconds: 500), () {
      final token = 'share_token_${DateTime.now().millisecondsSinceEpoch}';
      
      emit(state.copyWith(
        status: ShareStatus.success,
        qrCodeData: token,
        qrRemainingSeconds: 600, // 10 mins
      ));
      
      _startQrTimer();
    });
  }

  void _startQrTimer() {
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.qrRemainingSeconds > 0) {
        emit(state.copyWith(qrRemainingSeconds: state.qrRemainingSeconds - 1));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _qrTimer?.cancel();
    return super.close();
  }
}
