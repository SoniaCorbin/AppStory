// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coffre_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoffreItemTypeAdapter extends TypeAdapter<CoffreItemType> {
  @override
  final int typeId = 3;

  @override
  CoffreItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CoffreItemType.projet;
      case 1:
        return CoffreItemType.note;
      case 2:
        return CoffreItemType.idee;
      default:
        return CoffreItemType.projet;
    }
  }

  @override
  void write(BinaryWriter writer, CoffreItemType obj) {
    switch (obj) {
      case CoffreItemType.projet:
        writer.writeByte(0);
        break;
      case CoffreItemType.note:
        writer.writeByte(1);
        break;
      case CoffreItemType.idee:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoffreItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
