import 'package:flutter/foundation.dart';

@immutable
class AgendaEvent {
  final int id;
  final DateTime date; // jour (on ignore l'heure)
  final String title;
  final String time; // "18:00"
  final String color; // emoji ou label (simple)
  final bool completed;

  const AgendaEvent({
    this.id = 0,
    required this.date,
    required this.title,
    required this.time,
    required this.color,
    required this.completed,
  });

  AgendaEvent copyWith({
    int? id,
    DateTime? date,
    String? title,
    String? time,
    String? color,
    bool? completed,
  }) {
    return AgendaEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      time: time ?? this.time,
      color: color ?? this.color,
      completed: completed ?? this.completed,
    );
  }
}
