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
import '../widgets/access_request_detail/requester_info_card.dart';
import '../widgets/access_request_detail/requested_device_card.dart';
import '../widgets/access_request_detail/action_button.dart';

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
                      RequesterInfoCard(request: request),
                      SizedBox(height: 24.h),
                      // Section 2: Thiết bị yêu cầu
                      RequestedDeviceCard(request: request),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              ActionButton(
                label: 'Đã được xác nhận',
                onPressed: () {},
                backgroundColor: const Color(0xFF98F59B),
                textColor: const Color(0xFF7CB37C),
              ),
            ],
          ),
        );
      },
    );
  }
}
