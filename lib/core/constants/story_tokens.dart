import 'package:flutter/material.dart';

class C {
  // === Couleurs DARK ===
  static const _darkBg        = Color(0xFF080F1E);
  static const _darkSurface   = Color(0xFF111D2E);
  static const _darkSurface2  = Color(0xFF1A2B40);
  static const _darkSurface3  = Color(0xFF233350);
  static const _darkText      = Color(0xFFEAF4FF);
  static const _darkTextMuted = Color(0xFF8BAFC9);
  static const _darkTextDim   = Color(0xFF4D6E8A);

  // === Couleurs LIGHT ===
  static const _lightBg        = Color(0xFFDDE6EF);
  static const _lightSurface   = Color(0xFFF5F8FB);
  static const _lightSurface2  = Color(0xFFE8EEF4);
  static const _lightSurface3  = Color(0xFFD0DAE6);
  static const _lightText      = Color(0xFF0D1B2A);
  static const _lightTextMuted = Color(0xFF2D4A66);
  static const _lightTextDim   = Color(0xFF5A7A99);

  // === Couleurs d'accent (variantes dark/light) ===
  static const _darkPrimary    = Color(0xFF00D4FF);
  static const _lightPrimary   = Color(0xFF0099CC);

  static const _darkAccent     = Color(0xFF9B5FFF);
  static const _lightAccent    = Color(0xFF6020D0);

  static const _darkSecondary  = Color(0xFFFF6B35);
  static const _lightSecondary = Color(0xFFD94F1A);

  static const _darkGreen      = Color(0xFF00C87A);
  static const _lightGreen     = Color(0xFF007A4A);

  // === État du thème (mutable) ===
  static bool isDark = true;

  // === Getters dynamiques ===
  static Color get bg         => isDark ? _darkBg         : _lightBg;
  static Color get surface    => isDark ? _darkSurface    : _lightSurface;
  static Color get surface2   => isDark ? _darkSurface2   : _lightSurface2;
  static Color get surface3   => isDark ? _darkSurface3   : _lightSurface3;
  static Color get text       => isDark ? _darkText       : _lightText;
  static Color get textMuted  => isDark ? _darkTextMuted  : _lightTextMuted;
  static Color get textDim    => isDark ? _darkTextDim    : _lightTextDim;
  static Color get primary    => isDark ? _darkPrimary    : _lightPrimary;
  static Color get accent     => isDark ? _darkAccent     : _lightAccent;
  static Color get secondary  => isDark ? _darkSecondary  : _lightSecondary;
  static Color get green      => isDark ? _darkGreen      : _lightGreen;
}