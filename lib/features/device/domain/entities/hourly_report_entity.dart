import 'package:equatable/equatable.dart';

enum ConnectionStatus { stable, disconnected, weak }

class HourlyReportEntity extends Equatable {
  final DateTime time;
  final double temperature;
  final double humidity;
  final int? signalStrength;
  final ConnectionStatus connectionStatus;

  // Thresholds used for alerts
  final double maxTemperature;
  final double maxHumidity;

  const HourlyReportEntity({
    required this.time,
    required this.temperature,
    required this.humidity,
    this.signalStrength,
    required this.connectionStatus,
    required this.maxTemperature,
    required this.maxHumidity,
  });

  bool get isTempAlert => temperature > maxTemperature;
  bool get isHumidityAlert => humidity > maxHumidity;

  @override
  List<Object?> get props => [
        time,
        temperature,
        humidity,
        signalStrength,
        connectionStatus,
        maxTemperature,
        maxHumidity,
      ];
}
