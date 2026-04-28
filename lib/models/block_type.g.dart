// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockTypeAdapter extends TypeAdapter<BlockType> {
  @override
  final int typeId = 0;

  @override
  BlockType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BlockType.ton;
      case 1:
        return BlockType.personnage;
      case 2:
        return BlockType.lieu;
      case 3:
        return BlockType.objectif;
      case 4:
        return BlockType.obstacle;
      case 5:
        return BlockType.twist;
      case 6:
        return BlockType.fin;
      case 7:
        return BlockType.conflit;
      default:
        return BlockType.ton;
    }
  }

  @override
  void write(BinaryWriter writer, BlockType obj) {
    switch (obj) {
      case BlockType.ton:
        writer.writeByte(0);
        break;
      case BlockType.personnage:
        writer.writeByte(1);
        break;
      case BlockType.lieu:
        writer.writeByte(2);
        break;
      case BlockType.objectif:
        writer.writeByte(3);
        break;
      case BlockType.obstacle:
        writer.writeByte(4);
        break;
      case BlockType.twist:
        writer.writeByte(5);
        break;
      case BlockType.fin:
        writer.writeByte(6);
        break;
      case BlockType.conflit:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
