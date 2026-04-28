import 'package:flutter/foundation.dart';

@immutable
class AgendaEvent {
  final DateTime date; // jour (on ignore l’heure)
  final String title;
  final String time; // "18:00"
  final String color; // emoji ou label (simple)
  final bool completed;

  const AgendaEvent({
    required this.date,
    required this.title,
    required this.time,
    required this.color,
    required this.completed,
  });
}