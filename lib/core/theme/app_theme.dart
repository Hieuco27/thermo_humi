import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const LinearGradient registerButton = LinearGradient(
    colors: <Color>[
      AppColors.buttonGradientStartRegister,
      AppColors.buttonGradientEndRegister,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
