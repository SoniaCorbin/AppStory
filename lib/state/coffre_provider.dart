import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/coffre_item.dart';
import '../storage/coffre_record.dart';

final coffreProvider =
    StateNotifierProvider<CoffreNotifier, List<CoffreItem>>((ref) {
  return CoffreNotifier();
});

class CoffreNotifier extends StateNotifier<List<CoffreItem>> {
  CoffreNotifier() : super([]) {
    _loadFromHive();
  }

  Box<CoffreRecord> get _box => Hive.box<CoffreRecord>('coffre');

  void _loadFromHive() {
    if (!_box.isOpen) return;
    final records = _box.values.toList();
    state = records.map((r) => r.toModel()).toList();
  }

  Future<void> addItem(CoffreItem item) async {
    state = [...state, item];
    await _box.put(item.id, CoffreRecord.fromModel(item));
  }

  Future<void> updateItem(CoffreItem item) async {
    state = [
      for (final i in state)
        if (i.id == item.id) item else i
    ];
    await _box.put(item.id, CoffreRecord.fromModel(item));
  }

  Future<void> deleteItem(int id) async {
    state = state.where((i) => i.id != id).toList();
    await _box.delete(id);
  }

  Future<void> togglePin(int id) async {
    final item = state.firstWhere((i) => i.id == id);
    await updateItem(item.copyWith(pinned: !item.pinned));
  }

  /// Crée un nouvel item avec des valeurs par défaut.
  static CoffreItem buildNew({
    required CoffreItemType type,
    required String title,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    // Hive limite les clés à 32 bits → on utilise les secondes (pas les ms)
    final id = now.millisecondsSinceEpoch ~/ 1000;

    String icon;
    Color color;
    switch (type) {
      case CoffreItemType.projet:
        icon = '📖';
        color = const Color(0xFF00D4FF);
        break;
      case CoffreItemType.note:
        icon = '🖊';
        color = const Color(0xFF00E5A0);
        break;
      case CoffreItemType.idee:
        icon = '💡';
        color = const Color(0xFFFFD700);
        break;
    }

    final months = const [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sept', 'oct', 'nov', 'déc'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]}';

    return CoffreItem(
      id: id,
      type: type,
      icon: icon,
      title: title,
      tags: tags,
      date: dateStr,
      pinned: false,
      color: color,
    );
  }
}
