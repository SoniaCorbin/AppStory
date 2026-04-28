import 'package:flutter/material.dart';
import 'block_type.dart';

class Story {
  final int id;
  final String title;
  final String genre;
  final List<BlockType> blocks;
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
}