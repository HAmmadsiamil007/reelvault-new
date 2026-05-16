import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SplashLogoWidget extends StatelessWidget {
  final double glowIntensity;

  const SplashLogoWidget({super.key, required this.glowIntensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryMagenta],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.55 * glowIntensity),
            blurRadius: 40 * glowIntensity,
            spreadRadius: 8 * glowIntensity,
          ),
          BoxShadow(
            color: AppTheme.primaryMagenta.withValues(
              alpha: 0.3 * glowIntensity,
            ),
            blurRadius: 60 * glowIntensity,
            spreadRadius: 4 * glowIntensity,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.video_library_rounded, color: Colors.white, size: 52),
      ),
    );
  }
}
