// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GalleryItemAdapter extends TypeAdapter<GalleryItem> {
  @override
  final int typeId = 8;

  @override
  GalleryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GalleryItem(
      id: fields[0] as String?,
      imagePath: fields[1] as String,
      title: fields[2] as String,
      tags: (fields[3] as List).cast<String>(),
      isFavorite: fields[4] as bool,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GalleryItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.isFavorite)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
