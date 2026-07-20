/// BottomSheet "Thêm số điện thoại nhận cảnh báo"
/// ─ Bước 1: Nhập số điện thoại + ghi chú
/// ─ Bước 2: Nhập mã OTP 6 số (hiển thị ngay trong cùng sheet, không Navigator)
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/domain/repositories/phone_alert_repository.dart';
import 'package:thermo_humi/features/room/presentation/bloc/phone_otp/phone_otp_cubit.dart';
import 'package:thermo_humi/features/room/presentation/bloc/phone_otp/phone_otp_state.dart';

// Entry point: gọi hàm này từ bất kỳ đâu để mở sheet

Future<void> showPhoneOtpBottomSheet(
  BuildContext context, {
  required String roomId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) =>
          PhoneOtpCubit(repository: sl<PhoneAlertRepository>(), roomId: roomId),
      child: const _PhoneOtpSheet(),
    ),
  );
}

// Shell sheet — chứa AnimatedSize để chuyển 2 bước mượt

class _PhoneOtpSheet extends StatelessWidget {
  const _PhoneOtpSheet();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneOtpCubit, PhoneOtpState>(
      listenWhen: (prev, curr) => curr.isVerified && !prev.isVerified,
      listener: (context, state) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã thêm số điện thoại nhận cảnh báo'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            child: BlocBuilder<PhoneOtpCubit, PhoneOtpState>(
              builder: (context, state) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: state.step == PhoneOtpStep.enterPhone
                      ? _PhoneInputStep(state: state)
                      : _OtpVerifyStep(state: state),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneInputStep extends StatefulWidget {
  final PhoneOtpState state;
  const _PhoneInputStep({required this.state});

  @override
  State<_PhoneInputStep> createState() => _PhoneInputStepState();
}

class _PhoneInputStepState extends State<_PhoneInputStep> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _noteCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _isPhoneValid = false;

  static final _validPrefixes = RegExp(r'^(03|05|07|08|09)\d{8}$');

  @override
  void initState() {
    super.initState();
    // Giữ lại giá trị nếu user back từ bước 2
    _phoneCtrl = TextEditingController(text: widget.state.phone);
    _noteCtrl = TextEditingController(text: widget.state.note);
    _isPhoneValid = _validPrefixes.hasMatch(_phoneCtrl.text);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _isPhoneValid = _validPrefixes.hasMatch(value);
    });
    context.read<PhoneOtpCubit>().clearError();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<PhoneOtpCubit>().sendOtp(
      phone: _phoneCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 12.h),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _SheetHeader(
              title: 'Thêm số điện thoại nhận cảnh báo',
              onClose: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: 20.h),
            // SĐT
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration(label: 'Số điện thoại'),
              onChanged: _onPhoneChanged,
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'Vui lòng nhập số điện thoại';
                if (!_validPrefixes.hasMatch(v))
                  return 'Số điện thoại không hợp lệ';
                return null;
              },
            ),
            SizedBox(height: 12.h),

            // ── Ghi chú ──
            TextFormField(
              controller: _noteCtrl,
              decoration: _inputDecoration(
                label: 'Ghi chú (tuỳ chọn)',
                hint: 'VD: người thân',
              ),
              onChanged: (_) => context.read<PhoneOtpCubit>().clearError(),
            ),
            SizedBox(height: 8.h),

            // ── Lỗi API ──
            if (state.errorMessage != null) ...[
              SizedBox(height: 8.h),
              _ErrorBanner(message: state.errorMessage!),
            ],

            SizedBox(height: 20.h),

            // ── Nút submit ──
            _PrimaryButton(
              label: 'Gửi mã xác nhận',
              isLoading: state.isSendingOtp,
              isEnabled: _isPhoneValid && !state.isSendingOtp,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// BƯỚC 2 — Nhập mã OTP 6 số

class _OtpVerifyStep extends StatefulWidget {
  final PhoneOtpState state;
  const _OtpVerifyStep({required this.state});

  @override
  State<_OtpVerifyStep> createState() => _OtpVerifyStepState();
}

class _OtpVerifyStepState extends State<_OtpVerifyStep> {
  // MaterialPinField v9 quản lý controller nội bộ — không cần TextEditingController bên ngoài

  @override
  void didUpdateWidget(_OtpVerifyStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi có lỗi verify → widget sẽ rebuild, MaterialPinField tự reset nếu enabled thay đổi
    // Không cần manual clear vì Cubit emit state mới làm widget rebuild
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 4)}xxx${phone.substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<PhoneOtpCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header: padding nhỏ hơn để nút sát 2 bên ──
        Padding(
          padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 12.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
                  onPressed: state.isVerifying ? null : cubit.backToPhoneStep,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Text('Nhập mã xác nhận', style: AppTextStyles.titleMediumLogin()),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.close_rounded, size: 22.sp),
                  onPressed: state.isVerifying
                      ? null
                      : () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),

        // ── Content: padding lớn hơn cho đẹp ──
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),

              // Mô tả
              Text(
                'Vui lòng nhập mã xác nhận vừa được gửi tới số ${_maskPhone(state.phone)}',
                textAlign: TextAlign.center,
                style: AppTextStyles.body13().copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),

              // 6 ô OTP
              AbsorbPointer(
                absorbing: state.isVerifying,
                child: MaterialPinField(
                  length: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autoFocus: true,
                  enabled: !state.isVerifying,
                  theme: MaterialPinTheme(
                    cellSize: Size(50.w, 50.h),
                    shape: MaterialPinShape.outlined,
                  ),
                  onChanged: (_) => cubit.clearError(),
                  onCompleted: (otp) {
                    // Anti-spam: isVerifying check nằm trong Cubit
                    cubit.verifyOtp(otp: otp);
                  },
                ),
              ),

              // Lỗi verify
              if (state.errorMessage != null) ...[
                SizedBox(height: 4.h),
                _ErrorBanner(message: state.errorMessage!),
              ],

              SizedBox(height: 16.h),

              // Gửi lại mã / Đếm ngược
              Center(
                child: state.countdown > 0
                    ? Text(
                        'Gửi lại mã (${state.countdown}s)',
                        style: AppTextStyles.body13().copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: state.isVerifying ? null : cubit.resendOtp,
                        child: Text(
                          'Gửi lại mã',
                          style: AppTextStyles.body13().copyWith(
                            color: AppColors.gradientEnd,
                          ),
                        ),
                      ),
              ),
              if (state.isVerifying) ...[
                SizedBox(height: 12.h),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Shared widgets — private

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _SheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMediumLogin(),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gradientEnd,
          disabledBackgroundColor: AppColors.gradientEnd.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.titleMediumAppBar(color: Colors.white),
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF3B30),
            size: 16,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({required String label, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    counterText: '',
    filled: true,
    fillColor: AppColors.wardroInputBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.gradientEnd, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.wardroRedText, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.wardroRedText, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
