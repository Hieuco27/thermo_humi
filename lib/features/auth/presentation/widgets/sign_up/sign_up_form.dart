import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/register/register_event.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/register/register_state.dart';
import 'package:thermo_humi/features/auth/presentation/pages/auth_text_field.dart';
import 'package:thermo_humi/features/auth/presentation/widgets/common/primary_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
          // Navigate back to login
          context.pop();
        } else if (state is RegisterError) {
          if (state.fieldErrors == null || state.fieldErrors!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            AuthTextField(
              hintText: 'Họ và tên',
              prefixIcon: Icons.person_outline,
              controller: _nameController,
              keyboardType: TextInputType.name,
              errorText: (state is RegisterError)
                  ? (state.fieldErrors?['name'])
                  : null,
            ),
            SizedBox(height: 10.h),
            AuthTextField(
              hintText: 'Số điện thoại',
              prefixIcon: Icons.phone_outlined,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              errorText: (state is RegisterError)
                  ? (state.fieldErrors?['phone'])
                  : null,
            ),
            SizedBox(height: 10.h),
            AuthTextField(
              hintText: 'Mật khẩu',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: _passwordController,
              errorText: (state is RegisterError)
                  ? (state.fieldErrors?['password'])
                  : null,
            ),
            SizedBox(height: 10.h),
            AuthTextField(
              hintText: 'Xác nhận mật khẩu',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: _confirmPasswordController,
              errorText: (state is RegisterError)
                  ? (state.fieldErrors?['confirmPassword'])
                  : null,
            ),
            SizedBox(height: 20.h),
            PrimaryButton(
              text: 'Đăng ký',
              isLoading: state is RegisterLoading,
              backgroundColor: AppColors.gradientStart,
              onPressed: () {
                context.read<RegisterBloc>().add(
                  RegisterSubmitted(
                    name: _nameController.text,
                    phone: _phoneController.text,
                    password: _passwordController.text,
                    confirmPassword: _confirmPasswordController.text,
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
