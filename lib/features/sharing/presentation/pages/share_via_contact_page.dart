import 'package:flutter/material.dart';

class ShareViaContactPage extends StatelessWidget {
  final String resourceType;
  final String resourceId;
  const ShareViaContactPage({super.key, required this.resourceType, required this.resourceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chia sẻ thiết bị')),
      body: const Center(child: Text('Chia sẻ qua SĐT / Email')),
    );
  }
}
