import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/story.dart';
import '../../services/export_service.dart';
import '../../state/story_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class ReaderScreen extends ConsumerWidget {
  final Story story;

  const ReaderScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Découper le hook en paragraphes + les blocs assemblés
    final List<String> paragraphs = [
      if (story.hook.trim().isNotEmpty)
        ...story.hook.split('\n').where((s) => s.trim().isNotEmpty),
    ];

    return Stack(
      children: [
        const GridBg(opacity: 0.15),
        const MeshBlobs(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: C.bg.withValues(alpha: 0.92),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: C.text),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              story.title,
              style: StoryText.serif(size: 17, weight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              //Export
              IconButton(
                icon: Icon(Icons.ios_share_rounded, color: C.textMuted),
                tooltip: 'Exporter',
                onPressed: () => ExportService.shareMarkdown(story),
              ),
            ],
          ),
          body: paragraphs.isEmpty
              ? _buildEmptyState()
              : AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              itemCount: paragraphs.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 40.0,
                    child: FadeInAnimation(
                      child: _ReaderBlock(
                        text: paragraphs[index],
                        index: index,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✦', style: TextStyle(fontSize: 40, color: C.textDim)),
          const SizedBox(height: 16),
          Text('Aucun contenu à lire.',
              style: StoryText.serif(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Va dans l\'Atelier pour générer une amorce !',
              style: StoryText.sans(
                size: 13, color: C.textMuted, style: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _ReaderBlock extends ConsumerWidget {
  final String text;
  final int index;

  const _ReaderBlock({required this.text, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = [
      C.primary.withValues(alpha: 0.12),
      C.accent.withValues(alpha: 0.12),
      C.secondary.withValues(alpha: 0.12),
    ];
    final borderColors = [
      C.primary.withValues(alpha: 0.25),
      C.accent.withValues(alpha: 0.25),
      C.secondary.withValues(alpha: 0.25),
    ];

    final color         = colors[index % colors.length];
    final borderColor   = borderColors[index % borderColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: StoryText.mono(size: 11, color: C.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: StoryText.sans(
                size: 16,
                color: C.text,
              ).copyWith(height: 1.65),
            ),
          ),
        ],
      ),
    );
  }
}