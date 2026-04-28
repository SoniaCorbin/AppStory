import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'block_type.g.dart';

@HiveType(typeId: 0)
enum BlockType {
  @HiveField(0)
  ton,
  @HiveField(1)
  personnage,
  @HiveField(2)
  lieu,
  @HiveField(3)
  objectif,
  @HiveField(4)
  obstacle,
  @HiveField(5)
  twist,
  @HiveField(6)
  fin,
  @HiveField(7)
  conflit,
}

extension BlockTypeX on BlockType {
  String get label => switch (this) {
    BlockType.ton => 'Ton',
    BlockType.personnage => 'Personnage',
    BlockType.lieu => 'Lieu',
    BlockType.objectif => 'Objectif',
    BlockType.obstacle => 'Obstacle',
    BlockType.twist => 'Twist',
    BlockType.fin => 'Fin',
    BlockType.conflit => 'Conflit',
  };

  String get icon => switch (this) {
    BlockType.ton => '🎭',
    BlockType.personnage => '👤',
    BlockType.lieu => '📍',
    BlockType.objectif => '🎯',
    BlockType.obstacle => '⚡',
    BlockType.twist => '🌀',
    BlockType.fin => '🏁',
    BlockType.conflit => '⚔️',
  };

  String get desc => switch (this) {
    BlockType.ton => "L'atmosphère du récit",
    BlockType.personnage => "Qui peuple l'histoire",
    BlockType.lieu => "Où tout se passe",
    BlockType.objectif => "Ce qu'on veut atteindre",
    BlockType.obstacle => "Ce qui bloque la route",
    BlockType.twist => "Le retournement inattendu",
    BlockType.fin => "Comment ça se termine",
    BlockType.conflit => "La tension centrale",
  };

  Color get color => switch (this) {
    BlockType.ton => const Color(0xFF00D4FF),
    BlockType.personnage => const Color(0xFFFF6B35),
    BlockType.lieu => const Color(0xFF00E5A0),
    BlockType.objectif => const Color(0xFF7B2FF7),
    BlockType.obstacle => const Color(0xFFFF4466),
    BlockType.twist => const Color(0xFFFFD700),
    BlockType.fin => const Color(0xFFFF6B35),
    BlockType.conflit => const Color(0xFFE040FB),
  };

  static List<BlockType> get all => BlockType.values;
}