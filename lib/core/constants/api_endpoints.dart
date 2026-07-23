class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String change_password = '/auth/change-password';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboardSummary = '/api/v1/dashboard/summary';

  // ── Rooms ─────────────────────────────────────────────────────────────────
  static String getListRoom(String userId) => '/api/Dashboard/$userId/rooms';
  static const String locationQuery = '/location/query';

  // ── Devices ───────────────────────────────────────────────────────────────
  static const String deviceQuery = '/device/query';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = '/api/v1/profile';
  static const String changePassword = '/api/v1/profile/change-password';

  // ── Phone Alert (SMS cảnh báo) ────────────────────────────────────────────
  static const String phoneAlertSendOtp = '/api/v1/phone-alert/send-otp';
  static const String phoneAlertVerifyOtp = '/api/v1/phone-alert/verify-otp';
}
