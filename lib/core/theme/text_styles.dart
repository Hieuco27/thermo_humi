import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';

/// Custom text styles for the app
class AppTextStyles {
  AppTextStyles._();

  // Headline styles
  static TextStyle headlineLarge() {
    return GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle headlineMedium() {
    return GoogleFonts.inter(fontSize: 28.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle headlineSmall() {
    return GoogleFonts.inter(fontSize: 24.sp, fontWeight: FontWeight.w600);
  }

  // Title styles
  static TextStyle titleLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle titleLargeDiaLog() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMediumBlack() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle titleMediumLogin() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMediumAppBar({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle titleSmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 11.sp,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle titleSmall2({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle titleSmall3({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle titleMediumIcon() {
    return GoogleFonts.inter(
      fontSize: 19.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMedium16() {
    return GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500);
  }

  // Label styles
  static TextStyle labelLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle labelLarge2({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle labelMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      color: color ?? AppColors.textSecondary,
    );
  }

  static TextStyle labelSmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 11.sp,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  // Body styles
  static TextStyle bodyLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  // Body styles
  static TextStyle bodyLarge1({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle bodyLargeEmphasized() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: color,
      height: 20 / 14,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textPrimary,
      height: 16 / 12,
    );
  }

  // 13.sp styles
  static TextStyle body13({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle label13({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary,
    );
  }
}
