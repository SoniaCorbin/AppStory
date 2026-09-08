// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaBlockAdapter extends TypeAdapter<IdeaBlock> {
  @override
  final int typeId = 7;

  @override
  IdeaBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaBlock(
      id: fields[0] as String?,
      content: fields[1] as String,
      category: fields[2] as String,
      createdAt: fields[3] as DateTime,
      tags: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, IdeaBlock obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
