import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final bool isResolving;
  final VoidCallback onTap;
  final VoidCallback onResolveTap;

  const AlertCard({
    super.key,
    required this.alert,
    required this.isResolving,
    required this.onTap,
    required this.onResolveTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnresolved = !alert.isResolved;
    final isPositive = alert.type == AlertType.deviceOnline;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isUnresolved && !isPositive
              ? Border(
                  left: BorderSide(color: Colors.red, width: 4.w),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: Offset(0, 2.w),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(isUnresolved, isPositive),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: AppTextStyles.titleSmall3(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(alert.createdAt),
                          style: AppTextStyles.titleSmall(color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      alert.description,
                      style: AppTextStyles.titleSmall(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (!isPositive) _buildChip(isUnresolved),
                        const Spacer(),
                        if (isUnresolved && !isPositive) _buildActionBtn(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isUnresolved, bool isPositive) {
    IconData iconData;
    switch (alert.type) {
      case AlertType.thresholdExceeded:
        iconData = Icons.thermostat;
        break;
      case AlertType.humidityAbnormal:
        iconData = Icons.water_drop;
        break;
      case AlertType.deviceOffline:
        iconData = Icons.wifi_off;
        break;
      case AlertType.deviceOnline:
        iconData = Icons.wifi;
        break;
    }

    Color iconColor;
    if (isPositive) {
      iconColor = Colors.green;
    } else if (isUnresolved) {
      iconColor = Colors.red;
    } else {
      iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildChip(bool isUnresolved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUnresolved
            ? Colors.red.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isUnresolved ? 'Chưa xử lý' : 'Đã xử lý',
        style: AppTextStyles.labelSmall(
          color: isUnresolved ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildActionBtn() {
    if (isResolving) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
      );
    }

    return GestureDetector(
      onTap: onResolveTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          'Đánh dấu đã xử lý',
          style: AppTextStyles.labelSmall(color: Colors.blue),
        ),
      ),
    );
  }
}
