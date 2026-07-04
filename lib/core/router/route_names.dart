/// Route names — tất cả tên route tập trung 1 nơi
library;

class RouteNames {
  RouteNames._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';

  // ── Shell (Bottom Nav) ────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String areas = '/areas';
  static const String notifications = '/notifications';
  static const String report = '/report';
  static const String account = '/account';
  static const String profile = '/profile';

  // ── Room ──────────────────────────────────────────────────────────────────
  static const String deviceList = '/dashboard/room/:roomId';
  static const String addRoom = '/dashboard/add-room';

  // ── Device ────────────────────────────────────────────────────────────────
  static const String deviceDetail =
      '/dashboard/room/:roomId/device/:deviceId';
  static const String deviceThreshold =
      '/dashboard/room/:roomId/device/:deviceId/threshold';
  static const String deviceReport =
      '/dashboard/room/:roomId/device/:deviceId/report';
  static const String addDevice = '/dashboard/room/:roomId/add-device';

  // ── Sharing ───────────────────────────────────────────────────────────────
  static const String shareContact = '/share/contact';
  static const String scanQr = '/share/scan-qr';

  // ── Account ───────────────────────────────────────────────────────────────
  static const String members = '/account/members';
  static const String auditLogs = '/account/audit-logs';
}
