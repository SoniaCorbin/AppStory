import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'coffre_item.g.dart';

@HiveType(typeId: 3)
enum CoffreItemType {
  @HiveField(0)
  projet,
  @HiveField(1)
  note,
  @HiveField(2)
  idee,
}

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

  CoffreItem copyWith({
    int? id,
    CoffreItemType? type,
    String? icon,
    String? title,
    List<String>? tags,
    String? date,
    bool? pinned,
    Color? color,
  }) {
    return CoffreItem(
      id: id ?? this.id,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      pinned: pinned ?? this.pinned,
      color: color ?? this.color,
    );
  }
}
