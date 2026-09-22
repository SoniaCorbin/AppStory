import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/story.dart';
import '../../services/chat_service.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class ChatScreen extends StatefulWidget {
  final Story story;
  const ChatScreen({super.key, required this.story});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  RealtimeChannel? _channel;
  bool _loading = true;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribe();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    if (_channel != null) ChatService.unsubscribe(_channel!);
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final messages = await ChatService.getMessages(widget.story.id);
    if (!mounted) return;
    setState(() {
      _messages.addAll(messages);
      _loading = false;
    });
    _scrollToBottom();
  }

  void _subscribe() {
    _channel = ChatService.subscribeToMessages(
      storyId: widget.story.id,
      onMessage: (message) {
        if (!mounted) return;
        setState(() => _messages.add(message));
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty) return;
    _ctrl.clear();
    await ChatService.sendMessage(
      storyId: widget.story.id,
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBg(opacity: 0.25),
          const MeshBlobs(warm: true),
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 56),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: C.textDim),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('💬 CHAT',
                                style: StoryText.mono(
                                    size: 10, color: C.primary, letterSpacing: 2)),
                            Text(widget.story.title,
                                style: StoryText.serif(
                                    size: 16, weight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: _loading
                      ? Center(child: CircularProgressIndicator(color: C.primary))
                      : _messages.isEmpty
                      ? Center(
                    child: Text(
                      'Aucun message encore.\nCommence la conversation !',
                      style: StoryText.sans(
                          size: 13,
                          color: C.textDim,
                          style: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg.userId == _currentUserId;
                      return _MessageBubble(
                          message: msg, isMe: isMe);
                    },
                  ),
                ),

                // Input
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  color: C.bg,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          style: StoryText.sans(size: 14, color: C.text),
                          decoration: InputDecoration(
                            hintText: 'Écris un message…',
                            hintStyle: StoryText.sans(
                                size: 14, color: C.textDim),
                            filled: true,
                            fillColor: C.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: C.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: C.primary.withValues(alpha: 0.2),
              child: Text(
                message.userName.isNotEmpty
                    ? message.userName[0].toUpperCase()
                    : '?',
                style: StoryText.mono(size: 11, color: C.primary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? C.primary.withValues(alpha: 0.18)
                    : C.surface,
                borderRadius: BorderRadius.circular(14).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : null,
                  bottomLeft: !isMe ? const Radius.circular(4) : null,
                ),
                border: Border.all(
                  color: isMe
                      ? C.primary.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(message.userName,
                        style: StoryText.mono(
                            size: 9, color: C.primary, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(message.content,
                      style: StoryText.sans(size: 14, color: C.text)
                          .copyWith(height: 1.4)),
                  const SizedBox(height: 4),
                  Text(
                    '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                    style: StoryText.mono(size: 9, color: C.textDim),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}