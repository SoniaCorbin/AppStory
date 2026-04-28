import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/block_type.dart';
import '../models/story.dart';
import '../models/assembled_block.dart';

part 'story_record.g.dart';

@HiveType(typeId: 1)
class StoryRecord extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String genre;

  @HiveField(3)
  List<BlockRecord> blocks;

  @HiveField(4)
  int progress;

  @HiveField(5)
    int colorValue; // Color.value

  @HiveField(6)
  String lastEdit;

  StoryRecord({
    required this.id,
    required this.title,
    required this.genre,
    required this.blocks,
    required this.progress,
    required this.colorValue,
    required this.lastEdit,
  });

  factory StoryRecord.fromModel(Story s) {
    return StoryRecord(
      id: s.id,
      title: s.title,
      genre: s.genre,
      blocks: s.blocks.map((b) => BlockRecord.fromModel(b)).toList(),
      progress: s.progress,
      colorValue: s.color.toARGB32(),
      lastEdit: s.lastEdit,
    );
  }

  Story toModel() {
    return Story(
      id: id,
      title: title,
      genre: genre,
      blocks: blocks.map((b) => b.toModel()).toList(),
      progress: progress,
      color: Color(colorValue),
      lastEdit: lastEdit,
    );
  }
}

@HiveType(typeId: 2)
class BlockRecord {
  @HiveField(0)
  BlockType type;

  @HiveField(1)
  String value;

  BlockRecord({required this.type, required this.value});

  factory BlockRecord.fromModel(AssembledBlock b) {
    return BlockRecord(type: b.type, value: b.value);
  }

  AssembledBlock toModel() {
    return AssembledBlock(type: type, value: value);
  }
}
