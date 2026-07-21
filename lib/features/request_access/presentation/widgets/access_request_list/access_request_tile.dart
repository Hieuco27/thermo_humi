import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';
import 'package:thermo_humi/features/request_access/presentation/widgets/access_request_list/status_chip.dart';

class AccessRequestTile extends StatelessWidget {
  final AccessRequest request;
  final VoidCallback onTap;

  const AccessRequestTile({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = request.currentStatus;
    final isPending = status == AccessRequestStatus.pending;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isPending ? const Color(0xFFFFF7E6) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isPending ? Colors.orange.shade200 : Colors.grey.shade400,
          ),
          boxShadow: isPending
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isPending
                    ? Colors.orange.shade100
                    : const Color(0xFFD6E4FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  request.requesterInitials,
                  style: AppTextStyles.titleMedium(
                    color: isPending ? Colors.orange : AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${request.formattedRequesterName} muốn truy cập ${request.resourceName}',
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Xin quyền ${request.roleRequested.displayName} · ${request.type == AccessRequestType.device ? 'Thiết bị' : 'Phòng'}',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  StatusChip(status: status),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Time
            Text(
              DateFormat('HH:mm').format(request.createdAt),
              style: AppTextStyles.titleSmall2(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
