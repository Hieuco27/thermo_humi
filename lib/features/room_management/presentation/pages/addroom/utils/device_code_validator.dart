/// DeviceCodeValidator — pure Dart utility (no Flutter deps)
/// Validate mã QR và IMEI. Không phụ thuộc UI để có thể unit test độc lập.
library;

class DeviceCodeValidator {
  DeviceCodeValidator._();

  // ── QR Payload Parser ─────────────────────────────────────────────────────
  /// Parse raw QR string → trả về deviceCode nếu hợp lệ, null nếu sai định dạng.
  ///
  /// Chiến lược UI-first (chưa có thiết bị thực):
  ///  - Chấp nhận bất kỳ chuỗi QR nào có độ dài >= 8 ký tự
  ///  - Khi BE xác nhận định dạng thực, thay logic trong hàm này
  ///
  /// Ví dụ định dạng tương lai có thể hỗ trợ:
  ///  - IMEI 15 số thuần:   "123456789012345"
  ///  - Prefix HMS:          "HMS://123456789012345"
  ///  - JSON:                {"deviceId":"123456789012345","type":"sensor"}
  static String? parseQrPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // Thử parse prefix HMS://
    if (trimmed.startsWith('HMS://')) {
      final code = trimmed.replaceFirst('HMS://', '');
      return code.isNotEmpty ? code : null;
    }

    // Thử parse JSON đơn giản {"deviceId":"..."}
    if (trimmed.startsWith('{') && trimmed.contains('deviceId')) {
      final match = RegExp(r'"deviceId"\s*:\s*"([^"]+)"').firstMatch(trimmed);
      if (match != null) return match.group(1);
    }

    // Nếu là IMEI thuần 15 chữ số
    if (RegExp(r'^\d{15}$').hasMatch(trimmed)) {
      return trimmed;
    }

    // Fallback UI-first: chấp nhận mọi chuỗi >= 8 ký tự (không khoảng trắng giữa)
    // TODO: Thay bằng validate chặt khi có thiết bị thực
    if (trimmed.length >= 8 && !trimmed.contains(' ')) {
      return trimmed;
    }

    return null;
  }

  // ── IMEI Validator ────────────────────────────────────────────────────────
  /// Validate IMEI nhập tay: đúng định dạng = 15 chữ số và pass Luhn check.
  static bool isValidImei(String imei) {
    final clean = imei.trim();
    if (!RegExp(r'^\d{15}$').hasMatch(clean)) return false;
    return _luhnCheck(clean);
  }

  /// Trả về lỗi validate IMEI để hiển thị realtime (null = ok hoặc chưa đủ dài)
  static String? imeiError(String imei) {
    final clean = imei.trim();
    if (clean.isEmpty) return null;
    if (clean.length < 15) return null; // Đang nhập, chưa show lỗi
    if (!RegExp(r'^\d{15}$').hasMatch(clean)) {
      return 'IMEI phải gồm đúng 15 chữ số';
    }
    if (!_luhnCheck(clean)) {
      return 'Mã IMEI không hợp lệ (sai checksum)';
    }
    return null;
  }

  /// Kiểm tra xem deviceCode đã hợp lệ để bật nút Kích hoạt chưa.
  /// Trả về true nếu là IMEI hợp lệ HOẶC là mã QR bất kỳ đã parse được.
  static bool isDeviceCodeReady(String? code) {
    if (code == null || code.trim().isEmpty) return false;
    return code.trim().length >= 8;
  }

  // ── Luhn Algorithm ────────────────────────────────────────────────────────
  static bool _luhnCheck(String number) {
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}
