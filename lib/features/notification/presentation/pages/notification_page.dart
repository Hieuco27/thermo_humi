import 'package:flutter/material.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: Text('Thông báo')),
      ),
    );
  }
}
