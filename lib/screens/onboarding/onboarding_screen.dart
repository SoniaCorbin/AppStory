import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/story_text_styles.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text('Bienvenue', style: StoryText.serif(size: 28, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    "On va porter l'onboarding complet juste après.",
                    style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: C.green,
                        foregroundColor: C.bg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.shell),
                      child: const Text("Entrer dans l'Atelier ✦"),
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