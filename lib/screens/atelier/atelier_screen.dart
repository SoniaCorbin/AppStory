import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/block_type.dart';
import '../../state/atelier_provider.dart';
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

    return Stack(
      children: [
        const GridBg(opacity: 0.30),
        const MeshBlobs(),

        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              const SizedBox(height: 56),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HamBtn(onMenu: onMenu),
                    Text('⚗ LABORATOIRE', style: StoryText.mono(size: 10, color: C.accent, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text("L'Atelier", style: StoryText.serif(size: 28, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Assemblez vos blocs narratifs', style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic)),
                  ],
                ),
              ),

              // Palette
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PALETTE', style: StoryText.mono(size: 10, color: C.textMuted, letterSpacing: 2)),
                        GestureDetector(
                          onTap: ctrl.surprise,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: C.accent.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: C.accent.withValues(alpha: 0.27)),
                            ),
                            child: Row(
                              children: [
                                const Text('🎲'),
                                const SizedBox(width: 6),
                                Text('Surprends-moi', style: StoryText.mono(size: 11, color: C.accent)),
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
                            onPressed: () => ctrl.addBlock(type),
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
                      style: StoryText.mono(size: 10, color: C.textMuted, letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: C.primary.withValues(alpha: 0.13)),
                      ),
                      child: st.assembled.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Sélectionnez des blocs ci-dessus',
                            style: StoryText.sans(size: 13, color: C.textDim, style: FontStyle.italic),
                          ),
                        ),
                      )
                          : Column(
                        children: [
                          for (int i = 0; i < st.assembled.length; i++) ...[
                            AssembledBlockTile(
                              block: st.assembled[i],
                              onRemove: () => ctrl.removeBlock(st.assembled[i].type),
                            ),
                            if (i != st.assembled.length - 1) const SizedBox(height: 10),
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
                            : const Color(0xFF7B2FF7), // accent
                        foregroundColor: C.text,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: st.generating ? null : () => ctrl.generate(),
                      child: Text(st.generating ? '✦ Génération en cours…' : "✦ Générer l'amorce narrative"),
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
}