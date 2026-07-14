import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/features/profile/presentation/widgets/profile_avatar_section.dart';
import 'package:thermo_humi/features/profile/presentation/widgets/profile_logout_button.dart';
import 'package:thermo_humi/features/profile/presentation/widgets/profile_menu_list.dart';
import 'package:thermo_humi/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:thermo_humi/features/profile/presentation/cubit/profile_state.dart';
import 'package:thermo_humi/features/profile/presentation/widgets/profile_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const ProfileAppBar(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoaded) {
                          return ProfileAvatarSection(user: state.user);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    SizedBox(height: 20.h),
                    const ProfileMenuList(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: const ProfileLogoutButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
