import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelLarge().copyWith(fontWeight: FontWeight.w600),
    );
  }
}
