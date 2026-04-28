import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/story_text_styles.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int phase = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () => setState(() => phase = 1));
    Future.delayed(const Duration(milliseconds: 1200), () => setState(() => phase = 2));
    Future.delayed(const Duration(milliseconds: 2200), () => setState(() => phase = 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBg(opacity: 0.5),
          const MeshBlobs(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (phase >= 2) ...[
                    Text(
                      '◈ LABORATOIRE CRÉATIF',
                      style: StoryText.mono(size: 11, color: C.primary, letterSpacing: 4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: StoryText.serif(size: 42, weight: FontWeight.w900),
                        children: [
                          const TextSpan(text: 'Story'),
                          TextSpan(text: 'Blocks', style: StoryText.serif(size: 42, weight: FontWeight.w900, color: C.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "De l'étincelle à l'histoire",
                      style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic, weight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 52),
                  if (phase >= 3)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: C.primary,
                        foregroundColor: C.bg,
                        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.onboarding),
                      child: const Text("Entrer dans l'Atelier →"),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text('v1.0 · beta', style: StoryText.mono(size: 10, color: C.textDim)),
            ),
          ),
        ],
      ),
    );
  }
}