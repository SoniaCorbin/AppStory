import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/coffre_item.dart';
import '../../state/coffre_provider.dart';
import '../../state/story_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../atelier/widgets/ham_btn.dart';
import 'widgets/progress_ring.dart';

class ProfilScreen extends ConsumerWidget {
  final VoidCallback onMenu;

  const ProfilScreen({super.key, required this.onMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stats DYNAMIQUES depuis Hive
    final stories = ref.watch(storyProvider);
    final coffre = ref.watch(coffreProvider);

    final projects = stories.length;
    final blocks = stories.fold<int>(0, (s, st) => s + st.blocks.length);
    final notes =
        coffre.where((i) => i.type == CoffreItemType.note).length;

    // XP basé sur l'activité réelle
    final xp = (projects * 50) + (blocks * 5) + (notes * 10);
    final level = (xp ~/ 200) + 1;
    final nextXp = level * 200;
    final progress = nextXp == 0 ? 0.0 : (xp % 200) / 200.0;

    final avgProjectProgress = stories.isEmpty
        ? 0.0
        : stories.map((s) => s.progress).reduce((a, b) => a + b) /
            (stories.length * 100.0);

    final badges = const [
      _Badge('⚡', 'Éclair', '10 jours actifs'),
      _Badge('🧠', 'Archiviste', '50 notes'),
      _Badge('✦', 'Alchimiste', '1 amorce générée'),
      _Badge('🏁', 'Finisseur', '1 projet terminé'),
      _Badge('🔥', 'Streak', '7 jours de suite'),
      _Badge('💎', 'Coffre', '1 épinglé'),
    ];

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(warm: true),

        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: 56),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HamBtn(onMenu: onMenu),
                    Text('◉ PROFIL', style: StoryText.mono(size: 10, color: C.primary, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text('Votre Atelier', style: StoryText.serif(size: 28, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Stats & badges', style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic)),
                  ],
                ),
              ),

              // Profile card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: C.primary.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [C.primary.withValues(alpha: 0.27), C.accent.withValues(alpha: 0.27)],
                          ),
                          border: Border.all(color: C.primary.withValues(alpha: 0.33), width: 2),
                        ),
                        child: const Center(child: Text('🖊', style: TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sonia', style: StoryText.serif(size: 18, weight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('Écrivain · Niveau $level', style: StoryText.mono(size: 10, color: C.primary)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: Container(
                                      height: 3,
                                      color: C.surface3,
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: progress.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [C.primary, C.primary.withValues(alpha: 0.55)],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('$xp/$nextXp XP', style: StoryText.mono(size: 10, color: C.textDim)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Rings + stats
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: C.accent.withValues(alpha: 0.12)),
                        ),
                        child: Center(
                          child: ProgressRing(
                            progress: avgProjectProgress,
                            label: 'PROJET',
                            value: '${(avgProjectProgress * 100).round()}%',
                            color: C.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _MiniStat(n: '$projects', label: 'Projets', color: C.primary),
                          const SizedBox(height: 10),
                          _MiniStat(n: '$blocks', label: 'Blocs', color: C.secondary),
                          const SizedBox(height: 10),
                          _MiniStat(n: '$notes', label: 'Notes', color: C.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Badges
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('BADGES', style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2)),
                    Text('Voir tout →', style: StoryText.mono(size: 10, color: C.primary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, i) => _BadgeTile(b: badges[i]),
                ),
              ),

              // Actions (placeholders)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _ActionRow(
                      title: 'Exporter mes données',
                      subtitle: 'JSON / texte (à venir)',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export (à venir)')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ActionRow(
                      title: 'Préférences',
                      subtitle: 'Thème, police, etc.',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Préférences (à venir)')),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String n;
  final String label;
  final Color color;

  const _MiniStat({required this.n, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n, style: StoryText.mono(size: 18, color: color, weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label, style: StoryText.sans(size: 11, color: C.textMuted)),
        ],
      ),
    );
  }
}

@immutable
class _Badge {
  final String icon;
  final String title;
  final String subtitle;
  const _Badge(this.icon, this.title, this.subtitle);
}

class _BadgeTile extends StatelessWidget {
  final _Badge b;
  const _BadgeTile({required this.b});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(b.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            b.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StoryText.mono(size: 10, color: C.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            b.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StoryText.sans(size: 10, color: C.textDim, style: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: StoryText.sans(size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: StoryText.sans(size: 12, color: C.textMuted, style: FontStyle.italic)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: C.textMuted),
          ],
        ),
      ),
    );
  }
}