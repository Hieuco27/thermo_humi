import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/access_request_detail_cubit.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/access_request_state.dart';
import 'package:thermo_humi/features/request_access/presentation/widgets/role_selector.dart';
import 'package:thermo_humi/features/request_access/presentation/widgets/status_chip.dart';

class AccessRequestDetailScreen extends StatelessWidget {
  final String id;
  final AccessRequestType type;

  const AccessRequestDetailScreen({
    super.key,
    required this.id,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccessRequestDetailCubit>()..fetchDetail(id, type),
      child: const _DetailContent(),
    );
  }
}

class _DetailContent extends StatefulWidget {
  const _DetailContent();

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  AccessRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccessRequestDetailCubit, AccessRequestDetailState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == AccessRequestDetailStatus.initial ||
            (state.status == AccessRequestDetailStatus.loading &&
                state.request == null)) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == AccessRequestDetailStatus.notFound) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                'Chi tiết yêu cầu',
                style: AppTextStyles.titleMedium(color: Colors.black),
              ),
            ),
            body: const Center(child: Text('Không tìm thấy yêu cầu')),
          );
        }

        final request = state.request!;
        _selectedRole ??= request.roleRequested;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.gradientEnd,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 22.sp,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Chấp nhận yêu cầu',
              style: AppTextStyles.titleMediumAppBar(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: [
                      // Section 1: Thông tin người yêu cầu
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Thông tin người yêu cầu :',
                          style: AppTextStyles.bodyMedium(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30.w,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.requesterName,
                                    style: AppTextStyles.titleMediumBlack(),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Text(
                                        'Số điện thoại:  ',
                                        style: AppTextStyles.bodyMedium(
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        request.requesterPhone ?? '-',
                                        style: AppTextStyles.bodyMedium(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Text(
                                        'Thời gian:  ',
                                        style: AppTextStyles.bodyMedium(
                                          color: Colors.black,
                                        ),
                                      ),

                                      Text(
                                        '12:08  27-02-2026',
                                        style: AppTextStyles.bodyMedium(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Section 2: Thiết bị yêu cầu
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Thiết bị yêu cầu :',
                          style: AppTextStyles.bodyMedium(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Device Image
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                request.type == AccessRequestType.room
                                    ? Icons.door_front_door
                                    : Icons.ad_units,
                                color: Colors.grey.shade500,
                                size: 30.w,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.resourceName,
                                    style: AppTextStyles.titleMediumBlack(),
                                  ),
                                  SizedBox(height: 8.h),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Quyền hạn:  ',
                                      style: AppTextStyles.body13(
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              request.roleRequested.displayName,
                                          style: AppTextStyles.bodyMedium(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (request.macAddress != null) ...[
                                    SizedBox(height: 8.h),
                                    Text(
                                      request.macAddress!,
                                      style: AppTextStyles.bodyMedium(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF98F59B,
                      ), // Light green matching the image
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                    child: Text(
                      'Đã được xác nhận',
                      style: AppTextStyles.titleMedium(
                        color: const Color(0xFF7CB37C),
                      ).copyWith(fontSize: 16.sp), // Grayish green text
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
