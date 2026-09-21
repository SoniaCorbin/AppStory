import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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

  /// Copie l'image dans le dossier privé de l'app et retourne le nouveau chemin
  static Future<String> _copyToPrivate(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final galleryDir = Directory(p.join(appDir.path, 'gallery'));
    if (!await galleryDir.exists()) {
      await galleryDir.create(recursive: true);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
    final destPath = p.join(galleryDir.path, fileName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> addItem(String imagePath, {String title = '', List<String> tags = const []}) async {
    // Copie l'image dans le dossier privé de l'app
    final privatePath = await _copyToPrivate(imagePath);

    final item = GalleryItem(
      imagePath: privatePath,
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
    // Supprime aussi le fichier image du dossier privé
    final item = _box.get(id);
    if (item != null) {
      try {
        final file = File(item.imagePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
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