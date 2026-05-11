// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LibraryRecordAdapter extends TypeAdapter<LibraryRecord> {
  @override
  final int typeId = 6;

  @override
  LibraryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LibraryRecord(
      type: fields[0] as BlockType,
      value: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LibraryRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
