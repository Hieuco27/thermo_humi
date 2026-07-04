import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS grouped background
      appBar: AppBar(
        title: Text(
          'Báo cáo',
          style: AppTextStyles.titleMedium(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Màn hình báo cáo đang được phát triển...',
          style: AppTextStyles.bodyMedium(color: Colors.grey),
        ),
      ),
    );
  }
}
