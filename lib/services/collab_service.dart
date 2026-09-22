import 'package:supabase_flutter/supabase_flutter.dart';

class StoryEdit {
  final String id;
  final int storyId;
  final int blockIndex;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const StoryEdit({
    required this.id,
    required this.storyId,
    required this.blockIndex,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory StoryEdit.fromMap(Map<String, dynamic> map) {
    return StoryEdit(
      id: map['id'] as String,
      storyId: map['story_id'] as int,
      blockIndex: map['block_index'] as int,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class CollabService {
  static final _client = Supabase.instance.client;

  static String get _currentUserId =>
      _client.auth.currentUser?.id ?? '';

  static Future<void> broadcastEdit({
    required int storyId,
    required int blockIndex,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final name = user.userMetadata?['name'] as String? ?? 'Écrivain';

    await _client.from('story_edits').insert({
      'story_id': storyId,
      'block_index': blockIndex,
      'user_id': user.id,
      'user_name': name,
      'content': content,
    });
  }

  static RealtimeChannel subscribeToEdits({
    required int storyId,
    required void Function(StoryEdit) onEdit,
  }) {
    return _client
        .channel('story_edits:$storyId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'story_edits',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'story_id',
        value: storyId,
      ),
      callback: (payload) {
        final edit = StoryEdit.fromMap(
            payload.newRecord as Map<String, dynamic>);
        // Ignorer ses propres éditions
        if (edit.userId == _currentUserId) return;
        onEdit(edit);
      },
    )
        .subscribe();
  }

  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}