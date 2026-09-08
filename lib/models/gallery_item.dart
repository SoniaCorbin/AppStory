import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'gallery_item.g.dart';

@HiveType(typeId: 8)
class GalleryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath; // chemin local sur le téléphone

  @HiveField(2)
  final String title;

  @HiveField(3)
  final List<String> tags;

  @HiveField(4)
  final bool isFavorite;

  @HiveField(5)
  final DateTime createdAt;

  GalleryItem({
    String? id,
    required this.imagePath,
    this.title = '',
    this.tags = const [],
    this.isFavorite = false,
    required this.createdAt,
  }) : id = id ?? const Uuid().v4();

  GalleryItem copyWith({
    String? imagePath,
    String? title,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return GalleryItem(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
