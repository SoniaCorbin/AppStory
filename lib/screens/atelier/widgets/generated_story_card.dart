import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';

class GeneratedStoryCard extends StatelessWidget {
  final String story;
  final VoidCallback onDevelop;
  final VoidCallback onReset;

  const GeneratedStoryCard({
    super.key,
    required this.story,
    required this.onDevelop,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 14.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: C.accent.withOpacity(0.20)),
        boxShadow: [BoxShadow(color: C.accent.withOpacity(0.13), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✦ AMORCE GÉNÉRÉE', style: StoryText.mono(size: 10, color: C.accent, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text('"$story"', style: StoryText.serif(size: 14, weight: FontWeight.w400, style: FontStyle.italic).copyWith(height: 1.8)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: C.primary.withOpacity(0.13),
                    foregroundColor: C.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onDevelop,
                  child: const Text('Développer →'),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: C.surface2,
                  foregroundColor: C.textMuted,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                ),
                onPressed: onReset,
                child: const Text('↺'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}