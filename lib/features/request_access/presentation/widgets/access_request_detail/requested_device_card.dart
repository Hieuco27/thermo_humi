import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';

class RequestedDeviceCard extends StatelessWidget {
  final AccessRequest request;

  const RequestedDeviceCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Thiết bị yêu cầu :',
            style: AppTextStyles.bodyMedium(color: Colors.black),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                        style: AppTextStyles.body13(color: Colors.black),
                        children: [
                          TextSpan(
                            text: request.roleRequested.displayName,
                            style: AppTextStyles.bodyMedium(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (request.macAddress != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        request.macAddress!,
                        style: AppTextStyles.bodyMedium(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
