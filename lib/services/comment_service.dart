import 'package:supabase_flutter/supabase_flutter.dart';

class BlockComment {
  final String id;
  final int storyId;
  final int blockIndex;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const BlockComment({
    required this.id,
    required this.storyId,
    required this.blockIndex,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory BlockComment.fromMap(Map<String, dynamic> map) {
    return BlockComment(
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

class CommentService {
  static final _client = Supabase.instance.client;

  static Future<List<BlockComment>> getComments({
    required int storyId,
    required int blockIndex,
  }) async {
    final response = await _client
        .from('block_comments')
        .select()
        .eq('story_id', storyId)
        .eq('block_index', blockIndex)
        .order('created_at');

    return (response as List)
        .map((e) => BlockComment.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addComment({
    required int storyId,
    required int blockIndex,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final name = user.userMetadata?['name'] as String? ?? 'Écrivain';

    await _client.from('block_comments').insert({
      'story_id': storyId,
      'block_index': blockIndex,
      'user_id': user.id,
      'user_name': name,
      'content': content,
    });
  }

  static Future<void> deleteComment(String commentId) async {
    await _client
        .from('block_comments')
        .delete()
        .eq('id', commentId);
  }

  static Future<Map<int, int>> getCommentCounts(int storyId) async {
    final response = await _client
        .from('block_comments')
        .select('block_index')
        .eq('story_id', storyId);

    final counts = <int, int>{};
    for (final row in response as List) {
      final idx = row['block_index'] as int;
      counts[idx] = (counts[idx] ?? 0) + 1;
    }
    return counts;
  }
}