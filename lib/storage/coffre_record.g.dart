// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coffre_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoffreRecordAdapter extends TypeAdapter<CoffreRecord> {
  @override
  final int typeId = 4;

  @override
  CoffreRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoffreRecord(
      id: fields[0] as int,
      type: fields[1] as CoffreItemType,
      icon: fields[2] as String,
      title: fields[3] as String,
      tags: (fields[4] as List).cast<String>(),
      date: fields[5] as String,
      pinned: fields[6] as bool,
      colorValue: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CoffreRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.pinned)
      ..writeByte(7)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoffreRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
