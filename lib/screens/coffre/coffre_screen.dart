import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../data/mock/mock_coffre.dart';
import '../../models/coffre_item.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../atelier/widgets/ham_btn.dart';
import 'widgets/coffre_card.dart';

class CoffreScreen extends StatefulWidget {
  final VoidCallback onMenu;

  const CoffreScreen({super.key, required this.onMenu});

  @override
  State<CoffreScreen> createState() => _CoffreScreenState();
}

class _CoffreScreenState extends State<CoffreScreen> {
  String filter = 'tous';
  final filters = const ['tous', 'projets', 'notes', 'idées'];

  CoffreItemType? _mapFilterToType(String f) {
    switch (f) {
      case 'projets':
        return CoffreItemType.projet;
      case 'notes':
        return CoffreItemType.note;
      case 'idées':
        return CoffreItemType.idee; // (dans nos mocks on n’en a pas encore)
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _mapFilterToType(filter);
    final filtered = coffreItems.where((i) => type == null ? true : i.type == type).toList();
    final pinned = filtered.where((i) => i.pinned).toList();
    final others = filtered.where((i) => !i.pinned).toList();

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(warm: false),

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
                    HamBtn(onMenu: widget.onMenu),
                    Text('◈ COFFRE-FORT', style: StoryText.mono(size: 10, color: C.secondary, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text("Le Coffre à Idées", style: StoryText.serif(size: 28, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Toutes vos inspirations, sécurisées',
                      style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              // Search (visuel)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: C.textMuted),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Rechercher dans le coffre…', style: StoryText.sans(size: 14, color: C.textDim))),
                    ],
                  ),
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final f = filters[i];
                      final sel = filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? C.secondary.withOpacity(0.13) : C.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: sel ? C.secondary.withOpacity(0.40) : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              f,
                              style: StoryText.mono(
                                size: 11,
                                color: sel ? C.secondary : C.textMuted,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Pinned (uniquement si filter=tous, comme ton React)
              if (filter == 'tous' && pinned.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📌 ÉPINGLÉS', style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      for (final item in pinned) CoffreCard(item: item, onPressed: () {}),
                    ],
                  ),
                ),

              // All
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${filter == 'tous' ? 'TOUT' : filter.toUpperCase()} · ${others.length}',
                      style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2),
                    ),
                    const SizedBox(height: 10),
                    for (final item in others) CoffreCard(item: item, onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),

        // FAB
        Positioned(
          right: 24,
          bottom: 96,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouter (à venir)')),
              );
            },
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [C.secondary, const Color(0xFFCC4411)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: C.secondary.withOpacity(0.40),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('+', style: TextStyle(fontSize: 26, color: Colors.white, height: 1)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}