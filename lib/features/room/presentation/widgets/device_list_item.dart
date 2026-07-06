/// DeviceListItem — card thiết bị trong danh sách phòng
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/presentation/widgets/device/device_bottom_sheet.dart';

String _formatRelativeTime(DateTime? dt) {
  if (dt == null) return '--';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
  if (diff.inHours < 24) return '${diff.inHours} giờ';
  return '${diff.inDays} ngày';
}

class DeviceListItem extends StatefulWidget {
  final DeviceEntity device;
  final VoidCallback? onTap;
  final VoidCallback? onSettings;
  final VoidCallback? onViewReport;

  const DeviceListItem({
    super.key,
    required this.device,
    this.onTap,
    this.onSettings,
    this.onViewReport,
  });

  @override
  State<DeviceListItem> createState() => _DeviceListItemState();
}

class _DeviceListItemState extends State<DeviceListItem> {
  bool _isActive = false;

  Future<void> _handleTap() async {
    HapticFeedback.selectionClick();
    setState(() => _isActive = true);

    if (widget.onTap != null) {
      widget.onTap!();
      // Nếu có onTap bên ngoài truyền vào, giả lập delay nhỏ rồi reset
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _isActive = false);
    } else {
      await DeviceBottomSheet.show(context, widget.device);
      if (mounted) {
        setState(() => _isActive = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAlert = widget.device.hasAlert;

    Color cardBg = isAlert ? AppColors.dashboardAlertBg : Colors.white;

    if (_isActive) {
      cardBg = const Color(0xFFF0F0F5); // Màu xám nhạt khi đang chọn
    }

    final Color borderColor = isAlert
        ? AppColors.dashboardWarning
        : (_isActive ? const Color(0xFFD1D1D6) : const Color(0xFFE5E5EA));

    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isAlert
                      ? AppColors.dashboardWarning.withValues(alpha: 0.2)
                      : AppColors.backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 12.h, 16.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusDot(
                              isOnline: widget.device.isOnline,
                              hasAlert: isAlert,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                widget.device.name,
                                style: AppTextStyles.titleSmall3(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        // ── Metrics row ──
                        Row(
                          children: [
                            _MetricChip(
                              icon: Icons.thermostat_outlined,
                              value: widget.device.currentTemperature != null
                                  ? '${widget.device.currentTemperature!.toStringAsFixed(1)}°C'
                                  : '--',
                              isAlert: widget.device.isTemperatureAlert,
                            ),
                            SizedBox(width: 10.w),
                            _MetricChip(
                              icon: Icons.water_drop_outlined,
                              value: widget.device.currentHumidity != null
                                  ? '${widget.device.currentHumidity!.toStringAsFixed(0)}%'
                                  : '--',
                              isAlert: widget.device.isHumidityAlert,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // ── Right side: connectivity & time ──
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ConnectivityWidget(status: widget.device.connectivity),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 10.sp,
                            color: const Color(0xFF8E8E93),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            _formatRelativeTime(widget.device.lastUpdatedAt),
                            style: AppTextStyles.titleSmall(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status dot ─────────────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  final bool isOnline;
  final bool hasAlert;

  const _StatusDot({required this.isOnline, required this.hasAlert});

  @override
  Widget build(BuildContext context) {
    final Color color = hasAlert
        ? const Color(0xFFFF9800)
        : isOnline
        ? const Color(0xFF34C759)
        : const Color(0xFF8E8E93);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Metric chip
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isAlert;

  const _MetricChip({
    required this.icon,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isAlert
        ? const Color(0xFFFF3B30)
        : const Color(0xFF6D6D71);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 15.w),
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 3.w),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: isAlert ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Connectivity widget ─────────────────────────────────────────────────────
class _ConnectivityWidget extends StatelessWidget {
  final ConnectivityStatus status;

  const _ConnectivityWidget({required this.status});

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;
    final Color color;

    switch (status) {
      case ConnectivityStatus.strong:
        label = '4G';
        icon = Icons.signal_cellular_alt;
        color = const Color(0xFF34C759);
        break;
      case ConnectivityStatus.medium:
        label = '4G';
        icon = Icons.signal_cellular_alt_2_bar;
        color = const Color(0xFFFF9800);
        break;
      case ConnectivityStatus.weak:
        label = '4G';
        icon = Icons.signal_cellular_alt_1_bar;
        color = const Color(0xFFFF3B30);
        break;
      case ConnectivityStatus.none:
        label = 'No';
        icon = Icons.signal_cellular_off_outlined;
        color = const Color(0xFF8E8E93);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 3.w),
        Text(label, style: AppTextStyles.titleSmall()),
      ],
    );
  }
}
