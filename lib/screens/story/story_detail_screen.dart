import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat/chat_screen.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/story.dart';
import '../../services/export_service.dart';
import '../../state/pages_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../../widgets/chips/block_chip.dart';
import '../editor/editor_screen.dart';
import '../reader/reader_screen.dart';


class StoryDetailScreen extends ConsumerStatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  ConsumerState<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends ConsumerState<StoryDetailScreen> {
  late Story story;

  @override
  void initState() {
    super.initState();
    story = widget.story;
  }

  String _displayHook(Story s) {
    if (s.hook.trim().isNotEmpty) return s.hook;
    return "Aucune amorce pour cette histoire. Lance une génération depuis l'Atelier !";
  }

  Future<void> _openEditor() async {
    final updated = await Navigator.of(context).push<Story>(
      MaterialPageRoute(builder: (_) => EditorScreen(story: story)),
    );
    if (updated == null || !mounted) return;
    setState(() => story = updated);
  }

  Future<void> _continueWriting() async {
    final hook = story.hook.trim();
    if (hook.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucune amorce à reprendre. Génère-en une depuis l'Atelier."),
        ),
      );
      return;
    }
    await ref.read(pagesProvider.notifier).addPage(story.title, hook);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Page créée dans Mes Pages 📄',
          style: StoryText.sans(size: 13, color: C.text),
        ),
        backgroundColor: C.surface,
      ),
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
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 16),

                // Barre de navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: C.textDim),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.share_rounded, color: C.textDim),
                        tooltip: 'Exporter / Partager',
                        color: C.surface,
                        onSelected: (choice) async {
                          try {
                            if (choice == 'md') {
                              await ExportService.shareMarkdown(story);
                            } else if (choice == 'pdf') {
                              await ExportService.sharePdf(story);
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur lors de l\'export : $e'),
                              ),
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'md',
                            child: Row(
                              children: [
                                Icon(Icons.description_outlined,
                                    color: C.textMuted, size: 18),
                                const SizedBox(width: 10),
                                Text('Partager en Markdown',
                                    style: StoryText.sans(size: 13, color: C.text)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'pdf',
                            child: Row(
                              children: [
                                Icon(Icons.picture_as_pdf_outlined,
                                    color: C.textMuted, size: 18),
                                const SizedBox(width: 10),
                                Text('Partager en PDF',
                                    style: StoryText.sans(size: 13, color: C.text)),
                              ],
                            ),
                          ),
                        ],
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
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📖 PROJET',
                            style: StoryText.mono(
                                size: 10,
                                color: story.color,
                                letterSpacing: 2.6)),
                        const SizedBox(height: 8),
                        Text(story.title,
                            style: StoryText.serif(
                                size: 24, weight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: story.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: story.color.withValues(alpha: 0.22)),
                              ),
                              child: Text(story.genre,
                                  style: StoryText.mono(
                                      size: 11, color: story.color)),
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
                                    widthFactor:
                                    (story.progress / 100).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            story.color,
                                            story.color.withValues(alpha: 0.55),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${story.progress}%',
                                style: StoryText.mono(
                                    size: 11, color: C.textMuted)),
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
                      boxShadow: [
                        BoxShadow(
                            color: C.accent.withValues(alpha: 0.10),
                            blurRadius: 22),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✦ AMORCE',
                            style: StoryText.mono(
                                size: 10, color: C.accent, letterSpacing: 2.2)),
                        const SizedBox(height: 10),
                        Text(
                          _displayHook(story),
                          style: StoryText.serif(
                              size: 14, style: FontStyle.italic)
                              .copyWith(height: 1.8),
                        ),
                      ],
                    ),
                  ),
                ),

                // Blocs — label
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'BLOCS · ${story.blocks.length}',
                    style: StoryText.mono(
                        size: 10, color: C.textDim, letterSpacing: 2),
                  ),
                ),

                // Blocs — chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final b in story.blocks) BlockChip(type: b.type),
                      if (story.blocks.isEmpty)
                        Text('Aucun bloc (pour l\'instant).',
                            style: StoryText.sans(size: 13, color: C.textDim)),
                    ],
                  ),
                ),

                // Blocs — contenu
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
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BlockChip(type: b.type),
                                const SizedBox(height: 8),
                                Text(
                                  b.value,
                                  style: StoryText.sans(size: 13, color: C.text)
                                      .copyWith(height: 1.6),
                                ),
                              ],
                            ),
                          ),
                      if (story.blocks.isNotEmpty &&
                          story.blocks.every((e) => e.value.trim().isEmpty))
                        Text(
                          'Aucun contenu rédigé pour le moment.',
                          style: StoryText.sans(size: 13, color: C.textDim),
                        ),
                    ],
                  ),
                ),

                // Continuer l'écriture
                if (story.hook.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: story.color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _continueWriting,
                        child: const Text('Continuer l\'écriture →'),
                      ),
                    ),
                  ),
                // Chat
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: C.primary.withValues(alpha: 0.16),
                        foregroundColor: C.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ChatScreen(story: story)),
                      ),
                      child: const Text('💬 Chat du projet'),
                    ),
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
                            backgroundColor:
                            story.color.withValues(alpha: 0.16),
                            foregroundColor: story.color,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _openEditor,
                          child: const Text('Éditer'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: C.accent.withValues(alpha: 0.16),
                            foregroundColor: C.accent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReaderScreen(story: story),
                            ),
                          ),
                          child: const Text('Lire'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: C.surface,
                          foregroundColor: C.textMuted,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Épingler (à venir)')),
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