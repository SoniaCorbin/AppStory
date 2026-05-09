// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgendaRecordAdapter extends TypeAdapter<AgendaRecord> {
  @override
  final int typeId = 5;

  @override
  AgendaRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgendaRecord(
      id: fields[0] as int,
      date: fields[1] as DateTime,
      title: fields[2] as String,
      time: fields[3] as String,
      color: fields[4] as String,
      completed: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AgendaRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgendaRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
