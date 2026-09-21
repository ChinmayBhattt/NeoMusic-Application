import 'package:flutter/material.dart';
import 'app_colors.dart';

/// NeoMusic glowing and atmospheric gradients
class AppGradients {
  // Primary brand button gradient
  static const LinearGradient primaryButton = LinearGradient(
    colors: [AppColors.primary, Color(0xFF0077B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent vibrant gradient
  static const LinearGradient accentViolet = LinearGradient(
    colors: [Color(0xFFC084FC), AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Electric Sunset
  static const LinearGradient electricSunset = LinearGradient(
    colors: [AppColors.accentPink, AppColors.accentAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Player Full-Screen Atmospheric Backdrop
  static const LinearGradient playerBackdrop = LinearGradient(
    colors: [
      Color(0xFF1E1435),
      Color(0xFF0D111A),
      AppColors.background,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Hero Card Gradient
  static const LinearGradient heroCard = LinearGradient(
    colors: [
      Color(0xFF1B2236),
      Color(0xFF0E1320),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Mini-player subtle glow
  static const LinearGradient miniPlayerGlow = LinearGradient(
    colors: [
      Color(0x2200F0FF),
      Color(0x00151A27),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glass card gradient
  static const LinearGradient glassCard = LinearGradient(
    colors: [
      Color(0x22FFFFFF),
      Color(0x0AFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Album overlay gradient for readability
  static const LinearGradient imageOverlay = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0xAA090B10),
      Color(0xF0090B10),
    ],
    stops: [0.3, 0.7, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
