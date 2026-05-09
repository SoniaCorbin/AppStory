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
    if (!_box.isOpen) return;
    final records = _box.values.toList();
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
    final id = DateTime.now().millisecondsSinceEpoch;
    final record = AgendaRecord(
      id: id,
      date: DateTime(date.year, date.month, date.day),
      title: title,
      time: time,
      color: color,
      completed: false,
    );
    await _box.put(id, record);
    state = [...state, record.toModel().copyWith(id: id)];
  }

  Future<void> deleteEvent(int id) async {
    state = state.where((e) => e.id != id).toList();
    await _box.delete(id);
  }

  Future<void> toggleComplete(int id) async {
    final record = _box.get(id);
    if (record == null) return;
    record.completed = !record.completed;
    await record.save();
    _loadFromHive();
  }
}
