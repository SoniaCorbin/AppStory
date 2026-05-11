import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/coffre_item.dart';
import '../../state/coffre_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../atelier/widgets/ham_btn.dart';
import 'widgets/coffre_card.dart';

class CoffreScreen extends ConsumerStatefulWidget {
  final VoidCallback onMenu;

  const CoffreScreen({super.key, required this.onMenu});

  @override
  ConsumerState<CoffreScreen> createState() => _CoffreScreenState();
}

class _CoffreScreenState extends ConsumerState<CoffreScreen> {
  String filter = 'tous';
  String search = '';
  final filters = const ['tous', 'projets', 'notes', 'idées'];
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  CoffreItemType? _mapFilterToType(String f) {
    switch (f) {
      case 'projets':
        return CoffreItemType.projet;
      case 'notes':
        return CoffreItemType.note;
      case 'idées':
        return CoffreItemType.idee;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(coffreProvider);
    final type = _mapFilterToType(filter);
    final filtered = allItems.where((i) {
      if (type != null && i.type != type) return false;
      if (search.isNotEmpty &&
          !i.title.toLowerCase().contains(search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
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
                    Text('◈ COFFRE-FORT',
                        style: StoryText.mono(
                            size: 10,
                            color: C.secondary,
                            letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text("Le Coffre à Idées",
                        style:
                            StoryText.serif(size: 28, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Toutes vos inspirations, sécurisées',
                      style: StoryText.sans(
                          size: 13,
                          color: C.textMuted,
                          style: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => search = v),
                          decoration: InputDecoration(
                            hintText: 'Rechercher dans le coffre…',
                            hintStyle:
                                StoryText.sans(size: 14, color: C.textDim),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: StoryText.sans(size: 14, color: C.text),
                        ),
                      ),
                      if (search.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => search = '');
                          },
                          child: Icon(Icons.close_rounded,
                              size: 18, color: C.textDim),
                        ),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel
                                ? C.secondary.withValues(alpha: 0.13)
                                : C.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: sel
                                  ? C.secondary.withValues(alpha: 0.40)
                                  : Colors.white.withValues(alpha: 0.06),
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

              // Empty state
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          search.isEmpty
                              ? 'Le coffre est vide. Appuie sur + pour ajouter !'
                              : 'Aucun résultat pour "$search"',
                          style: StoryText.sans(
                              size: 13,
                              color: C.textDim,
                              style: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Pinned
              if (filter == 'tous' && pinned.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📌 ÉPINGLÉS',
                          style: StoryText.mono(
                              size: 10,
                              color: C.textDim,
                              letterSpacing: 2)),
                      const SizedBox(height: 10),
                      for (final item in pinned)
                        _DismissibleCard(
                          item: item,
                          onDelete: () => ref
                              .read(coffreProvider.notifier)
                              .deleteItem(item.id),
                          onTap: () => _openDetails(context, item),
                        ),
                    ],
                  ),
                ),

              // All others
              if (others.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filter == 'tous' ? 'TOUT' : filter.toUpperCase()} · ${others.length}',
                        style: StoryText.mono(
                            size: 10,
                            color: C.textDim,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 10),
                      for (final item in others)
                        _DismissibleCard(
                          item: item,
                          onDelete: () => ref
                              .read(coffreProvider.notifier)
                              .deleteItem(item.id),
                          onTap: () => _openDetails(context, item),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // FAB
        Positioned(
          right: 24,
          bottom: 130,
          child: GestureDetector(
            onTap: () => _openAddSheet(context),
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
                    color: C.secondary.withValues(alpha: 0.40),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('+',
                    style: TextStyle(
                        fontSize: 26, color: Colors.white, height: 1)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openDetails(BuildContext context, CoffreItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                        color: C.surface3,
                        borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item.title,
                          style: StoryText.serif(
                              size: 18, weight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ajouté le ${item.date}',
                    style: StoryText.sans(size: 12, color: C.textDim)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: item.pinned
                              ? C.primary.withValues(alpha: 0.20)
                              : C.surface2,
                          foregroundColor:
                              item.pinned ? C.primary : C.textMuted,
                        ),
                        onPressed: () {
                          ref
                              .read(coffreProvider.notifier)
                              .togglePin(item.id);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.push_pin_outlined),
                        label: Text(item.pinned ? 'Désépingler' : 'Épingler'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFF4466).withValues(alpha: 0.16),
                        foregroundColor: const Color(0xFFFF4466),
                      ),
                      onPressed: () {
                        ref
                            .read(coffreProvider.notifier)
                            .deleteItem(item.id);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Supprimer'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAddSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final tagsCtrl = TextEditingController();
    CoffreItemType selectedType = CoffreItemType.note;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                            color: C.surface3,
                            borderRadius: BorderRadius.circular(99)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Ajouter au coffre',
                        style: StoryText.serif(
                            size: 20, weight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    // Type selector
                    Text('TYPE',
                        style: StoryText.mono(
                            size: 10,
                            color: C.textDim,
                            letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final t in CoffreItemType.values) ...[
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setSheetState(
                                  () => selectedType = t),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedType == t
                                      ? C.secondary.withValues(alpha: 0.18)
                                      : C.surface2,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedType == t
                                        ? C.secondary
                                            .withValues(alpha: 0.40)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _typeLabel(t),
                                    style: StoryText.mono(
                                      size: 11,
                                      color: selectedType == t
                                          ? C.secondary
                                          : C.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text('TITRE',
                        style: StoryText.mono(
                            size: 10,
                            color: C.textDim,
                            letterSpacing: 2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Une idée, un projet, une note…',
                        filled: true,
                        fillColor: C.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tags (separes par des virgules)
                    Text('TAGS',
                      style: StoryText.mono(
                        size: 10,
                        color: C.textDim,
                        letterSpacing: 2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tagsCtrl,
                      decoration: InputDecoration(
                        hintText: 'thriller, paris, mystere',
                        helperText: 'Separes par des virgules',
                        helperStyle: StoryText.sans(size: 10, color: C.textDim),
                        filled: true,
                        fillColor: C.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: C.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) return;
                          // Parse les tags (separes par des virgules), trim, enleve vides)
                          final tags = tagsCtrl.text
                              .split(',')
                              .map((t) => t.trim())
                              .where((t) => t.isNotEmpty)
                              .toList();
                          final item = CoffreNotifier.buildNew(
                            type: selectedType,
                            title: title,
                            tags: tags,
                          );
                          ref.read(coffreProvider.notifier).addItem(item);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Ajouter'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  String _typeLabel(CoffreItemType t) {
    switch (t) {
      case CoffreItemType.projet:
        return '📖 Projet';
      case CoffreItemType.note:
        return '🖊 Note';
      case CoffreItemType.idee:
        return '💡 Idée';
    }
  }
}

class _DismissibleCard extends StatelessWidget {
  final CoffreItem item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _DismissibleCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('coffre_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24, bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4466).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Color(0xFFFF4466)),
      ),
      onDismissed: (_) => onDelete(),
      child: CoffreCard(item: item, onPressed: onTap),
    );
  }
}
