import '../../models/agenda_event.dart';

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

final agendaEvents = <AgendaEvent>[
  AgendaEvent(date: _d(2026, 4, 27), title: 'Écrire 500 mots', time: '18:00', color: '🟣', completed: false),
  AgendaEvent(date: _d(2026, 4, 27), title: 'Relire chapitre 2', time: '20:30', color: '🟠', completed: true),
  AgendaEvent(date: _d(2026, 4, 29), title: 'Brainstorm twist', time: '19:00', color: '🟡', completed: false),
  AgendaEvent(date: _d(2026, 5, 2), title: 'Plan chapitre 3', time: '17:30', color: '🟢', completed: false),
];