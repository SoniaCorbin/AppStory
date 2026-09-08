
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../state/story_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/idea_provider.dart';
import '../../state/coffre_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../atelier/widgets/ham_btn.dart';

class StatsScreen extends ConsumerWidget {
  final VoidCallback onMenu;
  const StatsScreen({super.key, required this.onMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories  = ref.watch(storyProvider);
    final streak   = ref.watch(streakProvider);
    final ideas    = ref.watch(ideaProvider);
    final coffre   = ref.watch(coffreProvider);

    final totalBlocks  = stories.fold<int>(0, (s, st) => s + st.blocks.length);
    final finished     = stories.where((s) => s.progress >= 100).length;
    final avgProgress  = stories.isEmpty ? 0.0
        : stories.map((s) => s.progress).reduce((a, b) => a + b) / stories.length;

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(),
        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: 56),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HamBtn(onMenu: onMenu),
                    Text('◉ STATS',
                        style: StoryText.mono(size: 10, color: C.primary, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text('Statistiques',
                        style: StoryText.serif(size: 28, weight: FontWeight.w700)),
                    Text('Votre activité créative',
                        style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic)),
                  ],
                ),
              ),

              // Cartes résumé
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _SummaryCard(
                      title: 'Série actuelle',
                      value: '${streak.currentStreak} j',
                      subtitle: 'Total : ${streak.totalActiveDays} jours actifs',
                      icon: Icons.local_fire_department_rounded,
                      color: C.primary,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: 'Projets',
                      value: '${stories.length}',
                      subtitle: '$finished terminé${finished != 1 ? 's' : ''}',
                      icon: Icons.auto_stories_rounded,
                      color: C.accent,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: 'Blocs écrits',
                      value: '$totalBlocks',
                      subtitle: 'Dans ${stories.length} projet${stories.length != 1 ? 's' : ''}',
                      icon: Icons.view_module_rounded,
                      color: const Color(0xFF34D399),
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: 'Coffre à idées',
                      value: '${ideas.length}',
                      subtitle: '${coffre.length} élément${coffre.length != 1 ? 's' : ''} dans le coffre',
                      icon: Icons.diamond_rounded,
                      color: const Color(0xFFFBBF24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Progression moyenne
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROGRESSION MOYENNE',
                        style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tous les projets',
                                  style: StoryText.sans(size: 13, color: C.textMuted)),
                              Text('${avgProgress.toStringAsFixed(0)}%',
                                  style: StoryText.mono(size: 14, color: C.primary)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: avgProgress / 100,
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              color: C.primary,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Liste des projets
              if (stories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text('PROJETS',
                      style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2)),
                ),
                ...stories.map((s) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(s.title,
                                  style: StoryText.sans(size: 14, weight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text('${s.progress}%',
                                style: StoryText.mono(size: 12, color: C.primary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${s.blocks.length} bloc${s.blocks.length != 1 ? 's' : ''} · ${s.genre}',
                            style: StoryText.sans(size: 11, color: C.textMuted)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: s.progress / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            color: s.color,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ] else
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Text('📊', style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('Aucune donnée encore.',
                            style: StoryText.serif(size: 16, weight: FontWeight.w600)),
                        Text('Crée ton premier projet !',
                            style: StoryText.sans(size: 13, color: C.textMuted)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(title,
                      style: StoryText.sans(size: 13, color: C.textMuted)),
                ],
              ),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: StoryText.sans(size: 11, color: C.textDim, style: FontStyle.italic)),
            ],
          ),
          Text(value,
              style: StoryText.serif(size: 32, weight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}