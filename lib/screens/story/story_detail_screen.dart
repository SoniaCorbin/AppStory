import 'package:flutter/material.dart';

import '../../core/constants/story_tokens.dart';
import'../../core/theme/story_text_styles.dart';
import '../../models/story.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../../widgets/chips/block_chip.dart';

class StoryDetailScreen extends StatelessWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  String _mockHook(Story s) {
    // On reste volontairement "placeholder" tant que l’éditeur n’est pas branché.
    return "« ${s.title} » est un projet ${s.genre.toLowerCase()} en cours. "
        "Une idée teinte l’air d’un secret : si le protagoniste avançait d’un pas, "
        "quel prix devrait-il payer pour atteindre la vérité ?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBg(opacity: 0.25),
          const MeshBlobs(warm: true),

          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 56),

                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: C.textMuted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'DÉTAIL',
                          style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 44), // équilibre visuel
                    ],
                  ),
                ),

                // Header card
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: story.color.withOpacity(0.16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📖 PROJET', style: StoryText.mono(size: 10, color: story.color, letterSpacing: 2.6)),
                        const SizedBox(height: 8),
                        Text(story.title, style: StoryText.serif(size: 24, weight: FontWeight.w800)),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: story.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: story.color.withOpacity(0.22)),
                              ),
                              child: Text(story.genre, style: StoryText.mono(size: 11, color: story.color)),
                            ),
                            const SizedBox(width: 10),
                            Text('Dernière modif: ${story.lastEdit}', style: StoryText.sans(size: 12, color: C.textDim)),
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
                                          colors: [story.color, story.color.withOpacity(0.55)],
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
                      border: Border.all(color: C.accent.withOpacity(0.18)),
                      boxShadow: [BoxShadow(color: C.accent.withOpacity(0.10), blurRadius: 22)],
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final bt in story.blocks) BlockChip(type: bt),
                      if (story.blocks.isEmpty)
                        Text('Aucun bloc (pour l’instant).', style: StoryText.sans(size: 13, color: C.textDim)),
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
                            backgroundColor: story.color.withOpacity(0.16),
                            foregroundColor: story.color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('EditorScreen (à venir)')),
                            );
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
                          side: BorderSide(color: Colors.white.withOpacity(0.08)),
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