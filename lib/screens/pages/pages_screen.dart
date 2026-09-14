import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/page_document.dart';
import '../../models/story.dart';
import '../../models/assembled_block.dart';
import '../../models/block_type.dart';
import '../../state/pages_provider.dart';
import '../../state/story_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../atelier/widgets/ham_btn.dart';
import 'dart:math';

class PagesScreen extends ConsumerStatefulWidget {
  final VoidCallback onMenu;
  const PagesScreen({super.key, required this.onMenu});

  @override
  ConsumerState<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends ConsumerState<PagesScreen> {
  final Set<String> _selected = {};
  bool _selectionMode = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selectionMode = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _startSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selected.add(id);
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  Future<void> _mergePages(List<PageDocument> pages) async {
    final selected = pages.where((p) => _selected.contains(p.id)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Titre de la fusion
    final titleCtrl = TextEditingController(
        text: selected.map((p) => p.title).join(' + '));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('Fusionner ${selected.length} pages',
            style: StoryText.serif(size: 18, weight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titre de l\'histoire :',
                style: StoryText.sans(size: 12, color: C.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: titleCtrl,
              style: StoryText.sans(size: 14, color: C.text),
              decoration: InputDecoration(
                filled: true,
                fillColor: C.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
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
            child: Text('Fusionner',
                style: StoryText.mono(size: 12, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Combiner le contenu
    final combinedContent = selected
        .map((p) => '## ${p.title}\n\n${p.content}')
        .join('\n\n---\n\n');

    final colors = [
      const Color(0xFF7B2FF7),
      const Color(0xFF00D4FF),
      const Color(0xFFFF6B35),
      const Color(0xFF00E5A0),
      const Color(0xFFFFD700),
    ];

    final newStory = Story(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: titleCtrl.text.trim().isEmpty ? 'Histoire fusionnée' : titleCtrl.text.trim(),
      genre: 'Écriture libre',
      blocks: [
        AssembledBlock(type: BlockType.ton, value: combinedContent),
      ],
      progress: 0,
      color: colors[Random().nextInt(colors.length)],
      lastEdit: 'à l\'instant',
      hook: combinedContent,
    );

    await ref.read(storyProvider.notifier).addStory(newStory);

    if (mounted) {
      _cancelSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Histoire créée ! 📖',
              style: StoryText.sans(size: 13, color: C.text)),
          backgroundColor: C.surface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(pagesProvider);

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(warm: true),
        Positioned.fill(
          child: Column(
            children: [
              const SizedBox(height: 56),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _selectionMode
                            ? TextButton(
                          onPressed: _cancelSelection,
                          child: Text('Annuler',
                              style: StoryText.mono(
                                  size: 12, color: C.textMuted)),
                        )
                            : HamBtn(onMenu: widget.onMenu),
                        Row(
                          children: [
                            if (_selectionMode && _selected.length >= 2)
                              IconButton(
                                icon: Icon(Icons.merge_rounded,
                                    color: C.primary),
                                tooltip: 'Fusionner',
                                onPressed: () => _mergePages(pages),
                              ),
                            if (!_selectionMode)
                              IconButton(
                                icon: Icon(Icons.add, color: C.primary),
                                onPressed: () =>
                                    _openEditor(context, ref, null),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Text('✦ MES PAGES',
                        style: StoryText.mono(
                            size: 10, color: C.primary, letterSpacing: 3)),
                    const SizedBox(height: 4),
                    Text('Mes Pages',
                        style: StoryText.serif(
                            size: 28, weight: FontWeight.w700)),
                    Text(
                      _selectionMode
                          ? '${_selected.length} sélectionnée${_selected.length != 1 ? 's' : ''}'
                          : '${pages.length} page${pages.length != 1 ? 's' : ''}',
                      style: StoryText.sans(
                          size: 13,
                          color: _selectionMode ? C.primary : C.textMuted,
                          style: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: pages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: pages.length,
                  itemBuilder: (_, i) => _PageTile(
                    page: pages[i],
                    selected: _selected.contains(pages[i].id),
                    selectionMode: _selectionMode,
                    onTap: () => _selectionMode
                        ? _toggleSelection(pages[i].id)
                        : _openEditor(context, ref, pages[i]),
                    onLongPress: () => _startSelection(pages[i].id),
                    onDelete: () => ref
                        .read(pagesProvider.notifier)
                        .deletePage(pages[i].id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, PageDocument? page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PageEditorScreen(page: page),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📄', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Aucune page encore.',
              style: StoryText.serif(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Appuie sur + pour commencer à écrire !',
              style: StoryText.sans(
                  size: 13,
                  color: C.textMuted,
                  style: FontStyle.italic)),
          const SizedBox(height: 8),
          Text('Maintiens une page pour la sélectionner et fusionner.',
              style: StoryText.mono(size: 10, color: C.textDim),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  final PageDocument page;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const _PageTile({
    required this.page,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final preview = page.content.trim().isEmpty
        ? 'Aucun contenu…'
        : page.content.trim().replaceAll('\n', ' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? C.primary.withValues(alpha: 0.12)
                : C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? C.primary.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.06),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected ? C.primary : C.textDim,
                    size: 22,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: StoryText.serif(
                          size: 16, weight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      style: StoryText.sans(size: 13, color: C.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${page.updatedAt.day}/${page.updatedAt.month}/${page.updatedAt.year}',
                      style: StoryText.mono(size: 10, color: C.textDim),
                    ),
                  ],
                ),
              ),
              if (!selectionMode)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Éditeur de page
// ─────────────────────────────────────────────

class _PageEditorScreen extends ConsumerStatefulWidget {
  final PageDocument? page;
  const _PageEditorScreen({this.page});

  @override
  ConsumerState<_PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends ConsumerState<_PageEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.page?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.page?.content ?? '');
    _titleCtrl.addListener(() => setState(() => _hasChanges = true));
    _contentCtrl.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (widget.page == null) {
      await ref.read(pagesProvider.notifier).addPage(title, content);
    } else {
      await ref
          .read(pagesProvider.notifier)
          .updatePage(widget.page!.id, title, content);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: C.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.page == null ? 'Nouvelle page' : 'Modifier',
          style: StoryText.serif(size: 17, weight: FontWeight.w700),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _save,
              child: Text('Sauver',
                  style: StoryText.mono(size: 13, color: C.primary)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              style: StoryText.serif(size: 22, weight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Titre…',
                hintStyle: StoryText.serif(
                    size: 22,
                    weight: FontWeight.w700,
                    color: C.textDim),
                border: InputBorder.none,
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: StoryText.sans(size: 16, color: C.text)
                    .copyWith(height: 1.7),
                decoration: InputDecoration(
                  hintText: 'Commence à écrire…',
                  hintStyle: StoryText.sans(
                      size: 16,
                      color: C.textDim,
                      style: FontStyle.italic),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}