import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assembled_block.dart';
import '../models/block_type.dart';
import '../models/story.dart';
import 'atelier_state.dart';
import 'story_provider.dart';

final atelierProvider = NotifierProvider<AtelierController, AtelierState>(
  AtelierController.new,
);

class AtelierController extends Notifier<AtelierState> {
  // ... (garder _initial et _surprises identiques)
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
    AssembledBlock(type: BlockType.objectif, value: 'Trouver quelqu\'un à qui dire aurevoir'),
    ],
    [
    AssembledBlock(type: BlockType.ton, value: 'Picaresque, drôle'),
    AssembledBlock(type: BlockType.personnage, value: 'Voleur qui ne peut voler que des souvenirs'),
    AssembledBlock(type: BlockType.lieu, value: "Marché aux puces de l'inconscient"),
    AssembledBlock(type: BlockType.obstacle, value: 'Les propriétaires veulent que leurs souvenirs reviennent'),
    ],
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
      assembled: [...state.assembled, AssembledBlock(type: type, value: '(appuyer pour définir)')],
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

  Future<void> generate() async {
    if (state.generating)return;
    state = state.copyWith(generating: true, generated: false, story: '');

    await Future.delayed(const Duration(milliseconds: 1800));

    state = state.copyWith(
      generating: false,
        generated: true,
        story:
        "Dans les ruelles brumeuses de Paris, l'inspecteur Moreau reçoit un mandat pour retrouver une héritière volatilisée. La pluie froide de janvier l'escorte jusqu'à l'hôtel particulier, où les secrets de famille se lisent dans chaque silence gêné…",
    );
  }

  void resetGenerated() {
    state = state.copyWith(generated: false, story: '', saved: false);
  }

  Future<void> saveAsStory() async {
    if (state.saved || !state.generated) return;

    final newStory = Story(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Nouvelle Amorce',
      genre: 'Non défini',
      blocks: List.from(state.assembled),
      progress: 0,
      color: const Color(0xFF7B2FF7),
      lastEdit: 'À l\'instant',
    );

    await ref.read(storyProvider.notifier).addStory(newStory);
    state = state.copyWith(saved: true);
  }
}