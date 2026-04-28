import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../data/mock/mock_notes.dart';
import '../../data/mock/mock_stories.dart';
import '../../models/story.dart';
import '../../state/story_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import 'widgets/streak_banner.dart';
import 'widgets/story_card.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onMenu;
  final VoidCallback onSearch;
  final ValueChanged<Story> onStory;

  const HomeScreen({
    super.key,
    required this.onMenu,
    required this.onSearch,
    required this.onStory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storyProvider);
    final displayStories = stories.isEmpty ? recentStories : stories;

    return Stack(
      children: [
        IgnorePointer(child: const GridBg(opacity: 0.25)),
        IgnorePointer(child: const MeshBlobs(warm: true)),
        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              const SizedBox(height: 56),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _HomeHeader(
                  onMenu: onMenu,
                  onSearch: onSearch,
                ),
              ),

              // Stats strip
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(child: _StatTile(n: '${displayStories.length}', label: 'Projets', color: C.primary)),
                    const SizedBox(width: 10),
                    const Expanded(child: _StatTile(n: '147', label: 'Blocs', color: C.secondary)),
                    const SizedBox(width: 10),
                    const Expanded(child: _StatTile(n: '38', label: 'Notes', color: C.accent)),
                  ],
                ),
              ),

              const StreakBanner(),

              // Recents
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RÉCENTS', style: StoryText.mono(size: 11, color: C.textMuted, letterSpacing: 2)),
                    Text('Voir tout →', style: StoryText.mono(size: 10, color: C.primary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    for (final s in displayStories) ...[
                      StoryCard(story: s, onPressed: () => onStory(s)),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),

              // Pense-bête
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PENSE-BÊTE', style: StoryText.mono(size: 11, color: C.textMuted, letterSpacing: 2)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: C.primary.withValues(alpha: 0.12),
                        border: Border.all(color: C.primary.withValues(alpha: 0.27)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('+ Ajouter', style: StoryText.mono(size: 10, color: C.primary)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  children: [
                    for (final n in quickNotes) ...[
                      _QuickNoteTile(text: n.text, time: n.time),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onMenu;
  final VoidCallback onSearch;

  const _HomeHeader({required this.onMenu, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onMenu,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _bar(), const SizedBox(height: 4),
                      _bar(), const SizedBox(height: 4),
                      _bar(),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text('MERCREDI · 23 AVR', style: StoryText.mono(size: 10, color: C.primary, letterSpacing: 3)),
              ],
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [C.primary.withValues(alpha: 0.27), C.accent.withValues(alpha: 0.27)]),
                border: Border.all(color: C.primary.withValues(alpha: 0.27), width: 1.5),
              ),
              child: const Center(child: Text('◉', style: TextStyle(fontSize: 20, color: C.textMuted))),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Bonjour,', style: StoryText.serif(size: 26, weight: FontWeight.w700)),
        Text('Écrivain ✦', style: StoryText.serif(size: 26, weight: FontWeight.w400, color: C.textMuted, style: FontStyle.italic)),
        const SizedBox(height: 16),

        // Search bar
        GestureDetector(
          onTap: onSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 18, color: C.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Rechercher dans StoryBlocks…', style: StoryText.sans(size: 14, color: C.textDim)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: C.surface2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('⌘F', style: StoryText.mono(size: 10, color: C.textDim)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar() => Container(width: 18, height: 2, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(1)));
}

class _StatTile extends StatelessWidget {
  final String n;
  final String label;
  final Color color;

  const _StatTile({required this.n, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            bottom: -10,
            child: Text('◈', style: TextStyle(fontSize: 36, color: Colors.white.withValues(alpha: 0.06))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n, style: StoryText.mono(size: 22, color: color)),
              const SizedBox(height: 2),
              Text(label, style: StoryText.sans(size: 11, color: C.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickNoteTile extends StatelessWidget {
  final String text;
  final String time;

  const _QuickNoteTile({required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: C.secondary, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: StoryText.sans(size: 13, color: C.text, weight: FontWeight.w400))),
          const SizedBox(width: 10),
          Text(time, style: StoryText.mono(size: 10, color: C.textDim)),
        ],
      ),
    );
  }
}