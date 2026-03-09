import 'package:flutter/material.dart';

class Bakgrunn extends StatelessWidget {
  final Widget child;

  const Bakgrunn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.asset(
            'bilder/FNF.png',
            fit: BoxFit.contain,
          ),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.5),
        ),
        child,
      ],
    );
  }
}