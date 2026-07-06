import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class NetworkSignalCard extends StatelessWidget {
  const NetworkSignalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gauge Icon Placeholder
          const Icon(Icons.speed, color: AppColors.dashboardSuccess, size: 64),
          const SizedBox(height: 16),
          Text(
            'Cường độ tín hiệu\nMạng 4G',
            style: AppTextStyles.titleSmall2(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ổn định',
            style: AppTextStyles.titleSmall2(color: AppColors.dashboardSuccess),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
