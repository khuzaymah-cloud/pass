import 'package:flutter/material.dart';

/// Design system color palette — iOS Glass · Black · Neon Green
class AppColors {
  AppColors._();

  // ─── Dark theme ───
  static const bgPrimary = Color(0xFF000000);
  static const bgSecondary = Color(0xFF0D0D0D);
  static const bgCard = Color(0xFF111111);
  static const bgElevated = Color(0xFF1A1A1A);

  static const neonPrimary = Color(0xFF00FF88);
  static const neonDim = Color(0xFF00CC6A);
  static const neonGlow = Color(0x2000FF88);
  static const neonBorder = Color(0x4000FF88);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFAAAAAA);
  static const textHint = Color(0xFF555555);

  static const error = Color(0xFFFF4D4D);
  static const warning = Color(0xFFFFB800);
  static const success = neonPrimary;

  // ─── Light theme ───
  static const lightBgPrimary = Color(0xFFF0F0F0);
  static const lightBgCard = Color(0xFFFFFFFF);
  static const lightNeonPrimary = Color(0xFF007A40);
  static const lightTextPrimary = Color(0xFF000000);
  static const lightTextSecondary = Color(0xFF333333);

  // ─── Glass card ───
  static Color glassCardBg(bool isDark) =>
      isDark ? bgCard.withOpacity(0.72) : lightBgCard.withOpacity(0.85);
}
