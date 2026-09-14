import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'page_document.g.dart';

@HiveType(typeId: 9)
class PageDocument extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  PageDocument({
    String? id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  PageDocument copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return PageDocument(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}