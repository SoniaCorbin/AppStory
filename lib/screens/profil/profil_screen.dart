import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/coffre_item.dart';
import '../../services/export_service.dart';
import '../../state/ai_settings_provider.dart';
import '../../state/coffre_provider.dart';
import '../../state/story_provider.dart';
import '../../state/theme_provider.dart';
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

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Toggle thème clair/sombre
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ref.watch(themeProvider)
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: C.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Thème',
                                    style: StoryText.sans(
                                        size: 14,
                                        weight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                    ref.watch(themeProvider)
                                        ? 'Sombre'
                                        : 'Clair',
                                    style: StoryText.sans(
                                        size: 12,
                                        color: C.textMuted,
                                        style: FontStyle.italic)),
                              ],
                            ),
                          ),
                          Switch(
                            value: ref.watch(themeProvider),
                            onChanged: (_) => ref
                                .read(themeProvider.notifier)
                                .toggle(),
                            activeColor: C.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ============ MODE IA ============
                    _AiModeCard(),
                    const SizedBox(height: 10),

                    _ActionRow(
                      title: 'Exporter toutes mes histoires',
                      subtitle: '${stories.length} histoire${stories.length > 1 ? 's' : ''} en Markdown',
                      onTap: () async {
                        if (stories.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Aucune histoire à exporter')),
                          );
                          return;
                        }
                        try {
                          // Concatène toutes les histoires en un seul Markdown
                          final buffer = StringBuffer();
                          buffer.writeln(
                              '# Mes histoires StoryBlocks\n');
                          buffer.writeln(
                              '_Export du ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}_\n\n');
                          for (final s in stories) {
                            buffer.writeln(
                                ExportService.toMarkdown(s));
                            buffer.writeln('\n\n---\n\n');
                          }
                          // Partage le tout dans un seul fichier
                          await Clipboard.setData(ClipboardData(
                              text: buffer.toString()));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    '✓ Copié dans le presse-papier !')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur : $e')),
                          );
                        }
                      },
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

/// Carte de configuration du Mode IA dans Profil.
class _AiModeCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ai = ref.watch(aiSettingsProvider);
    final ctrl = ref.read(aiSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ai.enabled
              ? C.accent.withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: C.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mode IA (Claude)',
                        style: StoryText.sans(
                            size: 14, weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      ai.hasApiKey
                          ? (ai.enabled
                              ? 'Activé — Génération via Claude'
                              : 'Désactivé — Génération locale')
                          : 'Aucune clé API configurée',
                      style: StoryText.sans(
                          size: 12,
                          color: C.textMuted,
                          style: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ai.enabled && ai.hasApiKey,
                onChanged: ai.hasApiKey
                    ? (v) => ctrl.setEnabled(v)
                    : null,
                activeColor: C.accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (ai.hasApiKey) ...[
            Row(
              children: [
                Icon(Icons.key_rounded, size: 14, color: C.textMuted),
                const SizedBox(width: 6),
                Text('Clé : ${ai.apiKeyPreview}',
                    style: StoryText.mono(size: 11, color: C.textMuted)),
                const Spacer(),
                TextButton(
                  onPressed: () => _confirmClearKey(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4466),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text('Effacer',
                      style: StoryText.sans(size: 11)),
                ),
                TextButton(
                  onPressed: () => _openApiKeyDialog(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: C.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child:
                      Text('Modifier', style: StoryText.sans(size: 11)),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: C.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () => _openApiKeyDialog(context, ref),
                icon: const Icon(Icons.key_rounded, size: 18),
                label: const Text('Configurer ma clé API Claude'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '🔒 Ta clé est stockée dans le Keystore Android, jamais envoyée à personne d\'autre qu\'Anthropic.',
              style: StoryText.sans(
                  size: 10,
                  color: C.textDim,
                  style: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openApiKeyDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        bool obscure = false; // Démarre visible pour faciliter le collage
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            backgroundColor: C.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: C.accent, size: 20),
                const SizedBox(width: 10),
                Text('Clé API Claude',
                    style: StoryText.serif(
                        size: 18, weight: FontWeight.w700)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récupère ta clé sur console.anthropic.com → API Keys',
                  style: StoryText.sans(
                      size: 12,
                      color: C.textMuted,
                      style: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  obscureText: obscure,
                  enableInteractiveSelection: true,
                  contextMenuBuilder: (ctx, editableTextState) {
                    return AdaptiveTextSelectionToolbar.editableText(
                      editableTextState: editableTextState,
                    );
                  },
                  style: StoryText.mono(size: 12),
                  decoration: InputDecoration(
                    hintText: 'sk-ant-...',
                    filled: true,
                    fillColor: C.surface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: C.textMuted),
                      onPressed: () => setS(() => obscure = !obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Bouton explicite "Coller depuis le presse-papier"
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: C.accent,
                        side: BorderSide(
                            color: C.accent.withValues(alpha: 0.4)),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () async {
                        final data = await Clipboard.getData(
                            Clipboard.kTextPlain);
                        final text = data?.text?.trim() ?? '';
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Presse-papier vide')),
                          );
                          return;
                        }
                        ctrl.text = text;
                        ctrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: text.length));
                      },
                      icon: const Icon(Icons.content_paste_rounded,
                          size: 16),
                      label: const Text('Coller'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ctrl.clear();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: C.textMuted,
                      ),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('Annuler',
                    style:
                        StoryText.sans(size: 13, color: C.textMuted)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: C.accent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    Navigator.pop(dialogCtx, ctrl.text.trim()),
                child: const Text('Enregistrer'),
              ),
            ],
          );
        });
      },
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(aiSettingsProvider.notifier).setApiKey(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Clé API enregistrée')),
      );
    }
  }

  Future<void> _confirmClearKey(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('Effacer la clé API ?',
            style: StoryText.serif(size: 16, weight: FontWeight.w700)),
        content: Text(
            'Cette action est irréversible. Tu pourras toujours en remettre une nouvelle.',
            style: StoryText.sans(size: 13, color: C.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF4466)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(aiSettingsProvider.notifier).clearApiKey();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑 Clé effacée')),
      );
    }
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
            Icon(Icons.chevron_right_rounded, color: C.textMuted),
          ],
        ),
      ),
    );
  }
}