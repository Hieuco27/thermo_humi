import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/login/login_event.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/login/login_state.dart';
import 'package:thermo_humi/features/auth/presentation/pages/auth_text_field.dart';
import 'package:thermo_humi/features/auth/presentation/widgets/common/primary_button.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.go('/home');
        } else if (state is LoginError) {
          if (state.fieldErrors == null || state.fieldErrors!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Column(
          children: [
        AuthTextField(
          hintText: 'Gmail hoặc Số điện thoại',
          prefixIcon: Icons.person_outline,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: (state is LoginError) ? (state.fieldErrors?['email']) : null,
        ),
        SizedBox(height: 16.h),
        AuthTextField(
          hintText: 'Mật khẩu',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          controller: _passwordController,
          errorText: (state is LoginError) ? (state.fieldErrors?['password']) : null,
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    side: const BorderSide(color: Colors.grey),
                    activeColor: const Color(0xFF3498DB),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Duy trì đăng nhập',
                  style: AppTextStyles.titleSmall2().copyWith(
                    color: AppColors.textFieldHint,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Quên mật khẩu?',
                style: AppTextStyles.titleSmall2().copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
        SizedBox(height: 32.h),
        PrimaryButton(
              text: 'Đăng nhập',
              isLoading: state is LoginLoading,
              backgroundColor: AppColors.gradientStart,
              onPressed: () {
                context.read<LoginBloc>().add(
                  LoginSubmitted(
                    email: _emailController.text,
                    password: _passwordController.text,
                    rememberMe: _rememberMe,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
