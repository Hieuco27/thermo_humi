import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/device_management/device_management_cubit.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/device_management/device_management_state.dart';

class DeviceFilterRow extends StatelessWidget {
  const DeviceFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeviceManagementCubit>();
    return BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.devices.length} thiết bị',
                style: AppTextStyles.label13(color: Colors.grey),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: cubit.onSortToggled,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_vert,
                            size: 16.sp,
                            color: Colors.black,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Tên ${state.sortOrder}',
                            style: AppTextStyles.label13(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
