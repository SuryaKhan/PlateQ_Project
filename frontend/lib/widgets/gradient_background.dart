import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1118), const Color(0xFF121212), const Color(0xFF0A0A0A)] // Elegant dark pink/purple to deep black
              : [const Color(0xFFFFF0F5), const Color(0xFFFFFFFF), const Color(0xFFFAFAFA)], // Soft pink to white
        ),
      ),
      child: child,
    );
  }
}
