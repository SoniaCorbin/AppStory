import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/assembled_block.dart';
import '../../models/block_type.dart';
import '../../state/ai_settings_provider.dart';
import '../../state/atelier_provider.dart';
import '../../state/library_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../../widgets/chips/block_chip.dart';
import 'widgets/assembled_block_tile.dart';
import 'widgets/generated_story_card.dart';
import 'widgets/ham_btn.dart';

class AtelierScreen extends ConsumerWidget {
  final VoidCallback onMenu;
  final VoidCallback onEdit;

  const AtelierScreen({
    super.key,
    required this.onMenu,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(atelierProvider);
    final ctrl = ref.read(atelierProvider.notifier);
    final aiOn = ref.watch(aiSettingsProvider.select(
        (s) => s.enabled && s.hasApiKey));

    // Affiche l'erreur IA en SnackBar si présente
    ref.listen<String?>(atelierProvider.select((s) => s.error), (prev, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠ $next')),
        );
      }
    });

    return Stack(
      children: [
        const GridBg(opacity: 0.30),
        const MeshBlobs(),

        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 130),
            children: [
              const SizedBox(height: 56),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HamBtn(onMenu: onMenu),
                    Row(
                      children: [
                        Text('⚗ LABORATOIRE',
                            style: StoryText.mono(
                                size: 10,
                                color: C.accent,
                                letterSpacing: 3)),
                        if (aiOn) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: C.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: C.accent.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    size: 10, color: C.accent),
                                const SizedBox(width: 4),
                                Text('IA',
                                    style: StoryText.mono(
                                        size: 9, color: C.accent)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("L'Atelier",
                        style:
                            StoryText.serif(size: 28, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        'Touche un type pour piocher dans ta bibliothèque',
                        style: StoryText.sans(
                            size: 13,
                            color: C.textMuted,
                            style: FontStyle.italic)),
                  ],
                ),
              ),

              // Palette — chaque chip ouvre la bibliothèque du type
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PALETTE',
                            style: StoryText.mono(
                                size: 10,
                                color: C.textMuted,
                                letterSpacing: 2)),
                        GestureDetector(
                          onTap: ctrl.surprise,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: C.accent.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: C.accent.withValues(alpha: 0.27)),
                            ),
                            child: Row(
                              children: [
                                const Text('🎲'),
                                const SizedBox(width: 6),
                                Text('Surprends-moi',
                                    style: StoryText.mono(
                                        size: 11, color: C.accent)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in BlockTypeX.all)
                          BlockChip(
                            type: type,
                            selected: st.assembled.any((b) => b.type == type),
                            onPressed: () =>
                                _openLibraryPicker(context, ref, type),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Assemblage
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSEMBLAGE · ${st.assembled.length} blocs',
                      style: StoryText.mono(
                          size: 10, color: C.textMuted, letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: C.primary.withValues(alpha: 0.13)),
                      ),
                      child: st.assembled.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'Touche un type dans la palette\npour piocher dans ta bibliothèque',
                                  textAlign: TextAlign.center,
                                  style: StoryText.sans(
                                      size: 13,
                                      color: C.textDim,
                                      style: FontStyle.italic),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                for (int i = 0; i < st.assembled.length; i++) ...[
                                  AssembledBlockTile(
                                    block: st.assembled[i],
                                    onRemove: () => ctrl
                                        .removeBlock(st.assembled[i].type),
                                    onValueChanged: (newValue) =>
                                        ctrl.updateBlockValue(
                                            st.assembled[i].type, newValue),
                                  ),
                                  if (i != st.assembled.length - 1)
                                    const SizedBox(height: 10),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              // Bouton générer
              if (st.assembled.length >= 2 && !st.generated)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: st.generating
                            ? C.surface2
                            : const Color(0xFF7B2FF7),
                        foregroundColor: C.text,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: st.generating ? null : () => ctrl.generate(),
                      child: Text(st.generating
                          ? '✦ Génération en cours…'
                          : "✦ Générer l'amorce narrative"),
                    ),
                  ),
                ),

