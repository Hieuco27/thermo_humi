import 'package:equatable/equatable.dart';

enum ReportStatus { normal, highAlert, lowAlert }

class DeviceReportPoint extends Equatable {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final ReportStatus status;

  const DeviceReportPoint({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.status,
  });

  @override
  List<Object?> get props => [timestamp, temperature, humidity, status];
}

class DeviceReportDataEntity extends Equatable {
  final List<DeviceReportPoint> points;
  final int totalRecords;
  final int currentPage;

  const DeviceReportDataEntity({
    required this.points,
    required this.totalRecords,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [points, totalRecords, currentPage];
}
