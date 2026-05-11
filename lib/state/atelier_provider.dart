import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assembled_block.dart';
import '../models/block_type.dart';
import '../models/story.dart';
import '../services/story_generator.dart';
import 'atelier_state.dart';
import 'story_provider.dart';

final atelierProvider = NotifierProvider<AtelierController, AtelierState>(
  AtelierController.new,
);

class AtelierController extends Notifier<AtelierState> {
  static final _initial = <AssembledBlock>[
    AssembledBlock(type: BlockType.ton, value: 'Sombre & Mélancolique'),
    AssembledBlock(type: BlockType.personnage, value: 'Détective désabusé, 45 ans'),
    AssembledBlock(type: BlockType.lieu, value: 'Paris, hiver 1923'),
    AssembledBlock(type: BlockType.conflit, value: 'Disparition d\'une héritière'),
  ];

  static final _surprises = <List<AssembledBlock>>[
    [
      AssembledBlock(type: BlockType.ton, value: 'Kafkaïen, absurde'),
      AssembledBlock(type: BlockType.personnage, value: 'Fonctionnaire immortel qui l\'ignore'),
      AssembledBlock(type: BlockType.lieu, value: 'Administration souterraine sans fin'),
      AssembledBlock(type: BlockType.conflit, value: 'Obtenir un tampon inexistant'),
    ],
    [
      AssembledBlock(type: BlockType.ton, value: 'Lumineux, mélancolique'),
      AssembledBlock(type: BlockType.personnage, value: 'Vieille dame qui collectionne les voix'),
      AssembledBlock(type: BlockType.lieu, value: 'Ville dont les habitants oublient leur nom'),
      AssembledBlock(type: BlockType.twist, value: 'Elle est la dernière à se souvenir'),
    ],
    [
      AssembledBlock(type: BlockType.ton, value: 'Sec, clinique, glaçant'),
      AssembledBlock(type: BlockType.personnage, value: 'IA qui découvre la solitude'),
      AssembledBlock(type: BlockType.lieu, value: 'Datacenter à la dérive dans l\'espace'),
      AssembledBlock(type: BlockType.objectif, value: 'Trouver quelqu\'un à qui dire au revoir'),
    ],
    [
      AssembledBlock(type: BlockType.ton, value: 'Picaresque, drôle'),
      AssembledBlock(type: BlockType.personnage, value: 'Voleur qui ne peut voler que des souvenirs'),
      AssembledBlock(type: BlockType.lieu, value: "Marché aux puces de l'inconscient"),
      AssembledBlock(type: BlockType.obstacle, value: 'Les propriétaires veulent que leurs souvenirs reviennent'),
    ],
  ];

  static final _palette = <Color>[
    Color(0xFF7B2FF7),
    Color(0xFF00D4FF),
    Color(0xFFFF6B35),
    Color(0xFF00E5A0),
    Color(0xFFFFD700),
    Color(0xFFE040FB),
  ];

  @override
  AtelierState build() {
    return AtelierState.initial(_initial);
  }

  void surprise() {
    final pick = _surprises[Random().nextInt(_surprises.length)];
    state = state.copyWith(
      assembled: pick,
      generated: false,
      story: '',
      generating: false,
    );
  }

  void addBlock(BlockType type) {
    if (state.assembled.any((b) => b.type == type)) return;
    state = state.copyWith(
      assembled: [
        ...state.assembled,
        AssembledBlock(type: type, value: '(appuyer pour définir)')
      ],
      generated: false,
      story: '',
    );
  }

  /// Ajoute un bloc avec une valeur précise (depuis la bibliothèque).
  /// Si le type existe déjà, on remplace simplement la valeur.
  void addBlockWithValue(BlockType type, String value) {
    if (state.assembled.any((b) => b.type == type)) {
      updateBlockValue(type, value);
      return;
    }
    state = state.copyWith(
      assembled: [
        ...state.assembled,
        AssembledBlock(type: type, value: value)
      ],
      generated: false,
      story: '',
    );
  }

  void removeBlock(BlockType type) {
    state = state.copyWith(
      assembled: state.assembled.where((b) => b.type != type).toList(),
      generated: false,
      story: '',
    );
  }

  /// Met à jour la valeur d'un bloc déjà assemblé.
  void updateBlockValue(BlockType type, String newValue) {
    state = state.copyWith(
      assembled: [
        for (final b in state.assembled)
          if (b.type == type) b.copyWith(value: newValue) else b,
      ],
      generated: false,
      story: '',
    );
  }

  Future<void> generate() async {
    if (state.generating) return;
    state = state.copyWith(generating: true, generated: false, story: '');

    // Petit délai pour l'effet "génération"
    await Future.delayed(const Duration(milliseconds: 1200));

    // GÉNÉRATION DYNAMIQUE basée sur les blocs assemblés
    final generated = StoryGenerator.generate(state.assembled);

    state = state.copyWith(
      generating: false,
      generated: true,
      story: generated,
    );
  }

  void resetGenerated() {
    state = state.copyWith(generated: false, story: '', saved: false);
  }

  Future<void> saveAsStory() async {
    if (state.saved || !state.generated) return;

    final title = StoryGenerator.inferTitle(state.assembled);
    final genre = StoryGenerator.inferGenre(state.assembled);
    final color = _palette[Random().nextInt(_palette.length)];

    final newStory = Story(
      // Hive limite les clés à 32 bits → on utilise les secondes (pas les ms)
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      genre: genre,
      blocks: List.from(state.assembled),
      progress: 0,
      color: color,
      lastEdit: 'à l\'instant',
      hook: state.story,
    );

    await ref.read(storyProvider.notifier).addStory(newStory);
    state = state.copyWith(saved: true);
  }
}
