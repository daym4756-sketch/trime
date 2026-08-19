import 'package:flutter/material.dart';

class TrimeColors {
  TrimeColors._();

  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color primaryNavyDark = Color(0xFF172554);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFF60A5FA);
  static const Color accentBlue = Color(0xFF2563EB);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color starGold = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF97316);

  static const Color barberRed = Color(0xFFDC2626);
  static const Color barberBlue = Color(0xFF1E40AF);
  static const Color barberWhite = Color(0xFFFFFFFF);

  static const LinearGradient exclusiveGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rambutkuHeaderGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
