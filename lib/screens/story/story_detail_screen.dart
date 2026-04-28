import 'package:flutter/material.dart';

import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/story.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../../widgets/chips/block_chip.dart';
import '../editor/editor_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late Story story;

  @override
  void initState() {
    super.initState();
    story = widget.story;
  }

  String _mockHook(Story s) {
    // Garde ta version si tu en as déjà une.
    // Celle-ci évite une erreur si tu copies-colles direct.
    return "Une amorce (placeholder) pour “${s.title}”.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IgnorePointer(child: const GridBg(opacity: 0.25)),
          IgnorePointer(child: const MeshBlobs(warm: true)),
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: C.textDim),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Tu peux ajouter un menu contextuel ici si tu veux
                        },
                        icon: const Icon(Icons.more_horiz_rounded, color: C.textDim),
                      ),
                    ],
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📖 PROJET',
                            style: StoryText.mono(size: 10, color: story.color, letterSpacing: 2.6)),
                        const SizedBox(height: 8),
                        Text(story.title, style: StoryText.serif(size: 24, weight: FontWeight.w800)),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: story.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: story.color.withValues(alpha: 0.22)),
                              ),
                              child: Text(story.genre, style: StoryText.mono(size: 11, color: story.color)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Dernière modif: ${story.lastEdit}',
                                style: StoryText.sans(size: 12, color: C.textDim),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Progress bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Container(
                                  height: 6,
                                  color: C.surface3,
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: (story.progress / 100).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [story.color, story.color.withValues(alpha: 0.55)],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${story.progress}%', style: StoryText.mono(size: 11, color: C.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Hook / amorce
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.accent.withValues(alpha: 0.18)),
                      boxShadow: [BoxShadow(color: C.accent.withValues(alpha: 0.10), blurRadius: 22)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✦ AMORCE', style: StoryText.mono(size: 10, color: C.accent, letterSpacing: 2.2)),
                        const SizedBox(height: 10),
                        Text(
                          _mockHook(story),
                          style: StoryText.serif(size: 14, style: FontStyle.italic).copyWith(height: 1.8),
                        ),
                      ],
                    ),
                  ),
                ),

                // Blocs
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'BLOCS · ${story.blocks.length}',
                    style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2),
                  ),
                ),

                // Chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final b in story.blocks) BlockChip(type: b.type),
                      if (story.blocks.isEmpty)
                        Text('Aucun bloc (pour l’instant).', style: StoryText.sans(size: 13, color: C.textDim)),
                    ],
                  ),
                ),

                // Contenu des blocs
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [
                      for (final b in story.blocks)
                        if (b.value.trim().isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: C.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BlockChip(type: b.type),
                                const SizedBox(height: 8),
                                Text(
                                  b.value,
                                  style: StoryText.sans(size: 13, color: C.text).copyWith(height: 1.6),
                                ),
                              ],
                            ),
                          ),
                      if (story.blocks.isNotEmpty && story.blocks.every((e) => e.value.trim().isEmpty))
                        Text(
                          'Aucun contenu rédigé pour le moment.',
                          style: StoryText.sans(size: 13, color: C.textDim),
                        ),
                    ],
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: story.color.withValues(alpha: 0.16),
                            foregroundColor: story.color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final updated = await Navigator.of(context).push<Story>(
                              MaterialPageRoute(
                                builder: (_) => EditorScreen(story: story),
                              ),
                            );

                            if (updated == null) return;

                            setState(() => story = updated);
                          },
                          child: const Text('Éditer'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: C.surface,
                          foregroundColor: C.textMuted,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Épingler (à venir)')),
                          );
                        },
                        child: const Text('📌'),
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