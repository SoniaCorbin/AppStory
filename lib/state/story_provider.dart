import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/story.dart';
import '../storage/story_record.dart';

final storyProvider =
    StateNotifierProvider<StoryNotifier, List<Story>>((ref) {
  return StoryNotifier();
});

class StoryNotifier extends StateNotifier<List<Story>> {
  StoryNotifier() : super([]) {
    _loadFromHive();
  }

  Box<StoryRecord> get _box => Hive.box<StoryRecord>('stories');

  void _loadFromHive() {
    if (!_box.isOpen) return;
    final records = _box.values.toList();
    state = records.map((r) => r.toModel()).toList();
  }

  Future<void> addStory(Story story) async {
    state = [...state, story];
    final record = StoryRecord.fromModel(story);
    await _box.put(story.id, record);
  }

  Future<void> updateStory(Story story) async {
    state = [
      for (final s in state)
        if (s.id == story.id) story else s
    ];
    await _box.put(story.id, StoryRecord.fromModel(story));
  }

  Future<void> deleteStory(int id) async {
    state = state.where((s) => s.id != id).toList();
    await _box.delete(id);
  }

  /// Renvoie l'histoire la plus récente, ou null si vide.
  Story? get latest {
    if (state.isEmpty) return null;
    return state.reduce((a, b) => a.id > b.id ? a : b);
  }
}
