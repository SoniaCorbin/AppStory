import 'package:flutter/material.dart';
import '../constants/story_tokens.dart';

ThemeData buildStoryTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: C.primary,
      secondary: C.secondary,
      surface: C.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );
}