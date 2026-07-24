import 'package:thermo_humi/features/device/domain/entities/sensor_entity.dart';

class SensorModel extends SensorEntity {
  const SensorModel({super.nameSensor, super.humidity, super.temperature});

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return SensorModel(
      nameSensor: json['nameSensor'] as String?,
      humidity: parseDouble(json['humidity']),
      temperature: parseDouble(json['temperature']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameSensor': nameSensor,
      'humidity': humidity,
      'temperature': temperature,
    };
  }
}
