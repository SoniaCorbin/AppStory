import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/idea_block.dart';

class IdeaNotifier extends StateNotifier<List<IdeaBlock>> {
  final Box<IdeaBlock> _box;

  IdeaNotifier(this._box) : super([]) {
    _loadIdeas();
  }

  void _loadIdeas() {
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addIdea(String content, String category, List<String> tags) async {
    final idea = IdeaBlock(
      content: content,
      category: category,
      createdAt: DateTime.now(),
      tags: tags,
    );
    await _box.put(idea.id, idea);
    _loadIdeas();
  }

  Future<void> updateIdea(String id, String content, String category) async {
    final existing = _box.get(id);
    if (existing != null) {
      final updated = IdeaBlock(
        id: id,
        content: content,
        category: category,
        createdAt: existing.createdAt,
        tags: existing.tags,
      );
      await _box.put(id, updated);
      _loadIdeas();
    }
  }

  Future<void> deleteIdea(String id) async {
    await _box.delete(id);
    _loadIdeas();
  }

  IdeaBlock? pickRandom() {
    if (state.isEmpty) return null;
    final shuffled = [...state]..shuffle();
    return shuffled.first;
  }
}

final ideaBoxProvider = Provider<Box<IdeaBlock>>((ref) {
  return Hive.box<IdeaBlock>('ideas');
});

final ideaProvider =
StateNotifierProvider<IdeaNotifier, List<IdeaBlock>>((ref) {
  return IdeaNotifier(ref.watch(ideaBoxProvider));
});