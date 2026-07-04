import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/hourly_report_entity.dart';

/// Một hàng dữ liệu trong bảng báo cáo theo giờ.
/// Tự động highlight nền đỏ nhạt nếu nhiệt độ hoặc độ ẩm vượt ngưỡng.
class ReportDataRow extends StatelessWidget {
  final HourlyReportEntity item;

  const ReportDataRow({super.key, required this.item});

  static const Color _normalText = Color(0xFF333333);
  static const Color _alertText = Color(0xFFC62828); // Deep red
  static const Color _alertBg = Color(0xFFFDE8E8);   // Light red bg

  @override
  Widget build(BuildContext context) {
    final bool hasAlert = item.isTempAlert || item.isHumidityAlert;
    final Color bgColor = hasAlert ? _alertBg : Colors.white;

    return Container(
      color: bgColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Giờ
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('HH:mm').format(item.time),
              style: AppTextStyles.bodyMedium(color: _normalText),
            ),
          ),

          // Nhiệt độ
          Expanded(
            flex: 3,
            child: Text(
              '${item.temperature.toStringAsFixed(1)}°C',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                color: item.isTempAlert ? _alertText : _normalText,
              ).copyWith(
                fontWeight:
                    item.isTempAlert ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),

          // Độ ẩm
          Expanded(
            flex: 3,
            child: Text(
              '${item.humidity.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                color: item.isHumidityAlert ? _alertText : _normalText,
              ).copyWith(
                fontWeight:
                    item.isHumidityAlert ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),

          // Tình trạng kết nối
          Expanded(
            flex: 3,
            child: Text(
              _statusLabel(item.connectionStatus),
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium(
                color: item.connectionStatus == ConnectionStatus.disconnected
                    ? _alertText
                    : _normalText,
              ).copyWith(
                fontWeight:
                    item.connectionStatus == ConnectionStatus.disconnected
                        ? FontWeight.w600
                        : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.stable:
        return 'Ổn định';
      case ConnectionStatus.weak:
        return 'Kém';
      case ConnectionStatus.disconnected:
        return 'Mất kết nối';
    }
  }
}
