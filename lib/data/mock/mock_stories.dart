import 'package:flutter/material.dart';
import '../../models/block_type.dart';
import '../../models/story.dart';

final recentStories = <Story>[
  Story(
    id: 1,
    title: 'Les Ombres de Versailles',
    genre: 'Thriller historique',
    blocks: [BlockType.personnage, BlockType.lieu, BlockType.conflit, BlockType.twist],
    progress: 68,
    color: const Color(0xFF00D4FF),
    lastEdit: 'il y a 2h',
  ),
  Story(
    id: 2,
    title: 'Le Dernier Signal',
    genre: 'Sci-fi dystopique',
    blocks: [BlockType.personnage, BlockType.objectif, BlockType.obstacle],
    progress: 32,
    color: const Color(0xFF7B2FF7),
    lastEdit: 'hier',
  ),
  Story(
    id: 3,
    title: 'Un Café à Minuit',
    genre: 'Romance contemporaine',
    blocks: [BlockType.ton, BlockType.personnage, BlockType.lieu, BlockType.fin],
    progress: 91,
    color: const Color(0xFFFF6B35),
    lastEdit: 'il y a 3j',
  ),
];