              // Résultat généré
              if (st.generated)
                GeneratedStoryCard(
                  story: st.story,
                  saved: st.saved,
                  onSave: ctrl.saveAsStory,
                  onDevelop: onEdit,
                  onReset: ctrl.resetGenerated,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Ouvre le sélecteur de bibliothèque pour un type donné.
  void _openLibraryPicker(
      BuildContext context, WidgetRef ref, BlockType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: SafeArea(
              child: _LibraryPickerSheet(type: type),
            ),
          ),
        );
      },
    );
  }
}

class _LibraryPickerSheet extends ConsumerWidget {
  final BlockType type;

  const _LibraryPickerSheet({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(libraryProvider
        .select((all) => all.where((e) => e.type == type).toList()));

    return Padding(
      padding: const EdgeInsets.all(20),
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

          // Title
          Row(
            children: [
              Text(type.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(type.label,
                  style: StoryText.serif(size: 22, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(type.desc,
              style: StoryText.sans(
                  size: 12,
                  color: C.textMuted,
                  style: FontStyle.italic)),
          const SizedBox(height: 16),

          // Bouton créer nouveau
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: type.color,
              side: BorderSide(color: type.color.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _openCreateOrEdit(context, ref, type, null),
            icon: const Icon(Icons.add_rounded),
            label: Text('Créer un nouveau ${type.label.toLowerCase()}'),
          ),
          const SizedBox(height: 16),

          // Liste des entrées
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Ta bibliothèque est vide.\nCrée ton premier !',
                  textAlign: TextAlign.center,
                  style: StoryText.sans(
                      size: 13,
                      color: C.textDim,
                      style: FontStyle.italic),
                ),
              ),
            )
          else ...[
            Text('TA BIBLIOTHÈQUE · ${entries.length}',
                style: StoryText.mono(
                    size: 10, color: C.textDim, letterSpacing: 2)),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final entry = entries[i];
                  return Dismissible(
                    key: ValueKey('lib_${entry.key}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFF4466).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFFF4466)),
                    ),
                    onDismissed: (_) {
                      ref
                          .read(libraryProvider.notifier)
                          .delete(entry.key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '🗑 "${entry.value}" supprimé de la bibliothèque')),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        // Sélectionne cette entrée pour l'assemblage
                        final atelier =
                            ref.read(atelierProvider.notifier);
                        if (ref
                            .read(atelierProvider)
                            .assembled
                            .any((b) => b.type == type)) {
                          atelier.updateBlockValue(type, entry.value);
                        } else {
                          atelier.addBlockWithValue(type, entry.value);
                        }
                        Navigator.pop(context);
                      },
                      onLongPress: () =>
                          _openCreateOrEdit(context, ref, type, entry),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: C.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: type.color.withValues(alpha: 0.18)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(entry.value,
                                  style: StoryText.sans(
                                      size: 13, color: C.text)),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit_outlined,
                                size: 14, color: C.textDim),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text('  💡 Touche pour sélectionner · Maintiens pour modifier · Glisse pour supprimer',
              style: StoryText.mono(size: 9, color: C.textDim)),
        ],
      ),
    );
  }

  Future<void> _openCreateOrEdit(BuildContext context, WidgetRef ref,
      BlockType type, LibraryEntry? existing) async {
    final ctrl = TextEditingController(text: existing?.value ?? '');
    final isEdit = existing != null;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: C.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(type.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  isEdit ? 'Modifier' : 'Nouveau ${type.label.toLowerCase()}',
                  style: StoryText.serif(size: 18, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type.desc,
                  style: StoryText.sans(
                      size: 12,
                      color: C.textMuted,
                      style: FontStyle.italic)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 4,
                minLines: 1,
                style: StoryText.sans(size: 14),
                decoration: InputDecoration(
                  hintText: 'Décris ton ${type.label.toLowerCase()}…',
                  hintStyle: StoryText.sans(size: 13, color: C.textDim),
                  filled: true,
                  fillColor: C.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (isEdit)
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4466)),
                onPressed: () {
                  ref.read(libraryProvider.notifier).delete(existing.key);
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🗑 Supprimé')),
                  );
                },
                child: const Text('Supprimer'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Annuler',
                  style: StoryText.sans(size: 13, color: C.textMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: type.color,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
              child: Text(isEdit ? 'Enregistrer' : 'Créer'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    final libCtrl = ref.read(libraryProvider.notifier);
    if (isEdit) {
      await libCtrl.update(existing.key, result);
    } else {
      await libCtrl.add(type, result);
    }
  }
}
