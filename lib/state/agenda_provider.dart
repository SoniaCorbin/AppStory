import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/agenda_event.dart';
import '../storage/agenda_record.dart';

final agendaProvider =
    StateNotifierProvider<AgendaNotifier, List<AgendaEvent>>((ref) {
  return AgendaNotifier();
});

class AgendaNotifier extends StateNotifier<List<AgendaEvent>> {
  AgendaNotifier() : super([]) {
    _loadFromHive();
  }

  Box<AgendaRecord> get _box => Hive.box<AgendaRecord>('agenda');

  void _loadFromHive() {
    if (!_box.isOpen) {
      // ignore: avoid_print
      print('[AgendaNotifier] _box not open, skipping load');
      return;
    }
    final records = _box.values.toList();
    // ignore: avoid_print
    print('[AgendaNotifier] Loaded ${records.length} events from Hive');
    state = records
        .map((r) => AgendaEvent(
              id: r.id,
              date: r.date,
              title: r.title,
              time: r.time,
              color: r.color,
              completed: r.completed,
            ))
        .toList();
  }

  Future<void> addEvent({
    required DateTime date,
    required String title,
    required String time,
    String color = '🟣',
  }) async {
    // Hive limite les clés à 32 bits → on utilise les secondes (pas les ms)
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final record = AgendaRecord(
      id: id,
      date: DateTime(date.year, date.month, date.day),
      title: title,
      time: time,
      color: color,
      completed: false,
    );
    await _box.put(id, record);
    // ignore: avoid_print
    print('[AgendaNotifier] Saved event "$title" (id=$id), box has ${_box.length} entries');
    // Recharge depuis Hive pour s'assurer que tout est en sync
    _loadFromHive();
  }

  Future<void> updateEvent({
    required int id,
    required DateTime date,
    required String title,
    required String time,
    required String color,
  }) async {
    final existing = _box.get(id);
    if (existing == null) return;
    existing.date = DateTime(date.year, date.month, date.day);
    existing.title = title;
    existing.time = time;
    existing.color = color;
    await existing.save();
    _loadFromHive();
  }

  Future<void> deleteEvent(int id) async {
    await _box.delete(id);
    _loadFromHive();
  }

  Future<void> toggleComplete(int id) async {
    final record = _box.get(id);
    if (record == null) return;
    record.completed = !record.completed;
    await record.save();
    _loadFromHive();
  }
}
