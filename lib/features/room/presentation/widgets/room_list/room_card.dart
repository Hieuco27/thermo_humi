import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/widgets/device_list_item.dart';

class RoomCard extends StatelessWidget {
  final RoomWithDevices rwd;
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onHeaderTap;
  final VoidCallback onViewAll;

  const RoomCard({
    super.key,
    required this.rwd,
    required this.isExpanded,
    required this.isDark,
    required this.onHeaderTap,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = const Color(0xFFFFFFFF);
    final Color borderColor = const Color(0xFFE5E5EA);
    final Color textPrimary = const Color(0xFF1C1C1E);
    final Color textSec = const Color(0xFF6D6D71);

    final bool hasAlert = rwd.room.hasAlert;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasAlert ? const Color(0xFFFF9800) : borderColor,
          width: hasAlert ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          _RoomCardHeader(
            room: rwd.room,
            devices: rwd.devices,
            isExpanded: isExpanded,
            isDark: isDark,
            textPrimary: textPrimary,
            textSec: textSec,
            hasAlert: hasAlert,
            onTap: onHeaderTap,
          ),

          // ── Device list (animated) ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _DeviceListSection(
              devices: rwd.devices,
              isDark: isDark,
              borderColor: borderColor,
              onViewAll: onViewAll,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Room Card Header ──────────────────────────────────────────────────────────
class _RoomCardHeader extends StatelessWidget {
  final RoomEntity room;
  final List<DeviceEntity> devices;
  final bool isExpanded;
  final bool isDark;
  final Color textPrimary;
  final Color textSec;
  final bool hasAlert;
  final VoidCallback onTap;

  const _RoomCardHeader({
    required this.room,
    required this.devices,
    required this.isExpanded,
    required this.isDark,
    required this.textPrimary,
    required this.textSec,
    required this.hasAlert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int onlineCount = devices.where((d) => d.isOnline).length;
    final int alertCount = devices.where((d) => d.hasAlert).length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Room icon
            SizedBox(
              width: 42.r,
              height: 42.r,
              // decoration: BoxDecoration(
              //   color: hasAlert
              //       ? const Color(0xFFFF9800).withValues(alpha: 0.12)
              //       : const Color(0xFF007AFF).withValues(alpha: 0.1),
              //   borderRadius: BorderRadius.circular(12.r),
              // ),
              child: SvgPicture.asset(
                'assets/icons/room/room.svg',
                width: 22.sp,
                height: 22.sp,
                colorFilter: ColorFilter.mode(
                  hasAlert ? const Color(0xFFFF9800) : const Color(0xFF007AFF),
                  BlendMode.srcIn,
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          room.name,
                          style: AppTextStyles.bodyLarge(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      _RoomStat(
                        svgAsset: 'assets/icons/room/device.svg',
                        value: '${room.totalDevices}',
                        color: textSec,
                      ),
                      SizedBox(width: 10.w),
                      _RoomStat(
                        svgAsset: 'assets/icons/room/4g.svg',
                        value: '$onlineCount online',
                        color: const Color(0xFF34C759),
                        iconSize: 10,
                      ),
                      if (alertCount > 0) ...[
                        SizedBox(width: 10.w),
                        _RoomStat(
                          svgAsset: 'assets/icons/room/canhBao.svg',
                          value: '$alertCount alert',
                          color: const Color(0xFFFF9800),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 280),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textSec,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomStat extends StatelessWidget {
  final String svgAsset;
  final String value;
  final Color color;
  final double iconSize;

  const _RoomStat({
    required this.svgAsset,
    required this.value,
    required this.color,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgAsset,
          width: iconSize.sp,
          height: iconSize.sp,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        SizedBox(width: 3.w),
        Text(value, style: AppTextStyles.bodyMedium()),
      ],
    );
  }
}

// ── Device list section ───────────────────────────────────────────────────────
class _DeviceListSection extends StatelessWidget {
  final List<DeviceEntity> devices;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onViewAll;

  const _DeviceListSection({
    required this.devices,
    required this.isDark,
    required this.borderColor,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Preview tối đa 3 thiết bị
    final preview = devices.take(3).toList();
    final hasMore = devices.length > 3;

    return Column(
      children: [
        Divider(height: 1, thickness: 0.5, color: borderColor),
        ...preview.map((d) => DeviceListItem(device: d)),
        if (hasMore)
          _ViewAllButton(
            remaining: devices.length - 3,
            isDark: isDark,
            onTap: onViewAll,
          ),
        SizedBox(height: 6.h),
      ],
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final int remaining;
  final bool isDark;
  final VoidCallback onTap;

  const _ViewAllButton({
    required this.remaining,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: const Color(0xFF007AFF).withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Xem tất cả', style: AppTextStyles.labelLarge()),
              if (remaining > 0) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text('+$remaining', style: AppTextStyles.bodyMedium()),
                ),
              ],
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12.sp,
                color: const Color(0xFF007AFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
