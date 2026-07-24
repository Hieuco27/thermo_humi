import 'package:equatable/equatable.dart';

class SensorEntity extends Equatable {
  final String? nameSensor;

  final double? humidity;
  final double? temperature;

  const SensorEntity({this.nameSensor, this.humidity, this.temperature});

  @override
  List<Object?> get props => [nameSensor, humidity, temperature];
}
