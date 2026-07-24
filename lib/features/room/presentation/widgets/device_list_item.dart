import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/sensor_entity.dart';
import 'package:thermo_humi/features/device/presentation/widgets/device/device_bottom_sheet.dart';

String _formatRelativeTime(DateTime? dt) {
  if (dt == null) return '--';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
  if (diff.inHours < 24) return '${diff.inHours} giờ';
  return '${diff.inDays} ngày';
}

String _formatExact(double? val) {
  if (val == null) return '--';
  if (val == val.toInt()) return val.toInt().toString();
  return val.toString();
}

/// Tính sensor "tệ nhất": ưu tiên sensor đang có cảnh báo, nếu không có thì lấy đầu tiên
SensorEntity? _worstSensor(DeviceEntity device) {
  final sensors = device.sensors;
  if (sensors.isEmpty) return null;
  for (final s in sensors) {
    final tempAlert =
        s.temperature != null &&
        (s.temperature! > device.temperatureMax ||
            s.temperature! < device.temperatureMin);
    final humAlert =
        s.humidity != null &&
        (s.humidity! > device.humidityMax || s.humidity! < device.humidityMin);
    if (tempAlert || humAlert) return s;
  }
  return sensors.first;
}

int _alertCount(DeviceEntity device) {
  final sensors = device.sensors;
  int count = 0;
  for (final s in sensors) {
    final tempAlert =
        s.temperature != null &&
        (s.temperature! > device.temperatureMax ||
            s.temperature! < device.temperatureMin);
    final humAlert =
        s.humidity != null &&
        (s.humidity! > device.humidityMax || s.humidity! < device.humidityMin);
    if (tempAlert || humAlert) count++;
  }
  return count;
}

class DeviceListItem extends StatefulWidget {
  final DeviceEntity device;
  final VoidCallback? onTap;
  final VoidCallback? onSettings;
  final VoidCallback? onViewReport;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<String>? onToggleSelect;

  const DeviceListItem({
    super.key,
    required this.device,
    this.onTap,
    this.onSettings,
    this.onViewReport,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelect,
  });

  @override
  State<DeviceListItem> createState() => _DeviceListItemState();
}

class _DeviceListItemState extends State<DeviceListItem> {
  bool _isActive = false;
  bool _expanded = false;
  bool _showAll = false;

  static const int _maxVisible = 4;

  Future<void> _handleTap() async {
    HapticFeedback.selectionClick();
    setState(() => _isActive = true);

    if (widget.isSelectionMode && widget.onToggleSelect != null) {
      widget.onToggleSelect!(widget.device.id);
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) setState(() => _isActive = false);
      return;
    }

