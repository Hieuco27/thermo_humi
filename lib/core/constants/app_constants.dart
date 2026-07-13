/// App-wide constants
library;

class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'ThermoHumi';
  static const String appVersion = '1.0.0';

  // ── Storage Keys ──────────────────────────────────────────────────────────
  static const String kAccessToken = 'access_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUserId = 'user_id';
  static const String kUserData = 'user_data';
  static const String kThemeMode = 'theme_mode';
  static const String kLanguage = 'language';
  static const String kFcmToken = 'fcm_token';

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  // ── Network ───────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // ── Realtime (abstracted - configured via env) ────────────────────────────
  static const String kRealtimeType = 'REALTIME_TYPE';
  static const Duration pollingInterval = Duration(seconds: 30);

  // ── Chart ─────────────────────────────────────────────────────────────────
  static const int chart24hPoints = 48;

  // ── Validation ────────────────────────────────────────────────────────────
  static const int minPasswordLength = 6;
  static const double minTemperature = -40.0;
  static const double maxTemperature = 125.0;
  static const double minHumidity = 0.0;
  static const double maxHumidity = 100.0;

  // ── Debounce ──────────────────────────────────────────────────────────────
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // ── QR ────────────────────────────────────────────────────────────────────
  static const String qrSharePrefix = 'thermohumi://share';
  static const Duration qrExpiry = Duration(hours: 24);

  // ── Share Resource Types ──────────────────────────────────────────────────
  static const String resourceTypeRoom = 'room';
  static const String resourceTypeDevice = 'device';
}
