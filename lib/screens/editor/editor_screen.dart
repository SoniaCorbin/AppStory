import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/assembled_block.dart';
import '../../models/story.dart';
import '../../state/story_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../../widgets/chips/block_chip.dart';
import '../../models/block_type.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final Story story;

  const EditorScreen({super.key, required this.story});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late List<AssembledBlock> _blocks;
  late List<TextEditingController> _controllers;
  late TextEditingController _titleController;
  late TextEditingController _hookController;

  @override
  void initState() {
    super.initState();
    _blocks = List.of(widget.story.blocks);
    _controllers = [
      for (final b in _blocks) TextEditingController(text: b.value),
    ];
    _titleController = TextEditingController(text: widget.story.title);
    _hookController = TextEditingController(text: widget.story.hook);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _titleController.dispose();
    _hookController.dispose();
    super.dispose();
  }

  Future<void> _saveAndClose() async {
    final updatedBlocks = <AssembledBlock>[
      for (var i = 0; i < _blocks.length; i++)
        _blocks[i].copyWith(value: _controllers[i].text.trim()),
    ];

    final updatedStory = widget.story.copyWith(
      title: _titleController.text.trim().isEmpty
          ? widget.story.title
          : _titleController.text.trim(),
      blocks: updatedBlocks,
      hook: _hookController.text.trim(),
      lastEdit: 'à l\'instant',
    );

    // Sauvegarde dans Hive via le provider
    await ref.read(storyProvider.notifier).updateStory(updatedStory);

    if (!mounted) return;
    Navigator.pop(context, updatedStory);
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le bloc ?'),
        content: Text('Supprimer "${_blocks[index].type.label}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _blocks.removeAt(index);
      _controllers.removeAt(index).dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBg(opacity: 0.25),
          const MeshBlobs(warm: true),
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 56),

                // Top bar
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
                        child: Text(
                          'ÉDITEUR',
                          style: StoryText.mono(
                              size: 10, color: C.textDim, letterSpacing: 2),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: C.text,
                          foregroundColor: C.bg,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        onPressed: _saveAndClose,
                        child: Text('Enregistrer',
                            style:
                                StoryText.mono(size: 10, letterSpacing: 1.2)),
                      ),
                    ],
                  ),
                ),

                // Titre éditable
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: TextField(
                    controller: _titleController,
                    style: StoryText.serif(size: 24, weight: FontWeight.w800),
                    decoration: InputDecoration(
                      hintText: 'Titre de l\'histoire',
                      hintStyle:
                          StoryText.serif(size: 24, color: C.textDim),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Amorce éditable
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: C.accent.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✦ AMORCE',
                            style: StoryText.mono(
                                size: 10,
                                color: C.accent,
                                letterSpacing: 2.2)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _hookController,
                          minLines: 3,
                          maxLines: 8,
                          style: StoryText.serif(
                                  size: 13, style: FontStyle.italic)
                              .copyWith(height: 1.7),
                          decoration: InputDecoration(
                            hintText: 'Saisis ou colle ici l\'amorce…',
                            hintStyle: StoryText.sans(
                                size: 13, color: C.textDim),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Text(
                    'Blocs · ${_blocks.length}',
                    style: StoryText.mono(
                        size: 10, color: C.textDim, letterSpacing: 2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final b in _blocks) BlockChip(type: b.type)
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _blocks.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;

                        final b = _blocks.removeAt(oldIndex);
                        _blocks.insert(newIndex, b);

                        final c = _controllers.removeAt(oldIndex);
                        _controllers.insert(newIndex, c);
                      });
                    },
                    itemBuilder: (context, index) {
                      final block = _blocks[index];
                      final controller = _controllers[index];

                      return Container(
                        key: ValueKey('block_${index}_${block.type.name}'),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: BlockChip(type: block.type)),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () => _confirmDelete(index),
                                  icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: C.textMuted),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(Icons.drag_handle_rounded,
                                        color: C.textMuted),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: controller,
                              minLines: 2,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: block.type.desc,
                                filled: true,
                                fillColor:
                                    Colors.white.withValues(alpha: 0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white
                                          .withValues(alpha: 0.06)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white
                                          .withValues(alpha: 0.06)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: block.type.color
                                          .withValues(alpha: 0.6)),
                                ),
                              ),
                              style: StoryText.sans(size: 13, color: C.text),
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
