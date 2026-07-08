import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  const AppBackground({super.key, required this.child, this.opacity = 0.4});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          opacity: opacity,
        ),
      ),
      child: child,
    );
  }
}