    if (widget.onTap != null) {
      widget.onTap!();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _isActive = false);
    } else {
      await DeviceBottomSheet.show(context, widget.device);
      if (mounted) setState(() => _isActive = false);
    }
  }

  void _toggleExpand() {
    HapticFeedback.selectionClick();
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) _showAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAlert = widget.device.hasAlert;
    final sensors = widget.device.sensors;

    Color cardBg = isAlert ? AppColors.dashboardAlertBg : Colors.white;
    if (_isActive) cardBg = const Color(0xFFF0F0F5);

    final Color borderColor = isAlert
        ? AppColors.dashboardWarning
        : (_isActive ? const Color(0xFFD1D1D6) : const Color(0xFFE5E5EA));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isAlert
                ? AppColors.dashboardWarning.withValues(alpha: 0.3)
                : AppColors.backgroundColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (tap to open detail)
          GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 12.h, 12.w, 8.h),
              child: Row(
                children: [
                  if (widget.isSelectionMode) ...[
                    GestureDetector(
                      onTap: _handleTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 12.w, left: 4.w),
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isSelected
                                ? AppColors.wardroRedText
                                : Colors.grey.shade400,
                            width: widget.isSelected ? 6.w : 1.5.w,
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        _StatusDot(
                          isOnline: widget.device.isOnline,
                          hasAlert: isAlert,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.device.name.isNotEmpty
                                ? widget.device.name
                                : widget.device.id,
                            style: AppTextStyles.labelLarge2().copyWith(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _ConnectivityWidget(status: widget.device.connectivity),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.access_time_rounded,
                          size: 15.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          _formatRelativeTime(widget.device.lastUpdatedAt),
                          style: AppTextStyles.label13(),
                        ),
                      ],
                    ),
                  ),
                  if (sensors.isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: _toggleExpand,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                        child: AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 24.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Summary row (collapsed) hoặc sensor list (expanded)
          if (sensors.isEmpty)
            // Không có sensor: tóm tắt cũ + tap để mở detail
            GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 16.w, 12.h),
                child: Row(
                  children: [
                    _MetricChip(
                      icon: Icons.thermostat_outlined,
                      value: widget.device.currentTemperature != null
                          ? '${_formatExact(widget.device.currentTemperature)}°C'
                          : '--',
                      isAlert: widget.device.isTemperatureAlert,
                    ),
                    SizedBox(width: 10.w),
                    _MetricChip(
                      icon: Icons.water_drop_outlined,
                      value: widget.device.currentHumidity != null
                          ? '${_formatExact(widget.device.currentHumidity)}%'
                          : '--',
                      isAlert: widget.device.isHumidityAlert,
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: !_expanded ? _handleTap : null,
              behavior: HitTestBehavior.opaque,
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: _buildSummaryRow(widget.device),
                secondChild: _buildSensorList(widget.device),
              ),
            ),
        ],
      ),
    );
  }

  // Summary row (collapsed)
  Widget _buildSummaryRow(DeviceEntity device) {
    final sensors = device.sensors;
    final worst = _worstSensor(device);
    final alerts = _alertCount(device);

    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 0, 16.w, 12.h),
      child: Row(
        children: [
          _MetricChip(
            icon: Icons.thermostat_outlined,
            value: worst?.temperature != null
                ? '${_formatExact(worst!.temperature)}°C'
                : '--',
            isAlert:
                worst != null &&
                worst.temperature != null &&
                (worst.temperature! > device.temperatureMax ||
                    worst.temperature! < device.temperatureMin),
          ),
          SizedBox(width: 8.w),
          _MetricChip(
            icon: Icons.water_drop_outlined,
            value: worst?.humidity != null
                ? '${_formatExact(worst!.humidity)}%'
                : '--',
            isAlert:
                worst != null &&
                worst.humidity != null &&
                (worst.humidity! > device.humidityMax ||
                    worst.humidity! < device.humidityMin),
          ),
          SizedBox(width: 10.w),
          Text(
            alerts > 0
                ? '${sensors.length} sensor · $alerts cảnh báo'
                : '${sensors.length} sensor',
            style: AppTextStyles.label13(
              color: alerts > 0
                  ? const Color(0xFFFF3B30)
                  : AppColors.textSecondary,
              fontWeight: alerts > 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Expanded sensor list
  Widget _buildSensorList(DeviceEntity device) {
    final sensors = device.sensors;
    final tooMany = sensors.length > 6;
    final displayList = tooMany && !_showAll
        ? sensors.take(_maxVisible).toList()
        : sensors;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < displayList.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.5,
                color: const Color(0xFFE5E5EA),
              ),
            _SensorRow(
              sensor: displayList[i],
              tempAlert:
                  displayList[i].temperature != null &&
                  (displayList[i].temperature! > device.temperatureMax ||
                      displayList[i].temperature! < device.temperatureMin),
              humAlert:
                  displayList[i].humidity != null &&
                  (displayList[i].humidity! > device.humidityMax ||
                      displayList[i].humidity! < device.humidityMin),
            ),
          ],
          if (tooMany && !_showAll) ...[
            Divider(height: 1, thickness: 0.5, color: const Color(0xFFE5E5EA)),
            GestureDetector(
              onTap: () => setState(() => _showAll = true),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'Xem thêm ${sensors.length - _maxVisible} sensor',
                  style: AppTextStyles.label13(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Sensor row
class _SensorRow extends StatelessWidget {
  final SensorEntity sensor;
  final bool tempAlert;
  final bool humAlert;

  const _SensorRow({
    required this.sensor,
    this.tempAlert = false,
    this.humAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color tempColor = tempAlert
        ? const Color(0xFFFF3B30)
        : const Color(0xFF6D6D71);
    final Color humColor = humAlert
        ? const Color(0xFFFF3B30)
        : const Color(0xFF6D6D71);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              sensor.nameSensor ?? 'Sensor',
              style: AppTextStyles.label13(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          // Nhiệt độ
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thermostat_outlined, size: 14.sp, color: tempColor),
              SizedBox(width: 2.w),
              Text(
                sensor.temperature != null
                    ? '${_formatExact(sensor.temperature)}°C'
                    : '--',
                style: AppTextStyles.label13(
                  color: tempColor,
                  fontWeight: tempAlert ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // Độ ẩm
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop_outlined, size: 14.sp, color: humColor),
              SizedBox(width: 2.w),
              Text(
                sensor.humidity != null
                    ? '${_formatExact(sensor.humidity)}%'
                    : '--',
                style: AppTextStyles.label13(
                  color: humColor,
                  fontWeight: humAlert ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Status dot
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

    return Container(
      width: 10.r,
      height: 10.r,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// Metric chip
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
        SizedBox(width: 4.w),
        Icon(icon, size: 15.sp, color: color),
        SizedBox(width: 3.w),
        Text(
          value,
          style: AppTextStyles.label13(
            color: color,
            fontWeight: isAlert ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Connectivity widget
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
        color = AppColors.dashboardSuccess;
        break;
      case ConnectivityStatus.medium:
        label = '4G';
        icon = Icons.signal_cellular_alt_2_bar;
        color = AppColors.wardroRedText;
        break;
      case ConnectivityStatus.weak:
        label = '4G';
        icon = Icons.signal_cellular_alt_1_bar;
        color = AppColors.wardroRedText;
        break;
      case ConnectivityStatus.none:
        label = 'No';
        icon = Icons.signal_cellular_off_outlined;
        color = AppColors.textSecondary;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: color),
        SizedBox(width: 3.w),
        Text(label, style: AppTextStyles.label13()),
      ],
    );
  }
}
