import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/story_text_styles.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;

  static const _slides = <_Slide>[
    _Slide(
      icon: '✦',
      title: 'Bienvenue dans StoryBlocks',
      desc: "Le laboratoire pour transformer une étincelle d'idée en récit.",
    ),
    _Slide(
      icon: '⚗',
      title: "L'Atelier",
      desc:
          "Assemble des blocs narratifs (ton, personnage, lieu, conflit…) et génère ton amorce.",
    ),
    _Slide(
      icon: '◈',
      title: 'Le Coffre & l\'Agenda',
      desc:
          "Garde tes idées en sécurité dans le Coffre, planifie tes sessions d'écriture dans l'Agenda.",
    ),
  ];

  Future<void> _finish() async {
    final settings = Hive.box('settings');
    await settings.put('onboarded', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Routes.shell);
  }

  void _next() {
    if (page < _slides.length - 1) {
      setState(() => page++);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[page];
    final isLast = page == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          const GridBg(opacity: 0.3),
          const MeshBlobs(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${page + 1} / ${_slides.length}',
                          style: StoryText.mono(
                              size: 11,
                              color: C.textDim,
                              letterSpacing: 2)),
                      TextButton(
                        onPressed: _finish,
                        child: Text('Passer',
                            style: StoryText.mono(
                                size: 11, color: C.textMuted)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(page),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slide.icon,
                            style: TextStyle(
                                fontSize: 56, color: C.primary)),
                        const SizedBox(height: 24),
                        Text(slide.title,
                            style: StoryText.serif(
                                size: 32, weight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Text(slide.desc,
                            style: StoryText.sans(
                                size: 15,
                                color: C.textMuted,
                                weight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Indicateur de pages
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          width: i == page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                i == page ? C.primary : C.surface3,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isLast ? C.green : C.primary,
                        foregroundColor: C.bg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _next,
                      child: Text(isLast
                          ? "Entrer dans l'Atelier ✦"
                          : 'Suivant →'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String icon;
  final String title;
  final String desc;
  const _Slide({required this.icon, required this.title, required this.desc});
}
