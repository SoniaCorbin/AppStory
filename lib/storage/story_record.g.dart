// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryRecordAdapter extends TypeAdapter<StoryRecord> {
  @override
  final int typeId = 1;

  @override
  StoryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryRecord(
      id: fields[0] as int,
      title: fields[1] as String,
      genre: fields[2] as String,
      blocks: (fields[3] as List).cast<BlockRecord>(),
      progress: fields[4] as int,
      colorValue: fields[5] as int,
      lastEdit: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StoryRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.genre)
      ..writeByte(3)
      ..write(obj.blocks)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.lastEdit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BlockRecordAdapter extends TypeAdapter<BlockRecord> {
  @override
  final int typeId = 2;

  @override
  BlockRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlockRecord(
      type: fields[0] as BlockType,
      value: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BlockRecord obj) {
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
      other is BlockRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
