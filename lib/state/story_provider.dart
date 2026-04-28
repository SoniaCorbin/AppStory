import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/story.dart';
import '../storage/story_record.dart';

final storyProvider = StateNotifierProvider<StoryNotifier, List<Story>>((ref) {
  return StoryNotifier();
});

class StoryNotifier extends StateNotifier<List<Story>> {
  StoryNotifier() : super([]) {
    _loadFromHive();
  }

  // La boîte Hive ouverte dans main.dart
  Box<StoryRecord> get _box => Hive.box<StoryRecord>('stories');

  // CHARGER : On transforme les records Hive en modèles UI
  void _loadFromHive() {
    if (!_box.isOpen) return;
    final records = _box.values.toList();
    state = records.map((r) => r.toModel()).toList();
  }

  // SAUVEGARDER : On transforme le modèle UI en record Hive
  Future<void> addStory(Story story) async {
    // 1. Mettre à jour l'état UI
    state = [...state, story];

    // 2. Persister dans Hive
    final record = StoryRecord.fromModel(story);
    await _box.put(story.id, record);
  }

  // MISE À JOUR (Exemple)
  Future<void> updateStory(Story story) async {
    state = [
      for (final s in state)
        if (s.id == story.id) story else s
    ];
    await _box.put(story.id, StoryRecord.fromModel(story));
  }
}
