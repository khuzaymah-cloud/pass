import 'package:flutter/material.dart';

/// Design system — Dark mode · Blue accent (#4361EE)
class AppColors {
  AppColors._();

  // ─── Accent ───
  static const accent = Color(0xFF4361EE);
  static const accentLight = Color(0xFF6B83F2);
  static const accentGlow = Color(0x204361EE);
  static const accentBorder = Color(0x404361EE);

  // ─── Dark backgrounds ───
  static const bgPrimary = Color(0xFF0A0A14);
  static const bgSecondary = Color(0xFF10101E);
  static const bgCard = Color(0xFF16162A);
  static const bgElevated = Color(0xFF1E1E36);

  // ─── Text ───
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9898B0);
  static const textHint = Color(0xFF4A4A64);

  // ─── Semantic ───
  static const error = Color(0xFFFF4D4D);
  static const warning = Color(0xFFFFB800);
  static const success = Color(0xFF00D68F);

  // ─── Legacy aliases (used across app) ───
  static const neonPrimary = accent;
  static const neonDim = accentLight;
  static const neonGlow = accentGlow;
  static const neonBorder = accentBorder;

  // ─── Light theme (for reference) ───
  static const lightBgPrimary = Color(0xFFF0F0F5);
  static const lightBgCard = Color(0xFFFFFFFF);
  static const lightNeonPrimary = Color(0xFF4361EE);
  static const lightTextPrimary = Color(0xFF000000);
  static const lightTextSecondary = Color(0xFF666680);

  // ─── Glass card ───
  static Color glassCardBg(bool isDark) => isDark
      ? bgCard.withValues(alpha: 0.72)
      : lightBgCard.withValues(alpha: 0.85);
}
