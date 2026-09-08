import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'idea_block.g.dart';

@HiveType(typeId: 7)
class IdeaBlock extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final List<String> tags;

  IdeaBlock({
    String? id,
    required this.content,
    this.category = 'Général',
    required this.createdAt,
    this.tags = const [],
  }) : id = id ?? const Uuid().v4();
}
