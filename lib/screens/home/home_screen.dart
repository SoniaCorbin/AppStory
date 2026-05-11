import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/coffre_item.dart';
import '../../models/story.dart';
import '../../state/coffre_provider.dart';
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

  String _todayLabel() {
    const days = [
      'LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'
    ];
    const months = [
      'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUIN',
      'JUIL', 'AOÛT', 'SEPT', 'OCT', 'NOV', 'DÉC'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]} · ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storyProvider);
    final coffre = ref.watch(coffreProvider);

    // Stats dynamiques
    final projetsCount = stories.length;
    final blocsCount = stories.fold<int>(0, (sum, s) => sum + s.blocks.length);
    final notesCount =
        coffre.where((i) => i.type == CoffreItemType.note).length;

    // Notes récentes du coffre
    final recentNotes = coffre
        .where((i) => i.type == CoffreItemType.note)
        .take(3)
        .toList();

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(warm: true),
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
                  dateLabel: _todayLabel(),
                ),
              ),

              // Stats strip — DYNAMIQUE
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                        child: _StatTile(
                            n: '$projetsCount',
                            label: 'Projets',
                            color: C.primary)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatTile(
                            n: '$blocsCount',
                            label: 'Blocs',
                            color: C.secondary)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatTile(
                            n: '$notesCount',
                            label: 'Notes',
                            color: C.accent)),
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
                    Text('RÉCENTS',
                        style: StoryText.mono(
                            size: 11,
                            color: C.textMuted,
                            letterSpacing: 2)),
                    Text('${stories.length} histoire${stories.length > 1 ? 's' : ''}',
                        style: StoryText.mono(size: 10, color: C.primary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    if (stories.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          children: [
                            const Text('✦', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text('Aucune histoire encore.',
                                style: StoryText.sans(
                                    size: 13, color: C.textMuted)),
                            const SizedBox(height: 4),
                            Text('Va dans l\'Atelier pour en créer une !',
                                style: StoryText.sans(
                                    size: 12,
                                    color: C.textDim,
                                    style: FontStyle.italic)),
                          ],
                        ),
                      )
                    else
                      for (final s in stories.reversed.take(5)) ...[
                        StoryCard(story: s, onPressed: () => onStory(s)),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),

              // Pense-bête (notes du coffre)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PENSE-BÊTE',
                        style: StoryText.mono(
                            size: 11,
                            color: C.textMuted,
                            letterSpacing: 2)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  children: [
                    if (recentNotes.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        child: Text(
                          'Pas encore de note. Ajoute-en depuis le Coffre !',
                          style: StoryText.sans(
                              size: 13,
                              color: C.textDim,
                              style: FontStyle.italic),
                        ),
                      )
                    else
                      for (final n in recentNotes) ...[
                        _QuickNoteTile(text: n.title, time: n.date),
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
  final String dateLabel;

  const _HomeHeader({
    required this.onMenu,
    required this.onSearch,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMenu,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _bar(),
                      const SizedBox(height: 4),
                      _bar(),
                      const SizedBox(height: 4),
                      _bar(),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(dateLabel,
                    style: StoryText.mono(
                        size: 10, color: C.primary, letterSpacing: 3)),
              ],
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  C.primary.withValues(alpha: 0.27),
                  C.accent.withValues(alpha: 0.27)
                ]),
                border: Border.all(
                    color: C.primary.withValues(alpha: 0.27), width: 1.5),
              ),
              child: Center(
                  child: Text('◉',
                      style: TextStyle(fontSize: 20, color: C.textMuted))),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Bonjour,',
            style: StoryText.serif(size: 26, weight: FontWeight.w700)),
        Text('Écrivain ✦',
            style: StoryText.serif(
                size: 26,
                weight: FontWeight.w400,
                color: C.textMuted,
                style: FontStyle.italic)),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: onSearch,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 18, color: C.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Rechercher dans StoryBlocks…',
                      style: StoryText.sans(size: 14, color: C.textDim)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar() => Container(
      width: 18,
      height: 2,
      decoration:
          BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(1)));
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
            child: Text('◈',
                style: TextStyle(
                    fontSize: 36,
                    color: Colors.white.withValues(alpha: 0.06))),
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
            decoration: BoxDecoration(
                color: C.secondary, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: StoryText.sans(
                      size: 13, color: C.text, weight: FontWeight.w400))),
          const SizedBox(width: 10),
          Text(time, style: StoryText.mono(size: 10, color: C.textDim)),
        ],
      ),
    );
  }
}
