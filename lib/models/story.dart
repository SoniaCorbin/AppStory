import 'package:flutter/material.dart';
import 'assembled_block.dart';

class Story {
  final int id;
  final String title;
  final String genre;
  final List<AssembledBlock> blocks;
  final int progress; // 0..100
  final Color color;
  final String lastEdit;

  const Story({
    required this.id,
    required this.title,
    required this.genre,
    required this.blocks,
    required this.progress,
    required this.color,
    required this.lastEdit,
  });

  Story copyWith({
    int? id,
    String? title,
    String? genre,
    List<AssembledBlock>? blocks,
    int? progress,
    Color? color,
    String? lastEdit,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      blocks: blocks ?? this.blocks,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      lastEdit: lastEdit ?? this.lastEdit,
    );
  }
}