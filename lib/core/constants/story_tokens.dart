import 'package:flutter/material.dart';

class C {
  // === Couleurs DARK ===
  static const _darkBg = Color(0xFF0A1628);
  static const _darkSurface = Color(0xFF0F1F33);
  static const _darkSurface2 = Color(0xFF162840);
  static const _darkSurface3 = Color(0xFF1C3350);
  static const _darkText = Color(0xFFE0EEFA);
  static const _darkTextMuted = Color(0xFF5A7A99);
  static const _darkTextDim = Color(0xFF2E4A66);

  // === Couleurs LIGHT ===
  static const _lightBg = Color(0xFFF7FAFC);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightSurface2 = Color(0xFFF0F4F8);
  static const _lightSurface3 = Color(0xFFE2E8F0);
  static const _lightText = Color(0xFF0A1628);
  static const _lightTextMuted = Color(0xFF5A7A99);
  static const _lightTextDim = Color(0xFFA0AEC0);

  // === Couleurs d'accent (identiques dans les 2 modes) ===
  static const primary = Color(0xFF00D4FF);
  static const secondary = Color(0xFFFF6B35);
  static const accent = Color(0xFF7B2FF7);
  static const green = Color(0xFF00E5A0);

  // === État du thème (mutable) ===
  static bool isDark = true;

  // === Getters dynamiques ===
  static Color get bg => isDark ? _darkBg : _lightBg;
  static Color get surface => isDark ? _darkSurface : _lightSurface;
  static Color get surface2 => isDark ? _darkSurface2 : _lightSurface2;
  static Color get surface3 => isDark ? _darkSurface3 : _lightSurface3;
  static Color get text => isDark ? _darkText : _lightText;
  static Color get textMuted => isDark ? _darkTextMuted : _lightTextMuted;
  static Color get textDim => isDark ? _darkTextDim : _lightTextDim;
}