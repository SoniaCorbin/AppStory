import 'package:flutter/material.dart';
import '../constants/story_tokens.dart';

class StoryText {
  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color color = C.textMuted,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'DMMono',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = C.text,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: 'DMSans',
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
    );
  }

  static TextStyle serif({
    double size = 22,
    FontWeight weight = FontWeight.w700,
    Color color = C.text,
    FontStyle style = FontStyle.normal,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
      height: height,
    );
  }
}