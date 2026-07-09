import 'package:thermo_humi/features/history/domain/entities/threshold_change_log.dart';

class ThresholdChangeLogModel extends ThresholdChangeLog {
  const ThresholdChangeLogModel({
    required super.id,
    required super.userName,
    required super.userInitials,
    required super.timestamp,
    required super.deviceName,
    required super.metricType,
    required super.oldValue,
    required super.newValue,
  });

  factory ThresholdChangeLogModel.fromJson(Map<String, dynamic> json) {
    return ThresholdChangeLogModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      userInitials: json['userInitials'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceName: json['deviceName'] as String,
      metricType: json['metricType'] as String,
      oldValue: json['oldValue'] as String,
      newValue: json['newValue'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userInitials': userInitials,
      'timestamp': timestamp.toIso8601String(),
      'deviceName': deviceName,
      'metricType': metricType,
      'oldValue': oldValue,
      'newValue': newValue,
    };
  }
}
