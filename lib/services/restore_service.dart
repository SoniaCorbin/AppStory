import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/assembled_block.dart';
import '../models/block_type.dart';
import '../models/coffre_item.dart';
import '../models/page_document.dart';
import '../models/story.dart';
import '../storage/coffre_record.dart';
import '../storage/story_record.dart';
import 'sync_service.dart';

class RestoreService {
  /// Restaure toutes les données depuis Supabase vers Hive.
  /// À appeler après un login réussi sur un nouvel appareil.
  static Future<void> restoreAll() async {
    await Future.wait([
      _restoreStories(),
      _restorePages(),
      _restoreCoffre(),
    ]);
  }

  static Future<void> _restoreStories() async {
    final box = Hive.box<StoryRecord>('stories');
    final rows = await SyncService.fetchStories();

    for (final row in rows) {
      // Ne pas écraser si déjà présent localement
      if (box.containsKey(row['id'])) continue;

      final blocksJson = (row['blocks'] as List?) ?? [];
      final blocks = blocksJson.map((b) {
        final typeName = b['type'] as String;
        final type = BlockType.values.firstWhere(
              (t) => t.name == typeName,
          orElse: () => BlockType.ton,
        );
        return AssembledBlock(type: type, value: b['value'] as String);
      }).toList();

      final story = Story(
        id: row['id'] as int,
        title: row['title'] as String,
        genre: row['genre'] as String? ?? '',
        hook: row['hook'] as String? ?? '',
        progress: row['progress'] as int? ?? 0,
        color: Color(row['color'] as int? ?? 0xFF7B2FF7),
        lastEdit: row['last_edit'] as String? ?? '',
        blocks: blocks,
      );

      await box.put(story.id, StoryRecord.fromModel(story));
    }
  }

  static Future<void> _restorePages() async {
    final box = Hive.box<PageDocument>('pages');
    final rows = await SyncService.fetchPages();

    for (final row in rows) {
      if (box.containsKey(row['id'])) continue;

      final page = PageDocument(
        id: row['id'] as String,
        title: row['title'] as String,
        content: row['content'] as String? ?? '',
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );

      await box.put(page.id, page);
    }
  }

  static Future<void> _restoreCoffre() async {
    final box = Hive.box<CoffreRecord>('coffre');
    final rows = await SyncService.fetchCoffreItems();

    for (final row in rows) {
      if (box.containsKey(row['id'])) continue;

      final typeName = row['type'] as String;
      final type = CoffreItemType.values.firstWhere(
            (t) => t.name == typeName,
        orElse: () => CoffreItemType.note,
      );

      final tagsJson = (row['tags'] as List?) ?? [];
      final tags = tagsJson.map((t) => t as String).toList();

      final item = CoffreItem(
        id: row['id'] as int,
        type: type,
        icon: row['icon'] as String? ?? '',
        title: row['title'] as String,
        tags: tags,
        date: row['date'] as String? ?? '',
        pinned: row['pinned'] as bool? ?? false,
        color: Color(row['color'] as int? ?? 0xFF007A4A),
      );

      await box.put(item.id, CoffreRecord.fromModel(item));
    }
  }
}