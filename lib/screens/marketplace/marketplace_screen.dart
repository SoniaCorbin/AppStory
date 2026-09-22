import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/story.dart';
import '../../services/template_service.dart';
import '../../state/story_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  List<StoryTemplate> _templates = [];
  bool _loading = true;
  String _selectedGenre = 'Tous';

  final List<String> _genres = [
    'Tous', 'Romance', 'Thriller', 'Fantasy', 'Science-Fiction', 'Écriture libre'
  ];

  final List<Color> _colors = [
    const Color(0xFF7B2FF7),
    const Color(0xFF00D4FF),
    const Color(0xFFFF6B35),
    const Color(0xFF00E5A0),
    const Color(0xFFFFD700),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final templates = await TemplateService.getTemplates(
      genre: _selectedGenre == 'Tous' ? null : _selectedGenre,
    );
    if (!mounted) return;
    setState(() {
      _templates = templates;
      _loading = false;
    });
  }

  Future<void> _useTemplate(StoryTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('Utiliser ce template ?',
            style: StoryText.serif(size: 18, weight: FontWeight.w700)),
        content: Text(
          'Une nouvelle histoire "${template.title}" sera créée avec les blocs de ce template.',
          style: StoryText.sans(size: 13, color: C.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style: StoryText.sans(size: 13, color: C.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.primary),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Créer',
                style: StoryText.mono(size: 12, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final color = _colors[Random().nextInt(_colors.length)];
    final story = Story(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: template.title,
      genre: template.genre,
      blocks: template.blocks,
      progress: 0,
      color: color,
      lastEdit: 'à l\'instant',
      hook: '',
    );

    await ref.read(storyProvider.notifier).addStory(story);
    await TemplateService.incrementDownloads(template.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Histoire créée depuis le template 📖',
            style: StoryText.sans(size: 13, color: C.text)),
        backgroundColor: C.surface,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBg(opacity: 0.25),
          const MeshBlobs(warm: true),
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 56),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: C.textDim),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('◈ MARKETPLACE',
                                style: StoryText.mono(
                                    size: 10,
                                    color: C.primary,
                                    letterSpacing: 2)),
                            Text('Templates de blocs',
                                style: StoryText.serif(
                                    size: 16, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Filtres genres
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _genres.length,
                    itemBuilder: (_, i) {
                      final genre = _genres[i];
                      final selected = genre == _selectedGenre;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedGenre = genre);
                          _load();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? C.primary
                                : C.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? C.primary
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            genre,
                            style: StoryText.mono(
                              size: 11,
                              color: selected ? Colors.white : C.textMuted,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Liste templates
                Expanded(
                  child: _loading
                      ? Center(
                      child: CircularProgressIndicator(color: C.primary))
                      : _templates.isEmpty
                      ? Center(
                    child: Text(
                      'Aucun template disponible.',
                      style: StoryText.sans(
                          size: 13,
                          color: C.textDim,
                          style: FontStyle.italic),
                    ),
                  )
                      : ListView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: _templates.length,
                    itemBuilder: (_, i) {
                      final t = _templates[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: t.isOfficial
                                ? C.primary.withValues(alpha: 0.25)
                                : Colors.white
                                .withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(t.title,
                                      style: StoryText.serif(
                                          size: 16,
                                          weight:
                                          FontWeight.w700)),
                                ),
                                if (t.isOfficial)
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: C.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: Text('✦ OFFICIEL',
                                        style: StoryText.mono(
                                            size: 9,
                                            color: C.primary)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(t.description,
                                style: StoryText.sans(
                                    size: 13,
                                    color: C.textMuted,
                                    style: FontStyle.italic)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                    color: C.surface3,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Text(t.genre,
                                      style: StoryText.mono(
                                          size: 10,
                                          color: C.textMuted)),
                                ),
                                const SizedBox(width: 8),
                                Text('${t.downloads} utilisations',
                                    style: StoryText.mono(
                                        size: 10,
                                        color: C.textDim)),
                                const Spacer(),
                                Text('par ${t.authorName}',
                                    style: StoryText.mono(
                                        size: 10,
                                        color: C.textDim)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: C.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          10)),
                                  padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                                onPressed: () =>
                                    _useTemplate(t),
                                child: const Text(
                                    'Utiliser ce template →'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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