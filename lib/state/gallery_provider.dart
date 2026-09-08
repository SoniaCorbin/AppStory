import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gallery_item.dart';

class GalleryNotifier extends StateNotifier<List<GalleryItem>> {
  final Box<GalleryItem> _box;

  GalleryNotifier(this._box) : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addItem(String imagePath, {String title = '', List<String> tags = const []}) async {
    final item = GalleryItem(
      imagePath: imagePath,
      title: title,
      tags: tags,
      createdAt: DateTime.now(),
    );
    await _box.put(item.id, item);
    _load();
  }

  Future<void> toggleFavorite(String id) async {
    final existing = _box.get(id);
    if (existing != null) {
      final updated = existing.copyWith(isFavorite: !existing.isFavorite);
      await _box.put(id, updated);
      _load();
    }
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    _load();
  }

  int get favoritesCount => state.where((i) => i.isFavorite).length;
}

final galleryBoxProvider = Provider<Box<GalleryItem>>((ref) {
  return Hive.box<GalleryItem>('gallery');
});

final galleryProvider =
StateNotifierProvider<GalleryNotifier, List<GalleryItem>>((ref) {
  return GalleryNotifier(ref.watch(galleryBoxProvider));
});