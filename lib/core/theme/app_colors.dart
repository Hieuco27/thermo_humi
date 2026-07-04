import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const backgroundColor = Color(0xFF000000);
  static const textColor = Color(0xFFFFFFFF);
  static const headerColor = Color(0xFFC2F1A6);

  static const directions = Color(0xFFF53F3F);
  static const gradientStart = Color(0xFF0077B6);
  static const gradientEnd = Color(0xFF2184F5);
  static const primary = Color(0xFF007AFF);
  static const primary2 = Color(0xFF0F6BAE);
  static const primary3 = Color(0xFF1168A7);
  static const pink = Color(0xFFF5CFE4);
  static const gray = Color(0xFFF2F2F2);

  static const primaryDark = Color(0xFF005BB5);
  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF6D6D71);
  static const border = Color(0xFFE5E5EA);

  //  Chung (không đổi theo theme)
  static const primary1 = Color(0xFF2186FA);

  // ── Auth & Brand Colors ──
  static const brandPurple = Color(
    0xFF5300B4,
  ); // Dark purple from the AI Stylist logo
  static const buttonGradientStartLogin = Color(0xFF5A00C8);
  static const buttonGradientEndLogin = Color(0xFFE8256F);

  static const buttonGradientStartRegister = Color(0xFFF07575);
  static const buttonGradientEndRegister = Color(0xFF5EC4B2);

  static const textFieldBorder = Color(0xFFD6D6E0);
  static const textFieldHint = Color(0xFFAAAAAA);

  // ── Wardro Colors ──
  static const wardroBrown = Color(0xFF90553A);
  static const wardroRedText = Color(0xFFE55A54);
  static const wardroInputBg = Color(0xFFF4F5F7);

  // ── Camera & Try-On Feature Colors ──
  static const cameraGold = Color(0xFFF5A623); // Garment mode frame, CTA chính
  static const cameraGoldDim = Color(0x33F5A623); // Gold mờ (fill)
  static const detectionGreen = Color(
    0xFF4CAF50,
  ); // AI detected, hotspot, true-to-size
  static const hotspotGlow = Color(0xFF00E676); // Hotspot pulse glow
  static const cameraOverlay = Color(0x26FFFFFF); // Overlay mờ trên camera

  // AI Fit Rating Badge Colors
  static const fitTrueToSize = Color(0xFF4CAF50); // Vừa vặn
  static const fitTight = Color(0xFFF44336); // Quá chật
  static const fitLoose = Color(0xFFFF9800); // Quá rộng

  // ── Home Light Theme — Warm Cream & Brown Palette ──
  /// Nền trang chủ — trắng kem ấm
  static const homeBackground = Color(0xFFFAF7F2);

  /// Nền card thông thường — trắng tinh
  static const homeSurface = Color(0xFFFFFFFF);

  /// Nền card thứ cấp — kem nhạt
  static const homeSurfaceAlt = Color(0xFFF1EBE0);

  /// Card "Chụp ảnh bạn" — nâu đậm sang trọng (primary action)
  static const homePrimaryCard = Color(0xFF3D2B1F);

  /// Màu nâu nhấn chính (alias của wardroBrown)
  static const homeAccentBrown = Color(0xFF90553A);

  /// Nâu nhạt — icon accent, viền
  static const homeAccentLight = Color(0xFFC8906A);

  /// Kem nâu — fill nền icon, badge background
  static const homeAccentCream = Color(0xFFE8D5C0);

  /// Text đen nâu — tiêu đề, tên mục
  static const homeTextPrimary = Color(0xFF1F150E);

  /// Text nâu xám — phụ đề, time ago
  static const homeTextSecondary = Color(0xFF8A6E5A);

  /// Text trên nền card tối (nâu đậm)
  static const homeTextOnDark = Color(0xFFFAF7F2);

  /// Đường kẻ, divider nhạt
  static const homeDivider = Color(0xFFEDE0D4);

  /// Nền badge AI — nâu đậm
  static const homeAiBadgeBg = Color(0xFF3D2B1F);

  /// Nền banner "Gợi ý hôm nay" — vàng kem ấm
  static const homeSuggestionBg = Color(0xFFFFF8F0);

  /// Viền dashed banner gợi ý — nâu mật ong
  static const homeSuggestionBorder = Color(0xFFD4AA88);

  // ── Dashboard Dark Theme Colors ──
  static const dashboardBackground = Color(0xFF041424); // Rất tối
  static const dashboardCardBg = Color(0xFF163749); // Màu thẻ hơi xanh lơ
  static const dashboardCardBgAlt = Color(0xFF1B4155); // Màu thẻ sáng hơn 1 chút
  static const dashboardTextPrimary = Color(0xFFFFFFFF);
  static const dashboardTextSecondary = Color(0xFF90A4AE);
  static const dashboardSuccess = Color(0xFF4CAF50);
  static const dashboardWarning = Color(0xFFFF9800);
}
