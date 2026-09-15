import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story.dart';
import '../models/page_document.dart';
import '../models/coffre_item.dart';
import 'auth_service.dart';

class SyncService{
  static final _client = Supabase.instance.client;

  // ─── STORIES ───────────────────────────────────────────────

  static Future<void> syncStory(Story story) async {
    if (!AuthService.isLoggedIn) return;
    final userId = AuthService.currentUser!.id;

    await _client.from('stories').upsert({
      'id': story.id,
      'user_id': userId,
      'title': story.title,
      'genre': story.genre,
      'hook': story.hook,
      'progress': story.progress,
      'color': story.color.value,
      'last_edit': story.lastEdit,
      'blocks': story.blocks.map((b) => {
        'type': b.type.name,
        'value': b.value,
      }).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteStory(int id) async {
    if(!AuthService.isLoggedIn) return;
    await _client.from('stories').delete().eq('id', id);
  }

  // ─── PAGES ─────────────────────────────────────────────────

  static Future<void> syncPage(PageDocument page) async {
    if (!AuthService.isLoggedIn) return;
    final userId = AuthService.currentUser!.id;

    await _client.from('pages').upsert({
      'id': page.id,
      'user_id': userId,
      'content': page.content,
      'created_at': page.createdAt.toIso8601String(),
      'updated_at': page.updatedAt.toIso8601String(),
    });
  }

  static Future<void> deletePage(String id) async{
    if (!AuthService.isLoggedIn) return;
    await _client.from('pages').delete().eq('id', id);
  }

  // ─── COFFRE ────────────────────────────────────────────────

  static Future<void> syncCoffreItem(CoffreItem item) async {
    if (!AuthService.isLoggedIn) return;
    final userId = AuthService.currentUser!.id;

    await _client.from('coffre_items').upsert({
      'id': item.id,
      'user_id': userId,
      'type': item.type.name,
      'icon': item.icon,
      'title': item.title,
      'tags': item.tags,
      'date': item.date,
      'pinned': item.pinned,
      'color': item.color.value,
    });
  }

  static Future<void> deleteCoffreItem(int id) async {
    if (!AuthService.isLoggedIn) return;
    await _client.from('coffre_items').delete().eq('id', id);
  }
}