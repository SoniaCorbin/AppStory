import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/agenda_event.dart';
import '../../models/coffre_item.dart';
import '../../models/story.dart';
import '../../state/agenda_provider.dart';
import '../../state/coffre_provider.dart';
import '../../state/story_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../story/story_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String query = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stories = ref.watch(storyProvider);
    final coffre = ref.watch(coffreProvider);
    final agenda = ref.watch(agendaProvider);

    final q = query.trim().toLowerCase();

    // Filtrage selon la query
    final foundStories = q.isEmpty
        ? <Story>[]
        : stories.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.genre.toLowerCase().contains(q) ||
          s.hook.toLowerCase().contains(q) ||
          s.blocks.any((b) => b.value.toLowerCase().contains(q));
    }).toList();

    final foundCoffre = q.isEmpty
        ? <CoffreItem>[]
        : coffre.where((i) {
      return i.title.toLowerCase().contains(q) ||
          i.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();

    final foundAgenda = q.isEmpty
        ? <AgendaEvent>[]
        : agenda.where((e) => e.title.toLowerCase().contains(q)).toList();

    final totalResults =
        foundStories.length + foundCoffre.length + foundAgenda.length;

    return Scaffold(
      body: Stack(
        children: [
          IgnorePointer(child: const GridBg(opacity: 0.25)),
          IgnorePointer(child: const MeshBlobs(warm: false)),
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 56),

                // Top bar : retour + barre de recherche
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
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              color: C.textMuted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded,
                                  size: 18, color: C.textMuted),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _ctrl,
                                  autofocus: true,
                                  onChanged: (v) => setState(() => query = v),
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher partout…',
                                    hintStyle: StoryText.sans(
                                        size: 14, color: C.textDim),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style:
                                  StoryText.sans(size: 14, color: C.text),
                                ),
                              ),
                              if (query.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    setState(() => query = '');
                                  },
                                  child: Icon(Icons.close_rounded,
                                      size: 18, color: C.textDim),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Compteur de résultats
                if (q.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      '$totalResults résultat${totalResults > 1 ? 's' : ''} pour "$query"',
                      style: StoryText.mono(
                          size: 11, color: C.textDim, letterSpacing: 1),
                    ),
                  ),

                // État vide / pas de query
                if (q.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('🔮', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 16),
                          Text('Cherche dans tout StoryBlocks',
                              style: StoryText.serif(
                                  size: 18, weight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            'Histoires, notes du coffre, événements…',
                            style: StoryText.sans(
                                size: 13,
                                color: C.textMuted,
                                style: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Aucun résultat
                if (q.isNotEmpty && totalResults == 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('🤷', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('Aucun résultat',
                              style: StoryText.sans(
                                  size: 14, color: C.textMuted)),
                        ],
                      ),
                    ),
                  ),

                // Résultats : Histoires
                if (foundStories.isNotEmpty) ...[
                  _SectionHeader(label: 'HISTOIRES', count: foundStories.length),
                  for (final s in foundStories)
                    _StoryResult(
                      story: s,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => StoryDetailScreen(story: s)));
                      },
                    ),
                ],

                // Résultats : Coffre
                if (foundCoffre.isNotEmpty) ...[
                  _SectionHeader(label: 'COFFRE', count: foundCoffre.length),
                  for (final i in foundCoffre)
                    _CoffreResult(item: i),
                ],

                // Résultats : Agenda
                if (foundAgenda.isNotEmpty) ...[
                  _SectionHeader(label: 'AGENDA', count: foundAgenda.length),
                  for (final e in foundAgenda) _AgendaResult(event: e),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(label,
              style: StoryText.mono(
                  size: 10, color: C.primary, letterSpacing: 2)),
          const SizedBox(width: 8),
          Text('· $count',
              style: StoryText.mono(size: 10, color: C.textDim)),
        ],
      ),
    );
  }
}

class _StoryResult extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  const _StoryResult({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: story.color.withValues(alpha: 0.13)),
        ),
        child: Row(
          children: [
            Text('📖', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title,
                      style: StoryText.serif(
                          size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(story.genre,
                      style: StoryText.sans(
                          size: 11,
                          color: C.textMuted,
                          style: FontStyle.italic)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: C.textDim),
          ],
        ),
      ),
    );
  }
}

class _CoffreResult extends StatelessWidget {
  final CoffreItem item;
  const _CoffreResult({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: StoryText.sans(
                        size: 14, weight: FontWeight.w600)),
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final t in item.tags)
                        Text('#$t',
                            style: StoryText.mono(
                                size: 10, color: item.color)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaResult extends StatelessWidget {
  final AgendaEvent event;
  const _AgendaResult({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Text(event.color, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: StoryText.sans(
                        size: 14,
                        weight: FontWeight.w600,
                        color: event.completed ? C.textDim : C.text)),
                const SizedBox(height: 2),
                Text(
                    '${event.date.day}/${event.date.month} · ${event.time}',
                    style: StoryText.mono(size: 10, color: C.textDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}