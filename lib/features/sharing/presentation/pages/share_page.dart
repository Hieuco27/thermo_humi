import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/sharing/presentation/bloc/share_cubit.dart';
import 'package:thermo_humi/features/sharing/presentation/bloc/share_state.dart';
import 'package:thermo_humi/features/sharing/presentation/widgets/qr_share_view.dart';

class SharePage extends StatelessWidget {
  final List<String> initialDeviceIds;
  final String? roomId;

  const SharePage({super.key, required this.initialDeviceIds, this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ShareCubit(initialDeviceIds: initialDeviceIds, roomId: roomId),
      child: const _SharePageContent(),
    );
  }
}

class _SharePageContent extends StatelessWidget {
  const _SharePageContent();

  Widget _buildToggleTab(
    BuildContext context, {
    required String title,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD6E4FF) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
                width: 24.w,
                height: 24.w,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: AppTextStyles.titleSmall().copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShareCubit, ShareState>(
      listener: (context, state) {
        if (state.status == ShareStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (state.status == ShareStatus.success &&
            state.method == ShareMethod.emailPhone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi lời mời thành công!')),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.gradientEnd,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              state.method == ShareMethod.qrCode && state.qrCodeData != null
                  ? 'Chia sẻ qua mã QR'
                  : 'Chia sẻ thiết bị',
              style: AppTextStyles.titleMediumAppBar(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.method == ShareMethod.qrCode &&
                    state.qrCodeData != null) ...[
                  QrShareView(
                    qrData: state.qrCodeData!,
                    remainingSeconds: state.qrRemainingSeconds,
                    onRefresh: () =>
                        context.read<ShareCubit>().generateQrCode(),
                  ),
                ] else ...[
                  // Normal Form View
                  Text(
                    'Phạm vi chia sẻ',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.backgroundColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildToggleTab(
                        context,
                        title: 'Thiết bị',
                        iconPath: 'assets/icons/room/device.svg',
                        isSelected: state.scope == ShareScope.single,
                        onTap: () => context.read<ShareCubit>().toggleScope(
                          ShareScope.single,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _buildToggleTab(
                        context,
                        title: 'Cả phòng',
                        iconPath: 'assets/icons/room/room.svg',
                        isSelected: state.scope == ShareScope.room,
                        onTap: () => context.read<ShareCubit>().toggleScope(
                          ShareScope.room,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  if (state.scope == ShareScope.single) ...[
                    Text(
                      'Thiết bị đã chọn',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.backgroundColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: state.selectedDeviceIds.map((id) {
                        // TODO: Thay thế id bằng tên thiết bị thật nếu bạn có Data
                        final mockName =
                            'Thiết bị ${id.length > 4 ? id.substring(0, 4) : id}';
                        return Chip(
                          label: Text(mockName),
                          labelStyle: AppTextStyles.label13(
                            color: AppColors.primary,
                          ),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          deleteIcon: Icon(
                            Icons.close_rounded,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          onDeleted: () {
                            // TODO: Handle logic xóa thiết bị khỏi list chọn
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Share Method
                  Text(
                    'Phương thức mời',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.backgroundColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildToggleTab(
                        context,
                        title: 'SĐT/email',
                        iconPath: 'assets/icons/room/phone.svg',
                        isSelected: state.method == ShareMethod.emailPhone,
                        onTap: () => context.read<ShareCubit>().toggleMethod(
                          ShareMethod.emailPhone,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _buildToggleTab(
                        context,
                        title: 'Mã QR',
                        iconPath: 'assets/icons/home/qr.svg',
                        isSelected: state.method == ShareMethod.qrCode,
                        onTap: () => context.read<ShareCubit>().toggleMethod(
                          ShareMethod.qrCode,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  if (state.method == ShareMethod.emailPhone) ...[
                    Text(
                      'Số điện thoại hoặc email',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.backgroundColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      onChanged: (val) =>
                          context.read<ShareCubit>().updateInviteInput(val),
                      decoration: InputDecoration(
                        hintText: 'Nhập SĐT hoặc email người nhận',
                        hintStyle: AppTextStyles.bodyMedium(
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == ShareStatus.loading
                          ? null
                          : () => context.read<ShareCubit>().submitShare(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: state.status == ShareStatus.loading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              state.method == ShareMethod.emailPhone
                                  ? 'Gửi lời mời'
                                  : 'Tạo mã QR',
                              style: AppTextStyles.titleMedium(
                                color: Colors.white,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
