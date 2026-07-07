import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class QrShareView extends StatelessWidget {
  final String qrData;
  final int remainingSeconds;
  final VoidCallback onRefresh;

  const QrShareView({
    super.key,
    required this.qrData,
    required this.remainingSeconds,
    required this.onRefresh,
  });

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16.h),
        // QR Code Container
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200.w,
            backgroundColor: Colors.transparent,
          ),
        ),
        SizedBox(height: 20.h),

        // Expiration
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 16.w, color: const Color(0xFFB58B24)),
            SizedBox(width: 8.w),
            Text(
              'Mã hết hạn sau ${_formatDuration(remainingSeconds)}',
              style: AppTextStyles.bodyMedium(
                color: const Color(0xFFB58B24),
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Instruction text
        Text(
          'Yêu cầu người nhận mở app, vào mục "Quét mã chia sẻ" và đưa camera vào mã này để nhận quyền truy cập.',
          textAlign: TextAlign.center,
          style: AppTextStyles.label13(color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),

        // Refresh button
        OutlinedButton.icon(
          onPressed: onRefresh,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          icon: Icon(Icons.refresh, color: AppColors.textPrimary, size: 20.w),
          label: Text(
            'Tạo mã mới',
            style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
