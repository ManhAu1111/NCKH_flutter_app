import 'package:flutter/material.dart';

class AppLogo extends StatefulWidget {
  const AppLogo({super.key});

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isHovered = true),
      onTapUp: (_) => setState(() => isHovered = false),
      onTapCancel: () => setState(() => isHovered = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedRotation(
            turns: isHovered ? 12 / 360 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: isHovered ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.pets, color: Colors.white, size: 18),
                  ),
                  AnimatedScale(
                    scale: isHovered ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: "Pet"),
                TextSpan(
                  text: "AI",
                  style: TextStyle(color: Color(0xFF0D9488)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}