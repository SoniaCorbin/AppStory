import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assembled_block.dart';
import '../models/block_type.dart';

class StoryTemplate {
  final String id;
  final String title;
  final String description;
  final String genre;
  final String authorName;
  final bool isOfficial;
  final int downloads;
  final List<AssembledBlock> blocks;
  final DateTime createdAt;

  const StoryTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.authorName,
    required this.isOfficial,
    required this.downloads,
    required this.blocks,
    required this.createdAt,
  });

  factory StoryTemplate.fromMap(Map<String, dynamic> map) {
    final rawBlocks = map['blocks'] as List<dynamic>;
    final blocks = rawBlocks.map((b) {
      final block = b as Map<String, dynamic>;
      return AssembledBlock(
        type: BlockType.values.firstWhere(
              (t) => t.name == block['type'],
          orElse: () => BlockType.ton,
        ),
        value: block['value'] as String? ?? '',
      );
    }).toList();

    return StoryTemplate(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      genre: map['genre'] as String,
      authorName: map['author_name'] as String,
      isOfficial: map['is_official'] as bool,
      downloads: map['downloads'] as int,
      blocks: blocks,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class TemplateService {
  static final _client = Supabase.instance.client;

  static Future<List<StoryTemplate>> getTemplates({String? genre}) async {
    final response = genre != null && genre != 'Tous'
        ? await _client
        .from('templates')
        .select()
        .eq('genre', genre)
        .order('downloads', ascending: false)
        .limit(50)
        : await _client
        .from('templates')
        .select()
        .order('downloads', ascending: false)
        .limit(50);

    return (response as List)
        .map((e) => StoryTemplate.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> incrementDownloads(String templateId) async {
    await _client.rpc('increment_template_downloads',
        params: {'template_id': templateId});
  }

  static Future<void> publishTemplate({
    required String title,
    required String description,
    required String genre,
    required List<AssembledBlock> blocks,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final name = user.userMetadata?['name'] as String? ?? 'Écrivain';

    await _client.from('templates').insert({
      'title': title,
      'description': description,
      'genre': genre,
      'author_id': user.id,
      'author_name': name,
      'is_official': false,
      'blocks': blocks
          .map((b) => {'type': b.type.name, 'value': b.value})
          .toList(),
    });
  }
}