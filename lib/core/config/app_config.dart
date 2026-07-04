/// App config từ .env — base URL, API version, realtime type
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:5000';

  static String get realtimeType =>
      dotenv.env['REALTIME_TYPE'] ?? 'POLLING'; // MQTT | WS | POLLING

  static String get mqttBroker => dotenv.env['MQTT_BROKER'] ?? '';

  static int get mqttPort =>
      int.tryParse(dotenv.env['MQTT_PORT'] ?? '1883') ?? 1883;

  static String get wsUrl => dotenv.env['WS_URL'] ?? '';

  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
