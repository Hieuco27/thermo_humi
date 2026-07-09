import 'package:flutter/material.dart';
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
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state.status == AccessRequestDetailStatus.initial ||
            (state.status == AccessRequestDetailStatus.loading && state.request == null)) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.gradientEnd,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == AccessRequestDetailStatus.notFound) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết yêu cầu')),
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
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Text(
              'Chi tiết yêu cầu',
              style: AppTextStyles.titleMedium(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Large
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      request.requesterInitials,
                      style: AppTextStyles.headlineMedium().copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  request.formattedRequesterName,
                  style: AppTextStyles.titleLarge(color: AppColors.textPrimary),
                ),
                if (request.requesterPhone != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    request.requesterPhone!,
                    style: AppTextStyles.bodyMedium(color: Colors.grey.shade600),
                  ),
                ],
                SizedBox(height: 24.h),
                
                // Info Box
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Loại truy cập', request.type == AccessRequestType.device ? 'Thiết bị' : 'Phòng'),
                      SizedBox(height: 12.h),
                      _buildInfoRow('Tên ${request.type == AccessRequestType.device ? 'thiết bị' : 'phòng'}', request.resourceName),
                      if (request.macAddress != null) ...[
                        SizedBox(height: 12.h),
                        _buildInfoRow('MAC Address', request.macAddress!),
                      ],
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Trạng thái', style: AppTextStyles.bodyMedium(color: Colors.grey.shade600)),
                          StatusChip(status: request.currentStatus),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32.h),

                if (request.currentStatus == AccessRequestStatus.pending) ...[
                  RoleSelector(
                    selectedRole: _selectedRole!,
                    onChanged: state.status == AccessRequestDetailStatus.submitting
                        ? null
                        : (role) => setState(() => _selectedRole = role),
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.status == AccessRequestDetailStatus.submitting
                              ? null
                              : () {
                                  context.read<AccessRequestDetailCubit>().respondToRequest(
                                    request.id,
                                    request.type,
                                    accept: false,
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            side: BorderSide(color: Colors.red.shade400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: state.isDeclining
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(color: Colors.red.shade400, strokeWidth: 2),
                                )
                              : Text(
                                  'Từ chối',
                                  style: AppTextStyles.titleMedium(color: Colors.red.shade400),
                                ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.status == AccessRequestDetailStatus.submitting
                              ? null
                              : () {
                                  context.read<AccessRequestDetailCubit>().respondToRequest(
                                    request.id,
                                    request.type,
                                    accept: true,
                                    roleToGrant: _selectedRole,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            elevation: 0,
                          ),
                          child: state.isAccepting
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Chấp nhận',
                                  style: AppTextStyles.titleMedium(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'Yêu cầu này đã được xử lý hoặc hết hạn.',
                        style: AppTextStyles.bodyMedium(color: AppColors.primary),
                        textAlign: TextAlign.center,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(color: Colors.grey.shade600)),
        Text(value, style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
