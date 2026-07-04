/// DeviceListItem — card thiết bị trong danh sách phòng
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

String _formatRelativeTime(DateTime? dt) {
  if (dt == null) return '--';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
  if (diff.inHours < 24) return '${diff.inHours} giờ';
  return '${diff.inDays} ngày';
}

class DeviceListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isAlert = device.hasAlert;

    final Color cardBg = isAlert
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFFFFFFF);

    final Color borderColor = isAlert
        ? const Color(0xFFFF9800)
        : const Color(0xFFE5E5EA);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isAlert
                      ? const Color(0xFFFF9800).withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 40.w, 12.h),
              child: Row(
                children: [
                  // ── Device name & alert badge ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusDot(
                              isOnline: device.isOnline,
                              hasAlert: isAlert,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                device.name,
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
                              value: device.currentTemperature != null
                                  ? '${device.currentTemperature!.toStringAsFixed(1)}°C'
                                  : '--',
                              isAlert: device.isTemperatureAlert,
                            ),
                            SizedBox(width: 10.w),
                            _MetricChip(
                              icon: Icons.water_drop_outlined,
                              value: device.currentHumidity != null
                                  ? '${device.currentHumidity!.toStringAsFixed(0)}%'
                                  : '--',
                              isAlert: device.isHumidityAlert,
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
                      _ConnectivityWidget(status: device.connectivity),
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
                            _formatRelativeTime(device.lastUpdatedAt),
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── More menu (top-right corner) ──
          Positioned(
            top: 2.h,
            right: 10.w,
            child: _DeviceMoreMenu(
              onSettings: onSettings,
              onViewReport: onViewReport,
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

// ── More menu ─────────────────────────────────────────────────────────────────
enum _DeviceMenuAction { settings, report }

class _DeviceMoreMenu extends StatelessWidget {
  final VoidCallback? onSettings;
  final VoidCallback? onViewReport;

  const _DeviceMoreMenu({this.onSettings, this.onViewReport});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_DeviceMenuAction>(
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20.sp,
        color: const Color(0xFF8E8E93),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.white,
      elevation: 4,
      onSelected: (action) {
        if (action == _DeviceMenuAction.settings) {
          onSettings?.call();
        } else if (action == _DeviceMenuAction.report) {
          onViewReport?.call();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _DeviceMenuAction.settings,
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: 18.sp,
                color: const Color(0xFF007AFF),
              ),
              SizedBox(width: 10.w),
              Text(
                'Cài đặt thiết bị',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: _DeviceMenuAction.report,
          child: Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 18.sp,
                color: const Color(0xFF34C759),
              ),
              SizedBox(width: 10.w),
              Text(
                'Xem báo cáo',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
