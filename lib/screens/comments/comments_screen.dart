import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/assembled_block.dart';
import '../../models/story.dart';
import '../../services/comment_service.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../../widgets/chips/block_chip.dart';

class CommentsScreen extends StatefulWidget {
  final Story story;
  final int blockIndex;
  final AssembledBlock block;

  const CommentsScreen({
    super.key,
    required this.story,
    required this.blockIndex,
    required this.block,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<BlockComment> _comments = [];
  bool _loading = true;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await CommentService.getComments(
      storyId: widget.story.id,
      blockIndex: widget.blockIndex,
    );
    if (!mounted) return;
    setState(() {
      _comments = comments;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty) return;
    _ctrl.clear();
    await CommentService.addComment(
      storyId: widget.story.id,
      blockIndex: widget.blockIndex,
      content: content,
    );
    await _loadComments();
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

  Future<void> _delete(String commentId) async {
    await CommentService.deleteComment(commentId);
    await _loadComments();
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
                            Text('💬 COMMENTAIRES',
                                style: StoryText.mono(
                                    size: 10,
                                    color: C.accent,
                                    letterSpacing: 2)),
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

                // Bloc concerné
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: C.accent.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlockChip(type: widget.block.type),
                        if (widget.block.value.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.block.value.trim(),
                            style: StoryText.sans(size: 13, color: C.textMuted)
                                .copyWith(height: 1.5),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Commentaires
                Expanded(
                  child: _loading
                      ? Center(
                      child: CircularProgressIndicator(color: C.accent))
                      : _comments.isEmpty
                      ? Center(
                    child: Text(
                      'Aucun commentaire encore.\nSois le premier !',
                      style: StoryText.sans(
                          size: 13,
                          color: C.textDim,
                          style: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollCtrl,
                    padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    itemCount: _comments.length,
                    itemBuilder: (_, i) {
                      final c = _comments[i];
                      final isMe = c.userId == _currentUserId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? C.accent.withValues(alpha: 0.10)
                              : C.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMe
                                ? C.accent.withValues(alpha: 0.25)
                                : Colors.white
                                .withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                              C.accent.withValues(alpha: 0.2),
                              child: Text(
                                c.userName.isNotEmpty
                                    ? c.userName[0].toUpperCase()
                                    : '?',
                                style: StoryText.mono(
                                    size: 11, color: C.accent),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(c.userName,
                                          style: StoryText.mono(
                                              size: 10,
                                              color: C.accent,
                                              letterSpacing: 1)),
                                      const Spacer(),
                                      Text(
                                        '${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                                        style: StoryText.mono(
                                            size: 9,
                                            color: C.textDim),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c.content,
                                      style: StoryText.sans(
                                          size: 13,
                                          color: C.text)
                                          .copyWith(height: 1.4)),
                                ],
                              ),
                            ),
                            if (isMe)
                              IconButton(
                                icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Colors.redAccent),
                                onPressed: () => _delete(c.id),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      );
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
                            hintText: 'Ajoute un commentaire…',
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
                            color: C.accent,
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