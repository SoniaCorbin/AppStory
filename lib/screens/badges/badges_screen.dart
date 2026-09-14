import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/coffre_item.dart';
import '../../state/ai_settings_provider.dart';
import '../../state/coffre_provider.dart';
import '../../state/story_provider.dart';
import '../../state/streak_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories    = ref.watch(storyProvider);
    final coffre     = ref.watch(coffreProvider);
    final streak     = ref.watch(streakProvider);
    final aiSettings = ref.watch(aiSettingsProvider);

    final notes    = coffre.where((i) => i.type == CoffreItemType.note).length;
    final pinned   = coffre.where((i) => i.pinned).length;
    final finished = stories.where((s) => s.progress >= 100).length;
    final hasHook  = stories.any((s) => s.hook.trim().isNotEmpty);

    final badges = [
      _BadgeData('⚡', 'Éclair',       '10 jours actifs',      streak.totalActiveDays >= 10,  '${streak.totalActiveDays}/10 jours actifs'),
      _BadgeData('🧠', 'Archiviste',   '50 notes dans le coffre', notes >= 50,                '$notes/50 notes'),
      _BadgeData('✦',  'Alchimiste',   '1 amorce IA générée',  hasHook && aiSettings.hasApiKey, hasHook ? 'Amorce générée ✓' : 'Génère une amorce avec l\'IA'),
      _BadgeData('🏁', 'Finisseur',    '1 projet terminé',     finished >= 1,                 '$finished projet${finished != 1 ? 's' : ''} terminé${finished != 1 ? 's' : ''}'),
      _BadgeData('🔥', 'Streak',       '7 jours de suite',     streak.currentStreak >= 7,     '${streak.currentStreak}/7 jours consécutifs'),
      _BadgeData('💎', 'Coffre',       '1 élément épinglé',    pinned >= 1,                   '$pinned élément${pinned != 1 ? 's' : ''} épinglé${pinned != 1 ? 's' : ''}'),
      _BadgeData('📖', 'Bibliothécaire', '5 projets créés',    stories.length >= 5,           '${stories.length}/5 projets'),
      _BadgeData('🌟', 'Étoile',       '100 blocs écrits',     stories.fold<int>(0, (s, st) => s + st.blocks.length) >= 100, '${stories.fold<int>(0, (s, st) => s + st.blocks.length)}/100 blocs'),
      _BadgeData('🎯', 'Précision',    '3 projets terminés',   finished >= 3,                 '$finished/3 projets terminés'),
      _BadgeData('🚀', 'Lanceur',      '1er projet créé',      stories.isNotEmpty,            stories.isEmpty ? 'Crée ton premier projet !' : 'Premier projet créé ✓'),
      _BadgeData('📅', 'Régulier',     '30 jours actifs',      streak.totalActiveDays >= 30,  '${streak.totalActiveDays}/30 jours actifs'),
      _BadgeData('👑', 'Maître',       'Tous les badges',      false,                         'Débloquez tous les autres badges'),
    ];

    final unlocked = badges.where((b) => b.unlocked).length;

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: C.bg.withValues(alpha: 0.92),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: C.text, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Badges', style: StoryText.serif(size: 17, weight: FontWeight.w700)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              // Résumé
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: C.accent.withValues(alpha: 0.20)),
                ),
                child: Row(
                  children: [
                    Text('🏅', style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$unlocked / ${badges.length} débloqués',
                            style: StoryText.serif(size: 18, weight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Continue à écrire pour débloquer la suite !',
                            style: StoryText.sans(size: 12, color: C.textMuted, style: FontStyle.italic)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Débloqués
              if (unlocked > 0) ...[
                Text('DÉBLOQUÉS · $unlocked',
                    style: StoryText.mono(size: 10, color: C.primary, letterSpacing: 2)),
                const SizedBox(height: 12),
                ...badges.where((b) => b.unlocked).map((b) => _BadgeRow(b: b, unlocked: true)),
                const SizedBox(height: 20),
              ],

              // Verrouillés
              Text('À DÉBLOQUER · ${badges.length - unlocked}',
                  style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2)),
              const SizedBox(height: 12),
              ...badges.where((b) => !b.unlocked).map((b) => _BadgeRow(b: b, unlocked: false)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeData {
  final String icon;
  final String title;
  final String condition;
  final bool unlocked;
  final String progress;

  const _BadgeData(this.icon, this.title, this.condition, this.unlocked, this.progress);
}

class _BadgeRow extends StatelessWidget {
  final _BadgeData b;
  final bool unlocked;

  const _BadgeRow({required this.b, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? C.surface : C.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? C.accent.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: unlocked ? 1.0 : 0.3,
            child: Text(b.icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title,
                    style: StoryText.sans(
                        size: 14,
                        weight: FontWeight.w600,
                        color: unlocked ? C.text : C.textMuted)),
                const SizedBox(height: 2),
                Text(b.condition,
                    style: StoryText.sans(size: 12, color: C.textDim, style: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(b.progress,
                    style: StoryText.mono(size: 10, color: unlocked ? C.accent : C.textDim)),
              ],
            ),
          ),
          if (unlocked)
            Icon(Icons.check_circle_rounded, color: C.accent, size: 20),
        ],
      ),
    );
  }
}