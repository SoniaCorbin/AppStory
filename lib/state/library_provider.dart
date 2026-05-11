import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/block_type.dart';
import '../storage/library_record.dart';

/// Modèle UI pour une entrée de bibliothèque.
class LibraryEntry {
  final int key;
  final BlockType type;
  final String value;

  const LibraryEntry({
    required this.key,
    required this.type,
    required this.value,
  });
}

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, List<LibraryEntry>>((ref) {
  return LibraryNotifier();
});

class LibraryNotifier extends StateNotifier<List<LibraryEntry>> {
  LibraryNotifier() : super([]) {
    _load();
  }

  Box<LibraryRecord> get _box => Hive.box<LibraryRecord>('library');

  void _load() {
    if (!_box.isOpen) return;
    final entries = <LibraryEntry>[];
    for (final key in _box.keys) {
      final r = _box.get(key);
      if (r != null) {
        entries.add(LibraryEntry(
          key: key as int,
          type: r.type,
          value: r.value,
        ));
      }
    }
    state = entries;
  }

  /// Retourne toutes les entrées d'un type donné.
  List<LibraryEntry> forType(BlockType type) {
    return state.where((e) => e.type == type).toList();
  }

  /// Ajoute une nouvelle entrée et retourne son id.
  Future<int> add(BlockType type, String value) async {
    final record = LibraryRecord(type: type, value: value);
    final key = await _box.add(record);
    _load();
    return key;
  }

  /// Modifie la valeur d'une entrée existante.
  Future<void> update(int key, String value) async {
    final record = _box.get(key);
    if (record == null) return;
    record.value = value;
    await record.save();
    _load();
  }

  /// Supprime une entrée.
  Future<void> delete(int key) async {
    await _box.delete(key);
    _load();
  }
}
