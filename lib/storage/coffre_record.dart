import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/coffre_item.dart';

part 'coffre_record.g.dart';

@HiveType(typeId: 4)
class CoffreRecord extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  CoffreItemType type;

  @HiveField(2)
  String icon;

  @HiveField(3)
  String title;

  @HiveField(4)
  List<String> tags;

  @HiveField(5)
  String date;

  @HiveField(6)
  bool pinned;

  @HiveField(7)
  int colorValue;

  CoffreRecord({
    required this.id,
    required this.type,
    required this.icon,
    required this.title,
    required this.tags,
    required this.date,
    required this.pinned,
    required this.colorValue,
  });

  factory CoffreRecord.fromModel(CoffreItem i) {
    return CoffreRecord(
      id: i.id,
      type: i.type,
      icon: i.icon,
      title: i.title,
      tags: i.tags,
      date: i.date,
      pinned: i.pinned,
      colorValue: i.color.toARGB32(),
    );
  }

  CoffreItem toModel() {
    return CoffreItem(
      id: id,
      type: type,
      icon: icon,
      title: title,
      tags: tags,
      date: date,
      pinned: pinned,
      color: Color(colorValue),
    );
  }
}
