import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CoffreItemType { projet, note, idee }

@immutable
class CoffreItem {
  final int id;
  final CoffreItemType type;
  final String icon; // emoji/char
  final String title;
  final List<String> tags;
  final String date;
  final bool pinned;
  final Color color;

  const CoffreItem({
    required this.id,
    required this.type,
    required this.icon,
    required this.title,
    required this.tags,
    required this.date,
    required this.pinned,
    required this.color,
  });
}