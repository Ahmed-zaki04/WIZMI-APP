import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryDark = Color(0xFF27AE60);
  static const Color primaryLight = Color(0xFF58D68D);

  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141829);
  static const Color surface2 = Color(0xFF1A2038);
  static const Color surfaceLight = Color(0xFF212840);

  static const Color amber = Color(0xFFF39C12);
  static const Color amberLight = Color(0xFFFAD7A0);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF2ECC71);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textMuted = Color(0xFF4A5568);

  static const Color border = Color(0xFF2D3550);
  static const Color divider = Color(0xFF1E2640);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
  );

  static const darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E1A), Color(0xFF141829)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2038), Color(0xFF0D1225)],
  );
}
