import 'package:hive/hive.dart';
import '../models/agenda_event.dart';

part 'agenda_record.g.dart';

@HiveType(typeId: 5)
class AgendaRecord extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String title;

  @HiveField(3)
  String time;

  @HiveField(4)
  String color;

  @HiveField(5)
  bool completed;

  AgendaRecord({
    required this.id,
    required this.date,
    required this.title,
    required this.time,
    required this.color,
    required this.completed,
  });

  AgendaEvent toModel() {
    return AgendaEvent(
      date: date,
      title: title,
      time: time,
      color: color,
      completed: completed,
    );
  }
}
