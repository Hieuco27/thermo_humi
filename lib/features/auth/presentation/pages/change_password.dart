import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/auth/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:thermo_humi/features/auth/presentation/cubit/change_password/change_password_state.dart';
import 'package:thermo_humi/features/auth/presentation/widgets/common/input_field.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChangePasswordCubit>(),
      child: const ChangePasswordView(),
    );
  }
}

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Text(
    text,
    style: AppTextStyles.titleSmall2().copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _eyeIcon({required bool obscure, required VoidCallback onTap}) =>
      IconButton(
        onPressed: onTap,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textPrimary,
          size: 20.r,
        ),
      );

  void _onChangePassword() {
    FocusScope.of(context).unfocus();
    context.read<ChangePasswordCubit>().changePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
      _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.gradientEnd,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: Colors.white,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Đổi mật khẩu',
            style: AppTextStyles.titleMediumAppBar(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đổi mật khẩu thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop(); // Quay lại trang trước
            } else if (state is ChangePasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ChangePasswordLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Mật khẩu cũ'),
                  SizedBox(height: 8.h),
                  InputField(
                    controller: _oldPasswordController,
                    hint: 'Nhập mật khẩu cũ',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureOldPassword,
                    suffixIcon: _eyeIcon(
                      obscure: _obscureOldPassword,
                      onTap: () => setState(
                        () => _obscureOldPassword = !_obscureOldPassword,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _label('Mật khẩu mới'),
                  SizedBox(height: 8.h),
                  InputField(
                    controller: _newPasswordController,
                    hint: 'Nhập mật khẩu mới',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureNewPassword,
                    suffixIcon: _eyeIcon(
                      obscure: _obscureNewPassword,
                      onTap: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _label('Nhập lại mật khẩu mới'),
                  SizedBox(height: 8.h),
                  InputField(
                    controller: _confirmPasswordController,
                    hint: 'Nhập lại mật khẩu mới',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: _eyeIcon(
                      obscure: _obscureConfirmPassword,
                      onTap: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientStart,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.gradientStart
                            .withValues(alpha: 0.7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Đổi mật khẩu',
                              style: AppTextStyles.titleMediumAppBar(),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
