import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../screens/shell/nav_items.dart';
import '../backgrounds/grid_bg.dart';
import '../backgrounds/mesh_blobs.dart';

class DrawerMenu extends StatelessWidget {
  final NavTab active;
  final ValueChanged<NavTab> onNav;
  final VoidCallback onClose;

  const DrawerMenu({
    super.key,
    required this.active,
    required this.onNav,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final panelWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop: cliquer ici ferme le drawer
            GestureDetector(
              onTap: onClose,
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),

            // Panel: ne doit PAS fermer quand on clique dedans
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: panelWidth,
                height: double.infinity,
                child: Material(
                  color: C.surface,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.white.withOpacity(0.06))),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 40,
                          offset: const Offset(6, 0),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const GridBg(opacity: 0.15),
                        const MeshBlobs(),
                        SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [C.primary.withOpacity(0.27), C.accent.withOpacity(0.27)],
                                        ),
                                        border: Border.all(color: C.primary.withOpacity(0.33), width: 2),
                                      ),
                                      child: const Center(child: Text('🖊', style: TextStyle(fontSize: 26))),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Votre Atelier', style: StoryText.serif(size: 17, weight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text('Écrivain · Niveau 3', style: StoryText.mono(size: 10, color: C.primary)),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              // Nav list
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.only(top: 6),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                                      child: Text(
                                        'NAVIGATION',
                                        style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2),
                                      ),
                                    ),
                                    ...NavTab.values.map((t) {
                                      final isActive = t == active;
                                      return InkWell(
                                        onTap: () {
                                          onNav(t);
                                          onClose();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                          decoration: BoxDecoration(
                                            color: isActive ? C.primary.withOpacity(0.07) : Colors.transparent,
                                            border: Border(
                                              left: BorderSide(
                                                color: isActive ? C.primary : Colors.transparent,
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 28,
                                                child: Icon(t.icon, color: isActive ? C.primary : C.textMuted, size: 22),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      t.label,
                                                      style: StoryText.sans(
                                                        size: 14,
                                                        weight: isActive ? FontWeight.w600 : FontWeight.w400,
                                                        color: isActive ? C.primary : C.text,
                                                      ),
                                                    ),
                                                    Text(
                                                      _subFor(t),
                                                      style: StoryText.sans(
                                                        size: 11,
                                                        color: C.textMuted,
                                                        style: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isActive)
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: C.primary,
                                                    borderRadius: BorderRadius.circular(3),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),

                                    // Divider
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      child: Container(height: 1, color: Colors.white.withOpacity(0.05)),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text('StoryBlocks v1.0 · beta', style: StoryText.mono(size: 10, color: C.textDim)),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subFor(NavTab t) => switch (t) {
    NavTab.home => 'Tableau de bord',
    NavTab.atelier => 'Assemblez vos blocs',
    NavTab.coffre => 'Toutes vos idées',
    NavTab.agenda => 'Journal créatif',
    NavTab.profil => 'Stats & badges',
  };
}