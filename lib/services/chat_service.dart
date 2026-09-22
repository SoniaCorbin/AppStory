import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String id;
  final int storyId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      storyId: map['story_id'] as int,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class ChatService {
  static final _client = Supabase.instance.client;

  static Future<List<ChatMessage>> getMessages(int storyId) async {
    final response = await _client
        .from('project_messages')
        .select()
        .eq('story_id', storyId)
        .order('created_at')
        .limit(100);

    return (response as List)
        .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> sendMessage({
    required int storyId,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final name = _client.auth.currentUser?.userMetadata?['name'] as String? ?? 'Écrivain';

    await _client.from('project_messages').insert({
      'story_id': storyId,
      'user_id': user.id,
      'user_name': name,
      'content': content,
    });
  }

  static RealtimeChannel subscribeToMessages({
    required int storyId,
    required void Function(ChatMessage) onMessage,
  }) {
    return _client
        .channel('project_messages:$storyId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'project_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'story_id',
        value: storyId,
      ),
      callback: (payload) {
        final message = ChatMessage.fromMap(
            payload.newRecord as Map<String, dynamic>);
        onMessage(message);
      },
    )
        .subscribe();
  }

  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}