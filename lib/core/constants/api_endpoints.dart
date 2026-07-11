/// API Endpoints — tất cả đường dẫn API tập trung 1 nơi
/// .NET backend convention: /api/v1/...
library;

class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboardSummary = '/api/v1/dashboard/summary';

  // ── Rooms ─────────────────────────────────────────────────────────────────
  static const String rooms = '/api/v1/rooms';
  static String roomById(String id) => '/api/v1/rooms/$id';
  static String roomDevices(String roomId) => '/api/v1/rooms/$roomId/devices';

  // ── Devices ───────────────────────────────────────────────────────────────
  static const String devices = '/api/v1/devices';
  static String deviceById(String id) => '/api/v1/devices/$id';
  static String deviceReadings(String id) => '/api/v1/devices/$id/readings';
  static String deviceReadings24h(String id) =>
      '/api/v1/devices/$id/readings/24h';
  static String deviceThreshold(String id) => '/api/v1/devices/$id/threshold';

  // ── Sharing ───────────────────────────────────────────────────────────────
  static const String shareInvitations = '/api/v1/sharing/invitations';
  static String acceptInvitation(String token) =>
      '/api/v1/sharing/invitations/$token/accept';
  static String revokeAccess(String id) => '/api/v1/sharing/access/$id/revoke';
  static String generateShareQr(String resourceType, String resourceId) =>
      '/api/v1/sharing/qr/$resourceType/$resourceId';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/api/v1/notifications';
  static String markNotificationRead(String id) =>
      '/api/v1/notifications/$id/read';
  static const String registerSms = '/api/v1/notifications/sms/register';
  static const String registerPushToken = '/api/v1/notifications/push/register';

  // ── Account / Members ─────────────────────────────────────────────────────
  static const String members = '/api/v1/account/members';
  static String memberById(String id) => '/api/v1/account/members/$id';
  static String memberPermissions(String id) =>
      '/api/v1/account/members/$id/permissions';

  // ── Audit Logs ────────────────────────────────────────────────────────────
  static const String auditLogs = '/api/v1/account/audit-logs';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = '/api/v1/profile';
  static const String changePassword = '/api/v1/profile/change-password';
}
