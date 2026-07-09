import 'package:equatable/equatable.dart';

class ThresholdChangeLog extends Equatable {
  final String id;
  final String userName;
  final String userInitials;
  final DateTime timestamp;
  final String deviceName;
  final String metricType; // 'Ngưỡng nhiệt độ' or 'Ngưỡng độ ẩm'
  final String oldValue;
  final String newValue;

  const ThresholdChangeLog({
    required this.id,
    required this.userName,
    required this.userInitials,
    required this.timestamp,
    required this.deviceName,
    required this.metricType,
    required this.oldValue,
    required this.newValue,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        userInitials,
        timestamp,
        deviceName,
        metricType,
        oldValue,
        newValue,
      ];
}
