import 'package:hive/hive.dart';
import '../models/block_type.dart';

part 'library_record.g.dart';

/// Une entrée dans la bibliothèque personnelle de l'utilisateur.
/// Représente un personnage, un lieu, un ton... que l'utilisateur a créé
/// et qui peut être réutilisé pour assembler des amorces.
@HiveType(typeId: 6)
class LibraryRecord extends HiveObject {
  @HiveField(0)
  BlockType type;

  @HiveField(1)
  String value;

  LibraryRecord({required this.type, required this.value});
}
