import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/page_document.dart';

class PagesNotifier extends StateNotifier<List<PageDocument>> {
  final Box<PageDocument> _box;

  PagesNotifier(this._box) : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addPage(String title, String content) async {
    final now = DateTime.now();
    final page = PageDocument(
      title: title.isEmpty ? 'Sans titre' : title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(page.id, page);
    _load();
  }

  Future<void> updatePage(String id, String title, String content) async {
    final existing = _box.get(id);
    if (existing != null) {
      final updated = existing.copyWith(
        title: title.isEmpty ? 'Sans titre' : title,
        content: content,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, updated);
      _load();
    }
  }

  Future<void> deletePage(String id) async {
    await _box.delete(id);
    _load();
  }
}

final pagesBoxProvider = Provider<Box<PageDocument>>((ref) {
  return Hive.box<PageDocument>('pages');
});

final pagesProvider =
    StateNotifierProvider<PagesNotifier, List<PageDocument>>((ref) {
  return PagesNotifier(ref.watch(pagesBoxProvider));
});